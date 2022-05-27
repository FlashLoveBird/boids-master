vector3 = require("vector3")

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_emitter object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local pe = {}
pe.table = 'pe'
pe.debug  = true
pe.position = nil
pe.direction = nil
pe.radius = nil
pe.predator_flock = nil
pe.level = nil
pe.rate = 1
pe.boid_limit = 400
pe.boid_count = 0
pe.dead_zone_bbox = nil
pe.active_boids = nil
pe.waypoint = nil
pe.is_waypoint_set = false
pe.is_active = false
pe.is_random_direction = false
pe.gradient = nil

local pe_mt = { __index = pe }
function pe:new(level, predator_flock, x, y, z, dirx, diry, dirz, radius)
  local pe = setmetatable({}, pe_mt)
  pe.predator_flock = predator_flock
  pe. level = level
  
  pe.position = {}
  pe.direction = {}
  pe.waypoint = {}
  pe.radius = radius
  vector3.set(pe.position, x, y, z)
  vector3.set(pe.direction, dirx, diry, dirz)
  vector3.normalize(pe.direction)
  
  pe.active_boids = {}
  
  local t = poisson_interval(self.rate)
  pe.spawn_timer = timer:new(level:get_master_timer(), t)
  pe.spawn_timer:start()
  
  pe.dead_zone_bbox = bbox:new(0, 0, 0, 0)
  
  return pe
end

function pe:reset()
  self.is_active = false
  for i=#self.active_boids,1,-1 do
    local b = self.active_boids[i]
    self.active_boids[i] = nil
    self:_destroy_boid(b)
  end
  self.boid_count = 0
end

function pe:set_position(x, y, z)
  vector3.set(self.position, x, y, z)
end

function pe:set_direction(dx, dy, dz)
  vector3.set(self.direction, dx, dy, dz)
  vector3.normalize(self.direction)
end

function pe:set_gradient(grad_table)
  self.gradient = grad_table
end

function pe:set_random_direction_on()
  self.is_random_direction = true
end

function pe:set_random_direction_off()
  self.is_random_direction = false
end

function pe:set_emission_rate(r)
  self.rate = r
  local t = poisson_interval(self.rate)
  self.spawn_timer:set_length(t)
  self.spawn_timer:start()
end

function pe:stop_emission()
  self.is_active = false
end

function pe:start_emission()
  self.is_active = true
end

function pe:set_boid_limit(n)
 self.boid_limit = n
end

function pe:set_dead_zone(x, y, width, height)
  local b = self.dead_zone_bbox
  b:set(x, y, width, height)
end

function pe:set_waypoint(x, y, z)
  if not x or not y then
    self.is_waypoint_set = false
  end

  z = z or self.position.z
  vector3.set(self.waypoint, x, y, z)
  
  self.is_waypoint_set = true
end

function pe:_get_spawn_point()
  -- random point on plane defined by direction within radius
  local x, y, z = self.position.x, self.position.y, self.position.z
  local angle = math.random() * 2 * math.pi
  local r = math.random() * self.radius
  local n = self.direction
  local v1x, v1y, v1z = -n.y, n.x, 0
  local inv = 1 / math.sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
  v1x, v1y, v1z = v1x * inv, v1y * inv, v1z * inv
  local v2x, v2y, v2z = vector3_cross(n.x, n.y, n.z, v1x, v1y, v1z)
  local rx = x + r*math.cos(angle)*v1x + r*math.sin(angle)*v2x
  local ry = y + r*math.cos(angle)*v1y + r*math.sin(angle)*v2y
  local rz = z + r*math.cos(angle)*v1z + r*math.sin(angle)*v2z
  
  return rx, ry, rz
end

function pe:_emit_boid()
  if not self.is_active then return end
  if self.boid_count >= self.boid_limit then return end

  local x, y, z = self:_get_spawn_point()
  local dir = self.direction
  local predator
  if self.is_random_direction then
    local dx, dy, dz = random_direction3()
    predator = self.predator_flock:add_boid(x, y, z, dx, dy, dz, self.gradient)
  else
    predator = self.predator_flock:add_boid(x, y, z, dir.x, dir.y, dir.z, self.gradient)
  end
  self.active_boids[#self.active_boids + 1] = predator
  
  if self.is_waypoint_set then
    predator:set_waypoint(self.waypoint.x, self.waypoint.y, self.waypoint.z)
  end
  
  self.boid_count = #self.active_boids
end

function pe:_destroy_boid(b)
  self.predator_flock:remove_boid(b)
end

------------------------------------------------------------------------------
function pe:update(dt)
  local active = self.active_boids
  local bbox = self.dead_zone_bbox
  for i=#active,1,-1 do
    local b = active[i]
    --if bbox:contains_coordinate(b.position.x, b.position.y) then
      --table.remove(active, i)
     -- self:_destroy_boid(b)
      --self.boid_count = #active
    --end
  end

  if self.spawn_timer:isfinished() then
    self:_emit_boid()
    local t = poisson_interval(self.rate)
    self.spawn_timer:set_length(t)
    self.spawn_timer:start()
  end
  
end

------------------------------------------------------------------------------
function pe:draw()
  if not self.debug then return end
  
  local x, y = self.position.x, self.position.y
  lg.setColor(255, 0, 0, 255)
  lg.setPointSize(5)
  lg.points(x, y)
  
  local len = 100
  local dir = self.direction
  local x2, y2 = x + len * dir.x, y + len * dir.y
  lg.setColor(0, 0, 0, 255)
  lg.setLineWidth(2)
  lg.line(x, y, x2, y2)
  lg.circle("line", x, y, len)
  
  -- points around radius
  local r = self.radius
  local n = self.direction
  local v1x, v1y, v1z = -n.y, n.x, 0
  local len = math.sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
  v1x, v1y, v1z = v1x/len, v1y/len, v1z/len
  local v2x, v2y, v2z = vector3_cross(n.x, n.y, n.z, v1x, v1y, v1z)
  
  local m = 40
  local inc = 2 * math.pi / m
  lg.setPointSize(4)
  for i=1,m do
    local angle = (i-1) * inc
    local rx = x + r*math.cos(angle)*v1x + r*math.sin(angle)*v2x
    local ry = y + r*math.cos(angle)*v1y + r*math.sin(angle)*v2y
    lg.setColor(0, 0, 255, 255)
    lg.points(rx, ry)
  end
  
  lg.setColor(255, 0, 0, 255)
  self.dead_zone_bbox:draw()
  
  lg.setColor(0, 0, 0, 255)
  lg.print(self.boid_count.." / "..self.boid_limit, x, y)
  
end

return pe
















