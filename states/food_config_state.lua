local food_config_state = state:new()
food_config_state.label = 'food_config_state'
local state = food_config_state

DIFFICULTY = "easy"

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
	   if b.text == "easy" then
	    DIFFICULTY = "easy"
        BOIDS:load_state("food_demo_load_state")
      elseif b.text == "moy" then
       DIFFICULTY = "moy"
	   BOIDS:load_state("food_demo_load_state")
      elseif b.text == "hard" then
        DIFFICULTY = "hard"
		BOIDS:load_state("food_demo_load_state")
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
      if b.text == "easy" then
        nbBush = nbBush - 1
      elseif b.text == "moy" then
        nbBush = nbBush + 1
      elseif b.text == "hard" then
        nbNids = nbNids - 1
      end
  
  b.toggle = not b.toggle
end
end
function food_config_state.mousereleased(x, y, button)
end

function food_config_state.resize(w, h, scale)

end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.load(level)
  local width, height = 1024, 768
  local xpad = 100
  local ypad = 60
  
  local xX = 0.5 * SCR_WIDTH - 0.25 * SCR_WIDTH
  local yY = 0.5 * SCR_HEIGHT
  
  
  state.buttons = {}
  state.buttons[1] = {text="easy", x = xX-200, y = yY, toggle = false, 
                      bbox = bbox:new(xX-200, yY, 300, 200)}
  state.buttons[2] = {text="moy", x = xX-200 + 0.25 * SCR_WIDTH, y = yY, toggle = false, 
                      bbox = bbox:new(xX-200 + 0.25 * SCR_WIDTH, yY, 300, 200)}
  state.buttons[3] = {text="hard", x = xX-200 + 0.5 * SCR_WIDTH, y = yY, toggle = false, 
                      bbox = bbox:new(xX-200 + 0.5 * SCR_WIDTH, yY, 300, 200)}
  
  button1 = love.graphics.newImage("images/ui/easy-diff.png")
  button2 = love.graphics.newImage("images/ui/moye-diff.png")
  button3 = love.graphics.newImage("images/ui/hard-diff.png")
  
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_config_state.update(dt)
local click = false
	local mouse = MOUSE_INPUT
	local mposX = love.mouse.getX()
	local mposY = love.mouse.getY()
	for i=1, #state.buttons do
		if i > 8 and escape then
			if state.buttons[i].bbox:contains_coordinate(mposX, mposY) == true then
				click = true
			end
		elseif i < 9 then
			if state.buttons[i].bbox:contains_coordinate(mposX, mposY) == true then
				click = true
			end
		end
	end
    
	if click then
		mouse:setClick(true)
	else
		mouse:setClick(false)
	end
end

function food_config_state.escape()
	BOIDS:load_state("food_menu_state")
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

  local x1 = state.buttons[1].bbox:get_x()
  local x2 = state.buttons[2].bbox:get_x()
  local x3 = state.buttons[3].bbox:get_x()
  local y1 = state.buttons[1].bbox:get_y()
  local y2 = state.buttons[2].bbox:get_y()
  local y3 = state.buttons[3].bbox:get_y()

  lg.setFont(FONTS.rubik)
  lg.setColor(0, 0, 0, 255)
  if LANGUE == "FR" then
	lg.print("Difficulté", x2, y1-300)
  else
    lg.print("Difficulty", x2, y1-300)
  end
    -- intruction text
 
  lg.setColor(0, 0, 0, 1)
  for i=1,#state.buttons do
    local b = state.buttons[i]
    --b.bbox:draw()
  end
  lg.setColor(255, 255, 255, 255)
  -- draw buttons
  
  lg.draw(button1, x1, y1)
  
  lg.draw(button2, x2, y2)
  
  lg.draw(button3, x3, y3)
  lg.setColor(0, 0, 0, 255)
  if LANGUE == "EN" then
	  lg.print("Easy", x1+50, y1+50)
	  lg.print("Normal", x2+20, y2+50)
	  lg.print("Hard", x3+50, y3+50)
  else
	  lg.print("Facile", x1+30, y1+50)
	  lg.print("Moyen", x2+40, y2+50)
	  lg.print("Difficile", x3+15, y3+50)
  end
	--lg.rectangle("fill", 200+i*60,920, 50,50)
  
end

return food_config_state












