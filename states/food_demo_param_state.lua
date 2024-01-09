local food_demo_param_state = state:new()
food_demo_param_state.label = 'food_demo_param_state'
local state = food_demo_param_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_param_state.keypressed(key)

end
function food_demo_param_state.keyreleased(key)
end
function food_demo_param_state.mousepressed(x, y, button)

local x = love.mouse.getX()
local y = love.mouse.getY()

for i=1,#state.buttons do
    local b = state.buttons[i]
    if b.bbox:contains_coordinate(x, y) then
		if b.text == "fullscreen" then
			if love.window.getFullscreen()==true then
				lw.setFullscreen(false)
				local width = lg.getWidth()
				local height = lg.getHeight()
				--newLightWorld:Resize(width, height)
				SCR_HEIGHT = height
				SRC_WIDTH = width
				state.resize(width, height)
				FULLSCREEN = 0
			else
				lw.setFullscreen(true)
				local width = lg.getWidth()
				local height = lg.getHeight()
				--newLightWorld:Resize(width, height)
				state.resize(width, height)
				FULLSCREEN = 1
			end
      elseif b.text == "music" then
		print('click music')
		print(MUSIC)
	    if MUSIC == 1 then
			MUSIC = 0
			love.audio.stop()
			print('stop music')
		else
			print('play music')
			src1 = love.audio.newSource("sound/Magic_Escape_Room.mp3", "stream")
			src2 = love.audio.newSource("sound/Revival.mp3", "stream")
			src3 = love.audio.newSource("sound/Perspectives.mp3", "stream")
			MUSIC = 1
			local i = math.random(1,3)
			  if i == 1 then
				src1:play()
			  elseif i == 2 then
				src2:play()
			  elseif i == 3 then
				src3:play()
			  end
		end
      elseif b.text == "goBack" then
        BOIDS:load_state("food_menu_state")
      elseif b.text == "langue" then
        if LANGUE == "FR" then
			LANGUE = "EN"
		else
			LANGUE = "FR"
		end
      end
    end
end
end

function food_demo_param_state.escape()
	BOIDS:load_state("food_menu_state")
end


function food_demo_param_state.resize(w, h)

  local xX = 0.5 * w
  local yY = 0
  
  state.buttons[1].bbox:set_position(xX-450, yY+300) 
  state.buttons[2].bbox:set_position(xX+150, yY+300) 
  state.buttons[3].bbox:set_position(xX-550, yY+700) 
  state.buttons[4].bbox:set_position(xX-150, yY+300) 
end

function food_demo_param_state.toggle_button(b)
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
      if b.text == "fullscreen" then
        BOIDS:load_next_state()
      elseif b.text == "music" then
        BOIDS:load_next_state()
      elseif b.text == "goBack" then
        BOIDS:load_state("food_config_state")
      end
    --elseif b.toggle == true then
      --if     b.x == xX then
      --  state.selectItem = 1
	  --end
    --end
 -- end
  b.toggle = not b.toggle
end

function food_demo_param_state.mousereleased(x, y, button)
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_param_state.load(level)
  lg.setBackgroundColor(225, 125, 214, 255)
  
  local xX = 0.5 * SCR_WIDTH
  local yY = 0
  
  
  state.buttons = {}
  state.buttons[1] = {text="fullscreen", x = xX-450, y = yY+300, toggle = false, 
                      bbox = bbox:new(xX-450, yY+300, 200, 200)}
  state.buttons[2] = {text="music", x = xX+150, y = yY+300, toggle = false, 
                      bbox = bbox:new(xX+150, yY+300, 200, 200)}
  state.buttons[3] = {text="goBack", x = xX-550, y = yY+700, toggle = false, 
                      bbox = bbox:new(xX-550, yY+700, 200, 200)}
  state.buttons[4] = {text="langue", x = xX-150, y = yY+300, toggle = false, 
                      bbox = bbox:new(xX-150, yY+300, 200, 200)}
  
  fullscreenOn = love.graphics.newImage("images/ui/fullscreenOn.png")
  fullscreen = love.graphics.newImage("images/ui/fullscreen.png")
  music = love.graphics.newImage("images/ui/music.png")
  musicOff = love.graphics.newImage("images/ui/musicOff.png")
  goBack = love.graphics.newImage("images/ui/goback.png")
  langueFR = love.graphics.newImage("images/ui/langueFR.png")
  langueEN = love.graphics.newImage("images/ui/langueEN.png")
  
end


function food_demo_param_state.newAnimation(image, width, height, duration)
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
function food_demo_param_state.update(dt)
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
function food_demo_param_state.draw()

  local x = 0.5 * SCR_WIDTH
  local y = 0
  
  local x1 = state.buttons[1].bbox:get_x()
  local x2 = state.buttons[2].bbox:get_x()
  local x3 = state.buttons[3].bbox:get_x()
  local x4 = state.buttons[4].bbox:get_x()
  local y1 = state.buttons[1].bbox:get_y()
  local y2 = state.buttons[2].bbox:get_y()
  local y3 = state.buttons[3].bbox:get_y()
  local y4 = state.buttons[4].bbox:get_y()
  lg.setColor(255, 255, 255, 255)
  if FULLSCREEN == 1 then
	love.graphics.draw(fullscreen, x1, y1)
  else
	love.graphics.draw(fullscreenOn, x1, y1)
  end
  if MUSIC == 1 then
	love.graphics.draw(music, x2, y2)
  else
	love.graphics.draw(musicOff, x2, y2)
  end
  love.graphics.draw(goBack, x3, y3)
  if LANGUE == "FR" then
	love.graphics.draw(langueFR, x4, y4)
  else
	love.graphics.draw(langueEN, x4, y4)
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

return food_demo_param_state












