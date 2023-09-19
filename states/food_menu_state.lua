local food_menu_state = state:new()
food_menu_state.label = 'food_menu_state'
local state = food_menu_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.keypressed(key)

end
function food_menu_state.keyreleased(key)
end
function food_menu_state.mousepressed(x, y, button)
print("b_________________0")
print(food_menu_state.toggle_button)
local x = love.mouse.getX()
local y = love.mouse.getY()

for i=1,#state.buttons do
    local b = state.buttons[i]
    if b.bbox:contains_coordinate(x, y) then
		if b.text == "play" then
			BOIDS:load_next_state()
		end
    end
end

function food_menu_state.toggle_button(b)
  --local boids = state.flock.active_boids
  print("b_________________")
  myText = b.text
  local width, height = 1024, 768
  local xpad = 0
  local ypad = 60
  local xX = 0.5 * SCR_WIDTH - 0.25 * SCR_WIDTH
  local yY = 0.5 * SCR_HEIGHT - 0.25 * SCR_HEIGHT
  --for i=1,#boids do
	myText = b.text
    --local boid = boids[i]
    --if     b.toggle == false then
			print(b.text)
      if b.text == "-bush" then
        print("change menu")
		lw.setFullscreen(false)
      elseif b.text == "+bush" then
        SCR_WIDTH = width
		SCR_HEIGHT = height
      elseif b.text == "-nid" then
        nbNids = nbNids - 1
      elseif b.text == "+nid" then
        nbNids = nbNids + 1
      elseif b.text == "-nidPred" then
        nbNidsPred = nbNidsPred - 1
      elseif b.text == "+nidPred" then
        nbNidsPred = nbNidsPred + 1
      elseif b.text == "play" then
        BOIDS:load_next_state()
      end
    --elseif b.toggle == true then
      --if     b.x == xX then
      --  state.selectItem = 1
	  --end
    --end
 -- end
  b.toggle = not b.toggle
end


end
function food_menu_state.mousereleased(x, y, button)
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.load(level)
  lg.setBackgroundColor(225, 125, 214, 255)
  
  local xX = 0.5 * SCR_WIDTH
  local yY = 0
  
  
  state.buttons = {}
  state.buttons[1] = {text="play", x = xX-150, y = yY+300, toggle = false, 
                      bbox = bbox:new(xX-150, yY+300, 300, 300)}
  state.buttons[2] = {text="parametre", x = xX-500, y = yY+700, toggle = false, 
                      bbox = bbox:new(xX-500, yY+700, 100, 100)}
  state.buttons[3] = {text="credits", x = xX+350, y = yY+700, toggle = false, 
                      bbox = bbox:new(xX+350, yY+700, 200, 100)}
  
  play = love.graphics.newImage("images/ui/play.png")
  parametre = love.graphics.newImage("images/ui/parametre.png")
  credits = love.graphics.newImage("images/ui/credits-bubble.png")
  
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.update(dt)

end
  

--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.draw()

  local x = 0.5 * SCR_WIDTH
  local y = 0
  
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(play, x-150, y+300)
  love.graphics.draw(parametre, x-500, y+700)
  love.graphics.draw(credits, x+350, y+700)
  
  lg.setColor(0, 0, 0, 255)
  for i=1, 3 do
	--love.graphics.rectangle( "fill", state.buttons[i].x, state.buttons[i].y, 200, 200)
  end
  
end

return food_menu_state












