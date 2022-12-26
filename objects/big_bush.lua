
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- big_bush object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local big_bush = {}
big_bush.table = 'big_bush'
big_bush.pos = nil
big_bush.target = nil
big_bush.level = nil
big_bush.level_map = nil
big_bush.flock = nil
big_bush.sources = nil
big_bush.center = nil
big_bush.posX = nil
big_bush.posY = nil
big_bush.collider = nil
big_bush.map_point = nil
big_bush.collision_table = nil
big_bush.numEmits = 0
big_bush.drawInfo = false
big_bush.x = 0
big_bush.y = 0
big_bush.state = false
big_bush.emmiter = nil
big_bush.name = 1
big_bush.graphic = nil

local big_bush_mt = { __index = big_bush }
function big_bush:new(level)
  local big_bush = setmetatable({}, big_bush_mt)
  big_bush.level_map = level:get_level_map()
  big_bush.level = level
  big_bush.graphic = math.random(1,2)
  plantGraphic = love.graphics.newImage("images/env/plant3-2x2.png")
  plantGraphic2 = love.graphics.newImage("images/env/plant4-2x2.png")
  plantGraphic3 = love.graphics.newImage("images/env/plant3-2x2.png")
  big_bush.name = math.random(0,50)
  return big_bush
end

function big_bush:_update_map_point(dt)
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

function big_bush:_handle_tile_collision(normal, point, offset, tile)
  
end

------------------------------------------------------------------------------
function big_bush:update(dt)
end

function big_bush:setNumEmits(num)
	self.numEmits = self.numEmits + num
end

function big_bush:getNumEmits()
local num = self.numEmits
	return num
end

function big_bush:getState()
	return self.state
end

function big_bush:add(emit)
	self.emmiter = emit
end

function big_bush:getEmit()
	return self.emmiter
end

function big_bush:getTree()
	return self
end

function big_bush:setState(bol)
	self.state = bol
end

function big_bush:set_target(pos, immediate)
  if immediate then
    self.target:set_position(pos)
    self:set_position(pos)
  end
  self.target:set_target(pos)
end

function big_bush:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function big_bush:get_pos()
  return self.pos
end

function big_bush:get_posX()
  return self.pos.x
end

function big_bush:get_posY()
  return self.pos.y
end

function big_bush:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx>x-20 and mx<x+20 and my>y-20 and my<y+20 then
		self.drawInfo = true
	end
end

------------------------------------------------------------------------------
function big_bush:draw(mx,my)
	local level = self.level
	local x, y = 0,0--level:get_camera():get_viewport()
	local mpos = level:get_mouse():get_position()
	local mxx, myy = x + mpos.x, y + mpos.y
	local nx, ny, f = level.level_map:get_field_vector_at_position({x=mx, y=my})
	
	lg.setColor(255, 255, 255, 255)
	if self.graphic==1 then
		love.graphics.draw(plantGraphic, mx-50, my-64)
	elseif self.graphic==2 then
		love.graphics.draw(plantGraphic2, mx-50, my-64)
	end
	--love.graphics.rectangle("fill", mx,my, 32,32)
	
	lg.print(self.graphic, mx, my-100)
	
	if drawInfo then
		
	end
	
end

return big_bush



