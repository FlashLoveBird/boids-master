
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_ink_source object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local bis = {}
bis.table = 'bis'
bis.debug = true
bis.level = nil
bis.level_map = nil
bis.flock = nil
bis.sources = nil
bis.depletion_rate = 100000
bis.surface_threshold = 0.5
bis.area = 20
bis.unit_area = TILE_WIDTH * TILE_HEIGHT
bis.area_changed = false
bis.boid_hash = nil
bis.collision_table = nil
bis.polygonizer_update_rate = 1.5   -- updates per second
bis.min_radius = 20
bis.food = nil
bis.animationExtend = nil
bis.animationDecrease = nil
bis.x = 0
bis.y = 0
bis.index = nil

local bis_mt = { __index = bis }
function bis:new(level, flock, index)
  local bis = setmetatable({}, bis_mt)
  bis.level = level
  bis.level_map = level:get_level_map()
  bis.flock = flock
  bis.sources = {}
  bis.boid_hash = {}
  bis.collision_table = {}
  bis.update_timer = timer:new(level:get_master_timer(), 1/bis.polygonizer_update_rate)
  bis.update_timer:start()
  inkGraphic = love.graphics.newImage("images/ui/ink-source.png")
  bis:init(index)
  return bis
end

function bis:init(index)
self.index = index
end

function bis:newAnimation(image, width, height, duration)
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

function bis:setFlock(flock)
	self.flock = flock
end

function bis:add_ink(x, y, radius)
  local p = self.level_map:add_point_to_source_polygonizer(x, y, radius)
  self.sources[#self.sources + 1] = self:_new_food_source(x, y, radius, p)
  self:_calculate_total_area()
  self.food = true
  return p
end

function bis:force_polygonizer_update()
  self.level_map:update_source_polygonizer()
end

function bis:set_depletion_rate(r)
  self.depletion_rate = r
end

function bis:set_update_rate(r)
  self.polygonizer_update_rate = r
end

function bis:set_surface_threshold(thresh)
  self.surface_threshold = thresh
end

function bis:remove_food_source(primitive)
  self.level_map.source_polygonizer:remove_primitive(primitive)
  for i=#self.sources,1,-1 do
    if self.sources[i].primitive == primitive then
      table.remove(self.sources, i)
	  self.food = false
      break
    end
  end
end

function bis:_new_food_source(x, y, radius, primitive)
  local source = {}
  source.x, source.y = x, y
  source.radius = radius
  source.starting_radius = radius
  source.primitive = primitive
  print("source")
  print(source)
  return source
end

function bis:get_food()
  return self.food
end

-- for fairness when attaching boids to a food source
function bis:_shuffle_food_sources()
  for i=1,#self.sources do
    local r = math.random(1,#self.sources)
    self.sources[r], self.sources[i] = self.sources[i], self.sources[r]
  end
end

function bis:_calculate_total_area()
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

function bis:_update_area(dt)
  local sources = self.sources
  local bhash = self.boid_hash
  local objects = self.collision_table
  table.clear_hash(bhash)
  if self.flock and self.sources[1] then 
		local s = sources[1]
		local r = s.radius
		table.clear(objects)
		self.flock:get_boids_in_radius(s.x, s.y, r, objects)
		local count = 0 
		if #objects>0 then
			local randomNb = 1--math.random(0,1000)
			for i=1,#objects do
			  if not bhash[objects[i]] and objects[i].foodGrab<50 and objects[i].boidType~=10 then
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
		if units_eaten > 0 and s.primitive ~= nil then
		  local new_area = math.pi * r * r - units_eaten
		  new_radius = math.sqrt(new_area / math.pi)
		  new_radius = math.max(new_radius, 0)
		  s.radius = new_radius or 1
		  s.primitive:set_radius(new_radius)
		  
		  if new_radius< self.min_radius then
			self.level_map:remove_primitive_from_source_polygonizer(s.primitive)
			table.remove(self.sources, i)
		  end
		end
	end
end

function bis:_update_polygonizer()
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
function bis:update(dt)
  self:_shuffle_food_sources()
  self:_update_area(dt)
  self:_calculate_total_area()
  self:_update_polygonizer()
end

------------------------------------------------------------------------------
function bis:draw(x, y)
   if not self.debug then return end
  local sources = self.sources
  for i=1,#sources do
    local s = sources[i]    
    local sr = s.starting_radius
    local r = s.radius
    local pct = math.floor(((r * r) / (sr * sr)) * 100)
	lg.setColor(255, 255, 255, 255)
	love.graphics.draw(foodGraphic, s.x-x, s.y-y)
    lg.circle("line", s.x-x, s.y-y, s.radius)
	lg.print(pct.."%", s.x-x, s.y-y)
  end
end

return bis















