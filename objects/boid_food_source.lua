
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_food_source object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local bfs = {}
bfs.table = 'bfs'
bfs.debug = true
bfs.level = nil
bfs.level_map = nil
bfs.flock = nil
bfs.sources = nil
bfs.depletion_rate = 100000
bfs.surface_threshold = 0.5
bfs.area = 20
bfs.unit_area = TILE_WIDTH * TILE_HEIGHT
bfs.area_changed = false
bfs.boid_hash = nil
bfs.collision_table = nil
bfs.polygonizer_update_rate = 1.5   -- updates per second
bfs.min_radius = 20
bfs.max_radius = 100
bfs.bushParent = nil
bfs.food = nil
bfs.animationExtend = nil
bfs.animationDecrease = nil
bfs.x = 0
bfs.y = 0
bfs.index = nil

local bfs_mt = { __index = bfs }
function bfs:new(level, flock, bushParent, index)
  local bfs = setmetatable({}, bfs_mt)
  bfs.level = level
  bfs.level_map = level:get_level_map()
  bfs.flock = flock
  bfs.sources = {}
  bfs.boid_hash = {}
  bfs.collision_table = {}
  bfs.update_timer = timer:new(level:get_master_timer(), 1/bfs.polygonizer_update_rate)
  bfs.update_timer:start()
  foodGraphic = love.graphics.newImage("images/env/seeds.png")
  bfs:init(index, bushParent)
  return bfs
end

function bfs:init(index, bushParent)

self.animationExtend = self:newAnimation(love.graphics.newImage("images/env/seeds.png"), 280, 249, 5)
self.animationDecrease = self:newAnimation(love.graphics.newImage("images/env/seeds.png"), 280, 249, 5)
self.index = index
self.bushParent = bushParent
end

function bfs:newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end

function bfs:setFlock(flock)
	self.flock = flock
end

function bfs:add_food(x, y, radius)
  local p = self.level_map:add_point_to_source_polygonizer(x, y, radius)
  local new_food_source = self:_new_food_source(x, y, radius, p)
  table.insert(self.sources, new_food_source)
  self:_calculate_total_area()
  self.food = true
  return p
end

function bfs:force_polygonizer_update()
  self.level_map:update_source_polygonizer()
end

function bfs:set_depletion_rate(r)
  self.depletion_rate = r
end

function bfs:set_update_rate(r)
  self.polygonizer_update_rate = r
end

function bfs:set_surface_threshold(thresh)
  self.surface_threshold = thresh
end

function bfs:remove_food_source(primitive)
  self.level_map.source_polygonizer:remove_primitive(primitive)
  for i=#self.sources,1,-1 do
    if self.sources[i].primitive == primitive then
      table.remove(self.sources, i)
	  self.food = false
      break
    end
  end
end

function bfs:_new_food_source(x, y, radius, primitive)
  local source = {}
  source.x, source.y = x, y
  source.radius = radius
  source.starting_radius = radius
  source.primitive = primitive
  print("source")
  print(source)
  return source
end

function bfs:get_food()
  local source = self.sources[1]
  if source~=nil then
	  if source.radius > 20 then
		return true
	  else
		return false
	  end
  else
	return false
  end
end

