
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- tree object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local tree = {}
tree.table = 'tree'
tree.pos = nil
tree.target = nil
tree.level = nil
tree.level_map = nil
tree.flock = nil
tree.sources = nil
tree.center = nil
tree.posX = nil
tree.posY = nil
tree.collider = nil
tree.map_point = nil
tree.collision_table = nil
tree.numEmits = nil
tree.drawInfo = false
tree.x = 0
tree.y = 0

local tree_mt = { __index = tree }
function tree:new(level, numEmits)
  local tree = setmetatable({}, tree_mt)
  tree.level_map = level:get_level_map()
  tree.level = level
  tree.numEmits = numEmits
  treeGraphic = love.graphics.newImage("images/env/tree.png")
  treeGraphicSelect = love.graphics.newImage("images/env/treeSelect.png")
  return tree
end

function tree:_update_map_point(dt)
  local x, y = self.pos.x , self.pos.y
  self.map_point:set_position_coordinates(x, y)
  self.map_point:update(dt)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, 
        collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile)
  end
end

function tree:_handle_tile_collision(normal, point, offset, tile)
  --print("mescouilles")
end

------------------------------------------------------------------------------
function tree:update(dt)
end

function tree:setNumEmits(num)
	self.numEmits = self.numEmits + num
end

function tree:getNumEmits()
local num = self.numEmits
	return num
end

function tree:set_target(pos, immediate)
  if immediate then
    self.target:set_position(pos)
    self:set_position(pos)
  end
  self.target:set_target(pos)
end

function tree:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function tree:get_pos()
  return self.pos
end

function tree:get_posX()
  return self.pos.x
end

function tree:get_posY()
  return self.pos.y
end

function tree:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx>x-20 and mx<x+20 and my>y-20 and my<y+20 then
		self.drawInfo = true
	end
end

------------------------------------------------------------------------------
function tree:draw(mx,my)
	local level = self.level
	local x, y = 0,0--level:get_camera():get_viewport()
	local mpos = level:get_mouse():get_position()
	local mxx, myy = x + mpos.x, y + mpos.y
	local nx, ny, f = level.level_map:get_field_vector_at_position({x=mx, y=my})
	local drawInfo = self.drawInfo
	
	if mxx>mx-50 and mxx<mx+50 and myy>my-50 and myy<my+50 then
		love.graphics.draw(treeGraphicSelect, mx-64, my-64)
	else
		love.graphics.draw(treeGraphic, mx-64, my-64)
	end
	
	if drawInfo then
		love.graphics.draw(treeGraphic, mx, my)
	end
	
end

return tree



