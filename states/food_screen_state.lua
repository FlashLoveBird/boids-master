local food_screen_state = state:new()
food_screen_state.label = 'food_screen_state'
local state = food_screen_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_screen_state.keypressed(key)
  if key == "return" then
    BOIDS:load_next_state()
  end
end
function food_screen_state.keyreleased(key)
end
function food_screen_state.mousepressed(x, y, button)
end
function food_screen_state.mousereleased(x, y, button)
end
function food_screen_state.wheelmoved(x, y)
end

function food_screen_state.escape()
love.event.quit() 
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_screen_state.load(level)
  lg.setBackgroundColor(255, 255, 255, 255)
  --love.window.setFullscreen(true, "desktop")
  title = lg.newImage("images/ui/intro.png")
  
  
  lw.setFullscreen(true)
  local width = lg.getWidth()
  local height = lg.getHeight()
  --newLightWorld:Resize(width, height)
  --state.resize(width, height)
  FULLSCREEN = 1
  
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_screen_state.update(dt)

end
  

--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_screen_state.draw()
  local width, height = 1024, 768
  local xpad = 100
  local ypad = 60

  local x = 0.5 * SCR_WIDTH - 0.5 * width + xpad
  local y = 0.5 * SCR_HEIGHT - 0.5 * height + ypad

  lg.setFont(FONTS.rubik)
  lg.setColor(255, 255, 255, 255)
  lg.print("Paper life", x, y)
  
  lg.draw(title, x, y)
  
end

return food_screen_state