-- for fairness when attaching boids to a food source
function bfs:_shuffle_food_sources()
  for i=1,#self.sources do
    local r = math.random(1,#self.sources)
    self.sources[r], self.sources[i] = self.sources[i], self.sources[r]
  end
end

function bfs:_calculate_total_area()
  local pi = math.pi
  local area = 0
  for i=1,#self.sources do
    local r = self.sources[i].radius
    area = area + pi * r * r
  end
  
  local eps = 0.01
  local new_area = area / self.unit_area
  if math.abs(self.area - new_area) > eps then
    self.area = new_area
    self.area_changed = true
  end
end

function bfs:_update_area(dt)
  local sources = self.sources
  local bhash = self.boid_hash
  local objects = self.collision_table
  table.clear_hash(bhash)
  if self.flock and self.sources[1] then 
		local s = sources[1]
		local r = s.radius
		table.clear(objects)
		self.flock:get_boids_in_radius(s.x, s.y, r + 5, objects)
		local count = 0 
		if #objects>0 then
			local randomNb = 1--math.random(0,1000)
			for i=1,#objects do
			  if not bhash[objects[i]] and objects[i].foodGrab<50 and objects[i].boidType~=10 and objects[i].boidType~=2 and r > 40 then
				count = count + 1
				bhash[objects[i]] = true
				objects[i]:grabFood(self.depletion_rate * 10 * dt)
			  elseif objects[i]:getObjectiv()~="goOut" and objects[i]:getObjectiv()~="goOnHomeWith" and objects[i].boidType~=10 then
				local x, y, z = objects[i]:get_position()
				objects[i]:set_waypoint(x+math.random(-200,200), y+math.random(-200,200), math.random(50,1000),50,100)
				objects[i]:unObstacleMe()
				objects[i]:setObjectiv("goOut")
			  end
			  if objects[i].boidType==10 then
					if objects[i]:getFood()<6 then
						objects[i]:canSetStateGrab(true)
						if objects[i]:getStateGrab() == true then
							count = count + 1
							objects[i]:grabFood(self.depletion_rate * 10 * dt)
						end
					end
			  end
			end
		end
		
		local units_eaten = self.depletion_rate * count * dt
		local new_radius = s.radius
		if units_eaten > 0 and s.primitive ~= nil then
		  local new_area = math.pi * r * r - units_eaten
		  new_radius = math.sqrt(new_area / math.pi)
		  new_radius = math.max(new_radius, 0)
		  s.radius = new_radius or 1
		  s.primitive:set_radius(new_radius)
		end
		if new_radius < 200 then
			--self.level_map:remove_primitive_from_source_polygonizer(s.primitive)
			--table.remove(self.sources, i)
			new_radius = s.radius + 0.1
		    s.primitive:set_radius(new_radius)
			s.radius = new_radius
		end
		local animationExtend = self.animationExtend
		local sr = s.starting_radius
		local r = s.radius
		local pct = math.floor(((r * r) / (sr * sr)) * 100)
		
		if pct > 80 then
			animationExtend.currentTime = 4
		elseif pct > 60 then
			animationExtend.currentTime = 3
		elseif pct > 40 then
			animationExtend.currentTime = 2
		elseif pct > 30 then
			animationExtend.currentTime = 1
		elseif pct > 20 then
			animationExtend.currentTime = 0
		elseif pct < 20 then
			local index = self.index
			animationExtend.currentTime = nil
			--self:force_polygonizer_update()
			--self.bushParent:resetFood()
			--self.food = false
			--self.level_map:remove_primitive_from_source_polygonizer(s.primitive)
			--table.remove(self.sources, i)
		end
	end
end

function bfs:_update_polygonizer()
  if self.update_timer:isfinished() then
    if self.area_changed then
      self:force_polygonizer_update()
      self.area_changed = false
      --print(math.random())
    end
    self.update_timer:set_length(1/self.polygonizer_update_rate)
    self.update_timer:start()
  end
end

------------------------------------------------------------------------------
function bfs:update(dt)
  self:_shuffle_food_sources()
  self:_update_area(dt)
  self:_calculate_total_area()
  self:_update_polygonizer()
end

------------------------------------------------------------------------------
function bfs:draw(x, y)
  if not self.debug then return end
  local sources = self.sources
  for i=1,#sources do
    local s = sources[i]    
    local sr = s.starting_radius
    local r = s.radius
    local pct = math.floor(((r * r) / (sr * sr)) * 100)
	lg.setColor(255, 255, 255, 255)
	--love.graphics.draw(foodGraphic, x, y)
    lg.circle("line", x, y, s.radius)
	lg.print(pct.."%", x, y)
	local animationExtend = self.animationExtend
	if animationExtend.currentTime then
		local spriteNum = math.floor(animationExtend.currentTime / animationExtend.duration * #animationExtend.quads) + 1
		love.graphics.draw(animationExtend.spriteSheet, animationExtend.quads[spriteNum], x-80, y-110)
	end
  end
  
end

return bfs















