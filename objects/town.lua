
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_town object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local tw = {}
tw.table = 'tw'
tw.debug = false
tw.level = nil
tw.level_map = nil
tw.flock = nil
tw.sources = nil
tw.depletion_rate = 300
tw.surface_threshold = 0.5
tw.area = 0
tw.unit_area = TILE_WIDTH * TILE_HEIGHT
tw.area_changed = false
tw.boid_hash = nil
tw.collision_table = nil
tw.polygonizer_update_rate = 1.5   -- updates per second
tw.min_radius = 0
local startTime = os.time()
local endTime = startTime+10

local tw_mt = { __index = tw }
function tw:new(level, flock)
  local tw = setmetatable({}, tw_mt)
  tw.level = level
  tw.level_map = level:get_level_map()
  tw.flock = flock
  tw.sources = {}
  tw.boid_hash = {}
  tw.collision_table = {}
  tw.update_timer = timer:new(level:get_master_timer(), 1/tw.polygonizer_update_rate)
  tw.update_timer:start()
  townGraphic = love.graphics.newImage("images/3D/tentClosed.png")
  
  return tw
end

function tw:add_town(x, y, radius)
  local p = self.level_map:add_point_to_source_polygonizer(x, y, radius)
  self.sources[#self.sources + 1] = self:_new_town(x, y, radius, p)
  self:_calculate_total_area()
  return self
end

function tw:force_polygonizer_update()
  self.level_map:update_source_polygonizer()
end

function tw:set_depletion_rate(r)
  self.depletion_rate = r
end

function tw:set_update_rate(r)
  self.polygonizer_update_rate = r
end

function tw:getTree()
	return self
end

function tw:getEmit()
	return self
end

function tw:get_humans()
	return 0
end


function tw:add_human()
	
end

function tw:get_food()
return 0
end

function tw:remove_human()

end

function tw:set_surface_threshold(thresh)
  self.surface_threshold = thresh
end

function tw:mousepressed(mx, my, button)
	
end

function tw:remove_town(primitive)
  self.level_map.source_polygonizer:remove_primitive(primitive)
  for i=#self.sources,1,-1 do
    if self.sources[i].primitive == primitive then
      table.remove(self.sources, i)
      break
    end
  end
end

function tw:_new_town(x, y, radius, primitive)
  local source = {}
  source.x, source.y = x, y
  source.radius = radius
  source.starting_radius = radius
  source.primitive = primitive
  return source
end

-- for fairness when attaching boids to a food source
function tw:_shuffle_towns()
  for i=1,#self.sources do
    local r = math.random(1,#self.sources)
    self.sources[r], self.sources[i] = self.sources[i], self.sources[r]
  end
end

function tw:_calculate_total_area()
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

function tw:getType()
	return 5
end

function tw:getNumEmits()
	return 0
end

function tw:getNumboids()
	return 0
end

function tw:getState()
	return true
end

function tw:add_food()

end

function tw:try_egg()

end

function tw:add_wood()

end

function tw:add_water()

end

function tw:setFlock(flock)
	local level = self.level
	self.flock = flock
end

function tw:_update_area(dt)
  local sources = self.sources
  local bhash = self.boid_hash
  local objects = self.collision_table
  local flock = self.flock
  table.clear_hash(bhash)
  for i=#sources,1,-1 do
	local s = sources[i]
	local r = s.radius
	local newR = r + 20
	table.clear(objects)
	flock:get_boids_in_radius(s.x, s.y, newR, objects)
	local count = 0
	if #objects>0 then
		for i=1,#objects do
		  local randomNb = math.random(1,1000)
		  if not bhash[objects[i]] and randomNb == 1 then
			local dead = math.random(1,#objects)
			--flock:pan(objects[i],s.x,s.y)
		  elseif objects[i]:getObjectiv()~="goOut" and objects[i]:getObjectiv()~="goOnHomeWith" then
				local x, y, z = objects[i]:get_position()
				objects[i]:set_waypoint(x+math.random(-200,200), y+math.random(-200,200), math.random(50,1000),50,100)
				objects[i]:unObstacleMe()
				objects[i]:setObjectiv("goOut")
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

function tw:_update_polygonizer()
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
function tw:update(dt)
  self:_shuffle_towns()
  self:_update_area(dt)
  self:_calculate_total_area()
  self:_update_polygonizer()
end

------------------------------------------------------------------------------
function tw:draw()
  if not self.debug then return end
  
  local sources = self.sources
  for i=1,#sources do
    local s = sources[i]
    lg.setColor(255, 255, 255, 255)
    --lg.circle("line", s.x, s.y, s.radius)
	love.graphics.draw(townGraphic, s.x-50, s.y-50)
    
    local sr = s.starting_radius
    local r = s.radius
    local pct = math.floor(((r * r) / (sr * sr)) * 100)
    lg.print(pct.."%", s.x, s.y)
  end
  
end

return tw















