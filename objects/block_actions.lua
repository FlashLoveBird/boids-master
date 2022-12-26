
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- block_actions object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local block_actions = {}
block_actions.table = 'block_actions'
block_actions.pos = nil
block_actions.x = 0
block_actions.y = 0

local block_actions_mt = { __index = block_actions }
function block_actions:new(level)
  
  return block_actions
end

function block_actions:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function block_actions:get_pos()
  return self.pos
end

function block_actions:get_posX()
  return self.pos.x
end

function block_actions:get_posY()
  return self.pos.y
end

function block_actions:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx>x-20 and mx<x+20 and my>y-20 and my<y+20 then
		self.drawInfo = true
	end
end

------------------------------------------------------------------------------
function block_actions:draw(mx,my)
		
end

return block_actions



