local food_demo_credits_state = state:new()
food_demo_credits_state.label = 'food_demo_credits_state'
local state = food_demo_credits_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_credits_state.keypressed(key)

end
function food_demo_credits_state.keyreleased(key)
end
function food_demo_credits_state.mousepressed(x, y, button)
print("b_________________0")
print(food_demo_credits_state.toggle_button)
local x = love.mouse.getX()
local y = love.mouse.getY()

for i=1,#state.buttons do
    local b = state.buttons[i]
    if b.bbox:contains_coordinate(x, y) then
		if b.text == "goBack" then
			BOIDS:load_state("food_menu_state")
		end
    end
end

function food_demo_credits_state.toggle_button(b)
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
function food_demo_credits_state.mousereleased(x, y, button)
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_credits_state.load(level)
  lg.setBackgroundColor(225, 125, 214, 255)
  
  local xX = 0.5 * SCR_WIDTH
  local yY = 0
  
  
  state.buttons = {}
  state.buttons[1] = {text="goBack", x = xX-550, y = yY+700, toggle = false, 
                      bbox = bbox:new(xX-550, yY+700, 200, 200)}
  
  goBack = love.graphics.newImage("images/ui/goback.png")
  
end


function food_demo_credits_state.newAnimation(image, width, height, duration)
   local animation = {}
   animation.spriteSheet = image;
   animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0
	
	return animation
end

function food_demo_credits_state.escape()
	BOIDS:load_state("food_menu_state")
end

--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_credits_state.update(dt)
	local click = false
	local mouse = MOUSE_INPUT
	local mposX = love.mouse.getX()
	local mposY = love.mouse.getY()
	for i=1, #state.buttons do
		if state.buttons[i].bbox:contains_coordinate(mposX, mposY) == true then
			click = true
		end
	end
    
	if click then
		mouse:setClick(true)
	else
		mouse:setClick(false)
	end
	
end


--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_credits_state.draw()

  local x = 0.5 * SCR_WIDTH
  local y = 0
  
  local x1 = state.buttons[1].bbox:get_x()
  local y1 = state.buttons[1].bbox:get_y()
  
  lg.setColor(0, 0, 0, 255)
  --love.graphics.draw(play, x-150, y+300)
  --love.graphics.draw(parametre, x-500, y+700)
  --love.graphics.draw(credits, x+350, y+700)
  local credits_1 = nil
  local credits_12 = nil
  local credits_13 = nil
  
  if LANGUE == "EN" then
	  credits_1 = "Music : 'Magic Escape Room' Kevin MacLeod (incompetech.com)"
	  credits_12 = "Licensed under Creative Commons: By Attribution 4.0 License"
	  credits_13 = "http://creativecommons.org/licenses/by/4.0/"
	  lg.print("A game by Dylan THOMAS",x-500,y+200)
  else
	  credits_1 = "Musique : 'Magic Escape Room' Kevin MacLeod (incompetech.com)"
	  credits_12 = "Licensed under Creative Commons: By Attribution 4.0 License"
	  credits_13 = "http://creativecommons.org/licenses/by/4.0/"
	  lg.print("Un jeu créé par Dylan THOMAS",x-500,y+200)
  end
  lg.setFont(FONTS.rubikMin)
  lg.print(credits_1,x-500,y+300)
  lg.print(credits_12,x-500,y+325)
  lg.print(credits_13,x-500,y+350)
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(goBack, x1, y1)
  
end

return food_demo_credits_state












