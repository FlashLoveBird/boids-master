
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- mouse_input object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local mouse_input = {}
mouse_input.table = MOUSE_INPUT
mouse_input.scale = 1.5                -- factor to scale mouse input by
mouse_input.reference_pos = nil
mouse_input.screen_pos = nil

mouse_input.x = 0
mouse_input.y = 0
mouse_input.width = SCR_WIDTH
mouse_input.height = SCR_HEIGHT

mouse_input.left_pressed = false
mouse_input.left_press_timer = nil
mouse_input.color = 255
mouse_input.color1 = 255
mouse_input.color2 = 255
mouse_input.color3 = 1
local mouseBoid = nil
local mouseTree = nil
local mouseBush = nil
local mousePred = nil
local mouseInput = nil
local mouseImg = nil
local mouseImgClick = nil
local mouseImgClickInstant = nil
mouse_input.click = nil
mouse_input.clickInstant = nil

local mouse_input_mt = { __index = mouse_input }
function mouse_input:new(level)
  local pos = vector2:new(0.5*SCR_WIDTH, 0.5*SCR_HEIGHT)
  love.mouse.setPosition(pos:get_vals())
  local width, height = SCR_WIDTH, SCR_HEIGHT
  
  local master_timer = MASTER_TIMER
  if level then
    master_timer = level:get_master_timer()
  end
  
  local press_timer = timer:new(master_timer)
  
  local scr_pos = vector2:new(pos.x, pos.y)
  local ref_pos = vector2:new(pos.x, pos.y)
  
  mouseBoid = love.graphics.newImage("images/mouse/bird-mouse.png")
  mouseTree = love.graphics.newImage("images/mouse/bigTree-mouse.png")
  mousePred = love.graphics.newImage("images/mouse/predator-mouse.png")
  mouseBush = love.graphics.newImage("images/mouse/bigBush-mouse.png")
  mouseImg = love.graphics.newImage("images/mouse/mouse.png")
  mouseImgClick = love.graphics.newImage("images/mouse/mouse-click.png")
  mouseImgClickInstant = love.graphics.newImage("images/mouse/mouse-click-instant.png")
  
  return setmetatable({ reference_pos = ref_pos,
                        screen_pos = scr_pos,
                        width = width,
                        height = height,
                        left_press_timer = press_timer}, mouse_input_mt)
end

function mouse_input:init()
  self.width = SCR_WIDTH
  self.height = SCR_HEIGHT
  self.reference_pos = vector2:new(0.5*SCR_WIDTH, 0.5*SCR_HEIGHT)
  self.screen_pos = vector2:new(0.5*SCR_WIDTH, 0.5*SCR_HEIGHT)
end

function mouse_input:setClick(bool)
  self.click = bool
end

function mouse_input:set_input(param)  
	self.mouseInput = param
end

function mouse_input:setColor(color, color1, color2, color3)
	self.color=color
	self.color1=color1
	self.color2=color2
	self.color3=color3
end

function mouse_input:mousepressed(x, y, button)
  --if button == 'l' then
    self.left_pressed = true
    self.left_press_timer:start()
  --end
end

function mouse_input:mousereleased(x, y, button)
  self.left_pressed = false
  self.left_press_timer:reset()
end

function mouse_input:set_sensitivity(scale_factor)
  self.scale = scale_factor
end


function mouse_input:set_boundary(x, y, width, height)
  self.x, self.y, self.width, self.height = x, y, width, height
end

--[[
function mouse_input:get_position()
  return self.screen_pos
end
]]--

function mouse_input:get_position()
  self.screen_pos.x, self.screen_pos.y = love.mouse.getPosition()
  return self.screen_pos
end

--[[
function mouse_input:get_coordinates()
  return self.screen_pos.x, self.screen_pos.y
end
]]--

function mouse_input:get_coordinates()
  return love.mouse.getPosition()
end

-- press time for left button
function mouse_input:get_left_time_pressed()
  return self.left_press_timer:time_elapsed()
end

--[[
function mouse_input:get_vals()
  return self.screen_pos.x, self.screen_pos.y
end
]]--

function mouse_input:get_vals()
  return love.mouse.getPosition()
end


function mouse_input:set_position(pos)
	self.screen_pos:clone(pos)
end

function mouse_input:was_left_pressed()
  local result = self.left_pressed
  self.left_pressed = false
  return result
end

function mouse_input:is_down(button)
  return love.mouse.isDown(button)
end

------------------------------------------------------------------------------
--[[
function mouse_input:update(dt)
  -- scale diffence between reference and new position
  local last_pos = self.reference_pos
  local mx, my = love.mouse.getPosition()
  local spos = self.screen_pos
  
  spos.x = spos.x + (mx - last_pos.x) * self.scale
  spos.y = spos.y + (my - last_pos.y) * self.scale
  love.mouse.setPosition(self.reference_pos:get_vals())
  
  -- limit screen position to within boundary
  local x, y = self.screen_pos:get_vals()
  if     x < self.x then 
    self.screen_pos.x = self.x 
  elseif x > self.x + self.width then 
    self.screen_pos.x = self.x + self.width 
  end
  if     y < self.y then 
    self.screen_pos.y = self.y 
  elseif y > self.y + self.height then 
    self.screen_pos.y = self.y + self.height
  end
  
end
]]--

function mouse_input:update(dt)
  
end

------------------------------------------------------------------------------
--[[
function mouse_input:draw()
  lg.setColor(0, 0, 0, 255)
  lg.setPointSize(3)
  local x, y = self.screen_pos:get_vals()
  local len = 10
  lg.setLineWidth(2)
  lg.line(x, y, x, y + len)
  lg.line(x, y, x + 0.7 * len, y + len - 3)
  
end
]]--

function mouse_input:draw()
  lg.setColor(self.color, self.color1, self.color2, self.color3)
  lg.setPointSize(3)
  local mouseInput = self.mouseInput
  local left_pressed = self.left_pressed
  local x, y = love.mouse.getPosition()
  if mouseInput == nil then
      lg.setColor(self.color, self.color1, self.color2, self.color3)
	  --local len = 10
	  --lg.setLineWidth(2)
	  --lg.line(x, y, x, y + len)
	  --lg.line(x, y, x + 0.7 * len, y + len - 3)
	  if self.click then
	    lg.draw(mouseImgClick, x-15, y-10)
	  elseif left_pressed == false then
		lg.draw(mouseImg, x-15, y-10)
	  else
		lg.draw(mouseImgClickInstant, x-15, y-10)
	  end
  elseif mouseInput =="bird" then
	lg.draw(mouseBoid, x-15, y-10)
  elseif mouseInput =="tree" then
	lg.draw(mouseTree, x-100, y-180)
  elseif mouseInput =="bush" then
	lg.draw(mouseBush, x-100, y-80)
  elseif mouseInput =="pred" then
	lg.draw(mousePred, x-100, y-80)
  end
end

return mouse_input



