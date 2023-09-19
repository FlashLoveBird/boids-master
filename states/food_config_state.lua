local food_config_state = state:new()
food_config_state.label = 'food_config_state'
local state = food_config_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.keypressed(key)

end
function food_config_state.keyreleased(key)
end
function food_config_state.mousepressed(x, y, button)

local x = love.mouse.getX()
local y = love.mouse.getY()

for i=1,#state.buttons do
    local b = state.buttons[i]
    if b.bbox:contains_coordinate(x, y) then
      if b.text == "GO" then
        BOIDS:load_next_state()
      end
    end
end

function food_config_state.toggle_button(b)
  --local boids = state.flock.active_boids
  myText = b.text
  local width, height = 1024, 768
  local xpad = 100
  local ypad = 60
  local xX = 0.5 * SCR_WIDTH - 0.5 * width + xpad
  local yY = 0.5 * SCR_HEIGHT - 0.5 * height + ypad + 200
  --for i=1,#boids do
	myText = b.text
    --local boid = boids[i]
    --if     b.toggle == false then
			print(b.text)
      if b.text == "-bush" then
        nbBush = nbBush - 1
      elseif b.text == "+bush" then
        nbBush = nbBush + 1
      elseif b.text == "-nid" then
        nbNids = nbNids - 1
      elseif b.text == "+nid" then
        nbNids = nbNids + 1
      elseif b.text == "-nidPred" then
        nbNidsPred = nbNidsPred - 1
      elseif b.text == "+nidPred" then
        nbNidsPred = nbNidsPred + 1
      elseif b.text == "GO" then
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
function food_config_state.mousereleased(x, y, button)
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.load(level)
  lg.setBackgroundColor(225, 125, 214, 255)
  local width, height = 1024, 768
  local xpad = 100
  local ypad = 60
  
  local xX = 0.5 * SCR_WIDTH - 0.25 * SCR_WIDTH
  local yY = 0.5 * SCR_HEIGHT - 0.25 * SCR_HEIGHT
  
  
  state.buttons = {}
  state.buttons[1] = {text="-bush", x = xX+150-200, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150-200, yY, 100, 100)}
  state.buttons[2] = {text="+bush", x = xX+150*2-200, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150*2-200, yY, 100, 100)}
  state.buttons[3] = {text="-nid", x = xX+150*3, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150*3, yY, 100, 100)}
  state.buttons[4] = {text="+nid", x = xX+150*4, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150*4, yY, 100, 100)}
  state.buttons[5] = {text="-nidPred", x = xX+150*5+200, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150*5+200, yY, 100, 100)}
  state.buttons[6] = {text="+nidPred", x = xX+150*6+200, y = yY, toggle = false, 
                      bbox = bbox:new(xX+150*6+200, yY, 100, 100)}
  state.buttons[7] = {text="GO", x = xX+525, y = yY+200, toggle = false, 
						bbox = bbox:new(xX+525, yY+200, 100, 100)}
  
  button = love.graphics.newImage("images/Jungle/upgrade/btn.png")
  buttonpress = love.graphics.newImage("images/Jungle/upgrade/btn-push.png")
  
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.update(dt)

end
  

--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.draw()
  local width, height = 1024, 768
  local xpad = 100
  local ypad = 60

  local x = 0.5 * SCR_WIDTH - 0.25 * SCR_WIDTH
  local y = 0.5 * SCR_HEIGHT - 0.25 * SCR_HEIGHT

  lg.setFont(FONTS.appleMedium)
  lg.setColor(251, 121, 0, 255)
  lg.print("Difficulté", x, y)
  
    -- intruction text
  lg.setColor(0, 0, 0, 255)
  lg.setFont(FONTS.muliBig)
  lg.print("Nb de bush", x-100, y+300)
  lg.print(tostring(nbBush), x-35, y+500)
  lg.print("Nb de nids", x+400, y+300)
  lg.print(tostring(nbNids), x+465, y+500)
  lg.print("Nb de nids de predateurs", x+800, y+300)
  lg.print(tostring(nbNidsPred), x+965, y+500)
  
  local ystep = 200
  
  -- draw buttons
  lg.setFont(FONTS.appleMedium)
  for i=1,#state.buttons do
    local b = state.buttons[i]
	lg.setColor(255, 255, 255, 255)
	local newX = 0
	local newY = 0
	if i==1 then
		newX = x - 200
	elseif i==2 then
		newX = x - 200
	elseif i==3 then
		newX = x
	elseif i==4 then
		newX = x
	elseif i==5 then
		newX = x + 200
	elseif i==6 then
		newX = x + 200
	elseif i==7 then
		newX = x - 525
		y = y + 200		
	end
	if b.toggle then
      lg.draw(buttonpress, newX+i*150, y)
    else
      lg.draw(button, newX+i*150, y)
    end
	--lg.rectangle("fill", 200+i*60,920, 50,50)
  end
  
end

return food_config_state












