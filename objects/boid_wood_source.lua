
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_wood_source object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local bws = {}
bws.table = 'bws'
bws.debug = true
bws.level = nil
bws.level_map = nil
bws.flock = nil
bws.sources = nil
bws.depletion_rate = 100000
bws.surface_threshold = 0.5
bws.area = 10
bws.unit_area = TILE_WIDTH * TILE_HEIGHT
bws.area_changed = false
bws.boid_hash = nil
bws.collision_table = nil
bws.polygonizer_update_rate = 1.5   -- updates per second
bws.min_radius = 50
bws.animationExtend = nil
bws.animationDecrease = nil
bws.x = 0
bws.y = 0
bws.index = nil
bws.treeParent = nil

local bws_mt = { __index = bws }
function bws:new(level, flock ,treeParent, index)
  local bws = setmetatable({}, bws_mt)
  bws.level = level
  bws.level_map = level:get_level_map()
  print('nouveau init bois')
  print(flock)
  bws.flock = flock
  bws.sources = {}
  bws.boid_hash = {}
  bws.collision_table = {}
  bws.update_timer = timer:new(level:get_master_timer(), 1/bws.polygonizer_update_rate)
  bws.update_timer:start()
  bws:init(index, treeParent)  
  return bws
end

function bws:init(index, treeParent)

self.animationExtend = self:newAnimation(love.graphics.newImage("images/env/wood.png"), 100, 131, 5)
self.animationDecrease = self:newAnimation(love.graphics.newImage("images/env/wood.png"), 100, 131, 5)
self.index = index
self.wood = false
self.treeParent = treeParent
end

function bws:getType()
	return 2
end

function bws:getState()
	return self.state
end


function bws:add_wood(x, y, radius)
  local p = self.level_map:add_point_to_source_polygonizer(x, y, radius)
  self.sources[#self.sources + 1] = self:_new_wood_source(x, y, radius, p)
  self:_calculate_total_area()
  print("-----------------------------------------------------------------#sources")
  print(#self.sources)
  print(x, y, radius, p)
  self.wood = true
  return self, p
end

function bws:get_wood()
  return self.wood
end

function bws:newAnimation(image, width, height, duration)
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

function bws:getPos()
  return self.x, self.y
end

function bws:isSource()
	if #self.sources>0 then
		return true
	else
		return false
	end
end

function bws:force_polygonizer_update()
  self.level_map:update_source_polygonizer()
end

function bws:set_depletion_rate(r)
  self.depletion_rate = r
end

function bws:set_update_rate(r)
  self.polygonizer_update_rate = r
end

function bws:set_surface_threshold(thresh)
  self.surface_threshold = thresh
end

function bws:remove_wood_source(primitive)
  self.level_map.source_polygonizer:remove_primitive(primitive)
  for i=#self.sources,1,-1 do
    if self.sources[i].primitive == primitive then
      table.remove(self.sources, i)
      break
    end
  end
end

function bws:_new_wood_source(x, y, radius, primitive)
  local source = {}
  source.x, source.y = x, y
  source.radius = radius
  source.starting_radius = radius
  source.primitive = primitive
  
  return source
end

-- for fairness when attaching boids to a wood source
function bws:_shuffle_wood_sources()
  for i=1,#self.sources do
    local r = math.random(1,#self.sources)
    self.sources[r], self.sources[i] = self.sources[i], self.sources[r]
  end
end

function bws:_calculate_total_area()
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

function bws:mousepressed(kx, ky, button)

end

function bws:setFlock(flock)
	self.flock = flock
end

function bws:_update_area(dt)
  local sources = self.sources
  local bhash = self.boid_hash
  local objects = self.collision_table
  table.clear_hash(bhash)
  if self.flock and sources[1] then
    local s = sources[1]
    local r = s.radius
	local newR = r + 50
    table.clear(objects)
		self.flock:get_boids_in_radius(s.x, s.y, newR, objects)
		local count = 0
		if #objects>0 then
			for i=1,#objects do
			  if not bhash[objects[i]] and objects[i].woodGrab<101 and objects[i].needHome==true then
				count = count + 1
				bhash[objects[i]] = true
				objects[i]:grabWood(self.depletion_rate * dt)
				objects[i]:set_emote("question")
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
		self:force_polygonizer_update()
		self.treeParent:resetWood() -- il faut supprimer dans la maptree la woorssource sinon loiseau continue de chercher
		self.wood = false
	end
	
	--animationExtend.currentTime = animationExtend.currentTime + dt
	--if animationExtend.currentTime >= animationExtend.duration then
	--	self.animationExtend.currentTime = animationExtend.currentTime - animationExtend.duration
	--end
	
	
  end
end

function bws:_update_polygonizer()
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
function bws:update(dt)
  self:_shuffle_wood_sources()
  self:_update_area(dt)
  self:_calculate_total_area()
  self:_update_polygonizer()    
end

------------------------------------------------------------------------------
function bws:draw(x, y)
  --if not self.debug then return end
  local sources = self.sources
  local posx,posy = self.x,self.y
  for i=1,#sources do
    local s = sources[i]
    lg.setColor(255, 0, 0, 255)
    --lg.circle("line", x, y, s.radius)
    
    local sr = s.starting_radius
    local r = s.radius
    local pct = math.floor(((r * r) / (sr * sr)) * 100)
    --lg.print(pct.."%", x, y)
	lg.setColor(255, 255, 255, 255)
	--love.graphics.draw(woodGraphic, x, y)
	
	local animationExtend = self.animationExtend
	local spriteNum = math.floor(animationExtend.currentTime / animationExtend.duration * #animationExtend.quads) + 1
	love.graphics.draw(animationExtend.spriteSheet, animationExtend.quads[spriteNum], x, y)
	
  end
  
end

return bws















