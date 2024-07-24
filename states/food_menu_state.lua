local food_menu_state = state:new()
food_menu_state.label = 'food_menu_state'
local state = food_menu_state
local play = nil
local parametre = nil
local credits = nil

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.keypressed(key)

end
function food_menu_state.escape()
love.event.quit() 
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
			BOIDS:load_state("food_config_state")
		elseif b.text == "parametre" then
			BOIDS:load_state("food_demo_param_state")
		elseif b.text == "credits" then
			BOIDS:load_state("food_demo_credits_state")
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
  src1 = love.audio.newSource("sound/Magic_Escape_Room.mp3", "stream")
  src2 = love.audio.newSource("sound/Revival.mp3", "stream")
  src3 = love.audio.newSource("sound/Perspectives.mp3", "stream")
  local i = math.random(1,3)
  if i == 1 then
	src1:play()
  elseif i == 2 then
	src2:play()
  elseif i == 3 then
	src3:play()
  end
  
  local xX = 0.5 * SCR_WIDTH
  local yY = 0
  
  
  state.buttons = {}
  state.buttons[1] = {text="play", x = xX-150, y = yY+300, toggle = false, 
                      bbox = bbox:new(xX-150, yY+300, 300, 300)}
  state.buttons[2] = {text="parametre", x = xX-550, y = yY+600, toggle = false, 
                      bbox = bbox:new(xX-550, yY+700, 300, 250)}
  state.buttons[3] = {text="credits", x = xX+350, y = yY+700, toggle = false, 
                      bbox = bbox:new(xX+350, yY+700, 350, 150)}
  
  
  play = state.newAnimation(love.graphics.newImage("images/ui/play.png"), 321, 278, 1)
  parametre = state.newAnimation(love.graphics.newImage("images/ui/parametre.png"), 333, 263, 1)
  creditsFR = state.newAnimation(love.graphics.newImage("images/ui/credits-bubble-FR.png"), 322, 162, 1)
  creditsEN = state.newAnimation(love.graphics.newImage("images/ui/credits-bubble-EN.png"), 322, 162, 1)
  
  
  play.currentTime = 0
  parametre.currentTime = 0
  creditsFR.currentTime = 0  
  creditsEN.currentTime = 0  
  
end


function food_menu_state.newAnimation(image, width, height, duration)
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


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_menu_state.update(dt)
	local click = false
	local mouse = MOUSE_INPUT
	local mposX = love.mouse.getX()
	local mposY = love.mouse.getY()
	for i=1, #state.buttons do
		if state.buttons[i].bbox:contains_coordinate(mposX, mposY) == true then
			if i == 1 then	
				click = true
				play.currentTime = play.currentTime + dt
				if play.currentTime >= play.duration then
					play.currentTime = play.currentTime - play.duration
				end
			elseif i == 2 then	
				click = true
				parametre.currentTime = parametre.currentTime + dt
				if parametre.currentTime >= parametre.duration then
					parametre.currentTime = parametre.currentTime - parametre.duration
				end
			elseif i == 3 then	
				click = true
				creditsFR.currentTime = creditsFR.currentTime + dt
				if creditsFR.currentTime >= creditsFR.duration then
					creditsFR.currentTime = creditsFR.currentTime - creditsFR.duration
				end
			end
		end
	end
    
	if click then
		mouse:setClick(true)
	else
		mouse:setClick(false)
	end
	if love.window.getFullscreen()==true then
		--lw.setFullscreen(false)
		local width = lg.getWidth()
		local height = lg.getHeight()
		--newLightWorld:Resize(width, height)
		SCR_HEIGHT = height
		SRC_WIDTH = width
		state.resize(width, height)
	else
		--lw.setFullscreen(true)
		local width = lg.getWidth()
		local height = lg.getHeight()
		--newLightWorld:Resize(width, height)
		SCR_HEIGHT = height
		SRC_WIDTH = width
		state.resize(width, height)
	end	
end

function food_menu_state.resize(w, h)
  local xX = 0.5 * SCR_WIDTH
  local yY = 0
  state.buttons[1].bbox:set_position(xX-150, yY+300) 
  state.buttons[2].bbox:set_position(xX-550, yY+600) 
  state.buttons[3].bbox:set_position(xX+350, yY+700) 
  
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
  --love.graphics.draw(play, x-150, y+300)
  --love.graphics.draw(parametre, x-500, y+700)
  --love.graphics.draw(credits, x+350, y+700)
  
  local x1 = state.buttons[1].bbox:get_x()
  local x2 = state.buttons[2].bbox:get_x()
  local x3 = state.buttons[3].bbox:get_x()
  local y1 = state.buttons[1].bbox:get_y()
  local y2 = state.buttons[2].bbox:get_y()
  local y3 = state.buttons[3].bbox:get_y()
  
  local spriteNum = math.floor(play.currentTime / play.duration * #play.quads) + 1
  love.graphics.draw(play.spriteSheet, play.quads[spriteNum], x1, y1)
  
  local spriteNum = math.floor(parametre.currentTime / parametre.duration * #parametre.quads) + 1
  love.graphics.draw(parametre.spriteSheet, parametre.quads[spriteNum], x2, y2)
  
  local spriteNum = math.floor(creditsFR.currentTime / creditsFR.duration * #creditsFR.quads) + 1
  if LANGUE == "FR" then
	love.graphics.draw(creditsFR.spriteSheet, creditsFR.quads[spriteNum], x3, y3)
  else
	love.graphics.draw(creditsEN.spriteSheet, creditsEN.quads[spriteNum], x3, y3)
  end
  lg.setColor(0, 0, 0, 255)
  for i=1,#state.buttons do 
  local button = state.buttons[i]
  --button.bbox:draw()
  end
  
  lg.setColor(0, 0, 0, 255)
  for i=1, 3 do
	--love.graphics.rectangle( "fill", state.buttons[i].x, state.buttons[i].y, 200, 200)
  end
  
end

return food_menu_state












