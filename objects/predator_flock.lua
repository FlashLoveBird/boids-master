
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- flock object - a flock of boids in 3d space
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local pfk = {}
pfk.table = 'pfk'
pfk.debug = false
pfk.level = nil
pfk.bbox = nil
pfk.temp_collision_bbox = nil
pfk.free_boids = nil
pfk.active_boids = nil
pfk.collider_cell_width = 150
pfk.collider_cell_height = 150
pfk.draw_boids = nil

pfk.user_interface = nil

pfk.num_initial_boids = 1000
pfk.gradient = require("gradients/named/greenyellow")

local pfk_mt = { __index = pfk }
function pfk:new(level, x, y, width, height, depth)
  local pfk = setmetatable({}, pfk_mt)
  pfk.level = level
  
  pfk:_init_bbox(x, y, width, height, depth)
  pfk:_init_boids()
  pfk:_init_collider()
  
  pfk.user_interface = predator_flock_interface:new(level, pfk)
  pfk.draw_boids = {}
  
  return pfk
end

function pfk:keypressed(key)
  self.user_interface:keypressed(key)
end
function pfk:keyreleased(key)
  self.user_interface:keyreleased(key)
end
function pfk:mousepressed(x, y, button)
  self.user_interface:mousepressed(x, y, button)
end
function pfk:mousereleased(x, y, button)
  self.user_interface:mousereleased(x, y, button)
end

function pfk:_init_boids()
  self.free_boids = {}
  self.active_boids = {}
  for i=1,self.num_initial_boids do
    self.free_boids[i] = predator:new(self.level)
  end
end

function pfk:_init_bbox(x, y, width, height, depth)
  self.bbox = bbox:new(x, y, width, height)
  self.bbox.depth = depth
  self.temp_collision_bbox = bbox:new(0, 0, 0, 0)

end

function pfk:_init_collider()
  local x, y, width, height = self.bbox:get_dimensions()
  local cw, ch = self.collider_cell_width, self.collider_cell_height
  self.collider = collider:new(self.level, x, y, width, height, cw, ch)
end

function pfk:contains_point(x, y, z)
  return self.bbox:contains_coordinate(x, y) and z >= 0 and z <= self.bbox.depth
end

function pfk:get_bbox()
  return self.bbox
end

function pfk:set_gradient(grad_table)
  self.gradient = grad_table
end

function pfk:set_camera_tracking_off()
  self.user_interface:set_camera_tracking_off()
end

function pfk:set_camera_tracking_on()
  self.user_interface:set_camera_tracking_on()
end

function pfk:add_boid(x, y, z, dirx, diry, dirz, gradient)
  z = z or 0
  if not x or not y then
    print("ERROR in flock:add_boid - no position specified")
    return
  end
  
  local new_boid = nil
  if #self.free_boids > 0 then
    new_boid = self.free_boids[#self.free_boids]
    self.free_boids[#self.free_boids] = nil
  else
    new_boid = predator:new(self.level)
  end
  new_boid:init(self, x, y, z, dirx, diry, dirz)
  if gradient then
    new_boid:set_gradient(gradient)
  else
    new_boid:set_gradient(self.gradient)
  end
  self.active_boids[#self.active_boids + 1] = new_boid
  
  return new_boid
end

function pfk:remove_boid(boid)
  local active = self.active_boids
  for i=#active,1,-1 do
    if active[i] == boid then
      table.remove(active, i)
      self.free_boids[#self.free_boids + 1] = boid
      boid:destroy()
      break
    end
  end
end

function pfk:get_active_boids()
  return self.active_boids
end

function pfk:get_boids_in_radius(x, y, r, storage)
  local bbox = self.temp_collision_bbox
  bbox.x, bbox.y = x - r, y - r
  bbox.width, bbox.height = 2 * r, 2 * r
  
  self.collider:get_objects_at_bbox(bbox, storage)
  for i=#storage,1,-1 do
    local boid = storage[i]
    local p = boid.position
    local dx, dy, dz = p.x - x, p.y - y
    if dx*dx + dy*dy > r * r then
      table.remove(storage, i)
    end
  end
  
end

function pfk:get_boids_in_sphere(x, y, z, r, storage)
  local bbox = self.temp_collision_bbox
  bbox.x, bbox.y = x - r, y - r
  bbox.width, bbox.height = 2 * r, 2 * r
  
  self.collider:get_objects_at_bbox(bbox, storage)
  for i=#storage,1,-1 do
    local boid = storage[i]
    local p = boid.position
    local dx, dy, dz = p.x - x, p.y - y, p.z - z
    if dx*dx + dy*dy + dz*dz > r * r then
      table.remove(storage, i)
    end
  end
  
end

function pfk:get_boids_in_bbox(bbox, storage)
  self.collider:get_objects_at_bbox(bbox, storage)
end

function pfk:get_collider()
  return self.collider
end


------------------------------------------------------------------------------
function pfk:_update_boids(dt)
  for i=1,#self.active_boids do
    self.active_boids[i]:update(dt)
  end
  
  -- find boids on screen and sort by depth for correct draw order
  local padx, pady = 200, 500
  local w, h = SCR_WIDTH + 2*padx, SCR_HEIGHT + 2*pady
  local cx, cy = self.level:get_camera():get_viewport()
  local bbox = self.temp_collision_bbox
  bbox.x, bbox.y = cx - padx, cy - pady
  bbox.width, bbox.height = w, h
  local objects = self.draw_boids
  table.clear(objects)
  self.collider:get_objects_at_bbox(bbox, objects)
  
  table.sort(objects, function(a, b) 
                                  return a.position.z < b.position.z
                                end)

end

function pfk:update(dt)
  self.user_interface:update(dt)

  self:_update_boids(dt)
  self.collider:update(dt)
end

------------------------------------------------------------------------------
function pfk:draw()
  for i=1,#self.draw_boids do
    self.draw_boids[i]:draw_shadow()
  end
  for i=1,#self.draw_boids do
    self.draw_boids[i]:draw()
  end

  self.user_interface:draw()
  
  if not self.debug then return end
  
  lg.setColor(255, 0, 0, 255)
  self.bbox:draw()
  
  self.collider.debug = self.debug
  --self.collider:draw()
  
end

return pfk



























