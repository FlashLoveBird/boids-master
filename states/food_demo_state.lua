local food_demo_state = state:new()
food_demo_state.label = 'food_demo_state'
local state = food_demo_state
local food = 10
local wood = 30
local nbBoids = 0
local nbBoidsPrey = 0
local nbBoidsPred = 0
local speedTime = 1
local journeyTime = "Matin"
local startTime = os.time()
local endTime = startTime+1
local map = {}
local click = nil
local init = false
local nbHomePredator = 0
local scale = 0
local scaleNow = false
local escape = false
local nbGrpBird = 0
local bitser = require "bitser"
local save = nil
local music = nil
local music_2 = nil
local nbNids = 1
local playIntro = false
local tableAnimRessources = {}


local Shadows = require("shadows")
local LightWorld = require("shadows.LightWorld")
local Light = require("shadows.Light")
local Body = require("shadows.Body")
local Star = require("shadows.Star")
local PolygonShadow = require("shadows.ShadowShapes.PolygonShadow")
local CircleShadow = require("shadows.ShadowShapes.CircleShadow")
local newLight = nil
local newBody = nil
local inkReserveImg = nil
local inkReserve = 100
local boidCostInk = 5

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_state.keypressed(key)
  if state.selectItem ==0 then
	state.flock:keypressed(key)
  end
  
  if key == "return" then
    --BOIDS:load_next_state()
  end
  
  if key == "t" then
    state.reset()
    state.start_fade()
  end
  
  -- mouse wheel up/down changes obstacle_size
  local min, max = 50, 1000
  local inc = 30
  if key == "o" then
    state.point_radius = state.point_radius + inc
    state.point_radius = math.min(max, state.point_radius)
  elseif key == "i" then
    state.point_radius = state.point_radius - inc
    state.point_radius = math.max(min, state.point_radius)
  end
  
end
function food_demo_state.keyreleased(key)
  state.flock:keyreleased(key)
  
   if key == "lshift" then
		state.hero:set_run(false)
   elseif key == "e" then
		state.hero:setStateGrab(false)
   end
  
end

function food_demo_state.wheelmoved(x, y)
    if y > 0 then
        text = "Mouse wheel moved up"
    elseif y < 0 then
        text = "Mouse wheel moved down"
    end
	print(text)
end

function food_demo_state.mousepressed(x, y, button)

  
  if state.selectItem ==0 then
	state.flock:mousepressed(x, y, button)
	state.level:mousepressed(x, y, button, state.flock)
  end

  local map = state.level:getTreeMap()
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  local target = vector2:new(mx, my)
  local buttons = state.buttons
  myText = mpos.y
  for i=1,#buttons do
    local b = buttons[i]
    if b.bbox:contains_coordinate(mpos.x, mpos.y) then
      food_demo_state.toggle_button(b)
	  if b.toggle == true and state.selectItem == 0 then
		b.toggle = false
	  end
      return
    end
  end

   --[[if button == 3 then
    local b = state.speedb
    if b.slow.bbox:contains_coordinate(x, y) then
      b.slow.state = not b.slow.state
      b.fast.state = false
      return
    end
    if b.fast.bbox:contains_coordinate(x, y) then
      b.slow.state = false
      b.fast.state = not b.fast.state
      return
    end
  end--]]
  if button == 2 then
    local button = buttons[state.selectItem]
	if button then
		food_demo_state.toggle_button(button)
	end
	state.selectItem = 0
	state.level:get_mouse():setColor(255,255,255)
  end
  
  if inkReserve > boidCostInk - 1 then
  ------------------------------------------------------------------AJOUT BOIS
  --[[local p = state.wood_source:add_wood(mx, my, 200)
  state.wood_source:force_polygonizer_update()--]]
  cmx = math.floor(mx /32)
  cmy = math.floor(my /32)
 
	  if button == 1 and state.selectItem == 3 and speedTime ~= 0 then
		if mx > 5 and mx < 25600 and my > 5 and my < 25600 then
			if state.level:canILandHere(cmx,cmy,10) then
				--state.hero:putEgg(mx-25,my-25,0)
				--state.hero:setRandomPoints(mx,my,0)
				--love.audio.play(intro)
				--playIntro = true
				state.hero:goDirection(7, mx, my, 0)
				inkReserve = inkReserve - boidCostInk
			end
		end
		
	  end
	  if cmx > 5 and cmx < 800 and cmy > 5 and cmy < 800 and state.level:canILandHere(cmx,cmy,10) and speedTime ~= 0 then
		  if button == 1 and state.selectItem == 1 then
			--map[cmx][cmy] = state.level:addBush(cmx,cmy,state.flock)
			--map[cmx][cmy]:setState(true)
			--map[cmx][cmy]:set_position(cmx,cmy)
			--state.level:setTreeMap(map)
			state.hero:goDirection(7, mx,my,3)
			--state.hero:setRandomPoints(mx,my,3)
			
			local level = state.level
			local level_map = level:get_level_map()
			local tilemap = level_map:get_tile_map()
			
			local mapSave = level:getTreeMapSave()
			
			save = {mapSave}
			bitser.dumpLoveFile('save.dat', mapSave)
			inkReserve = inkReserve - boidCostInk * 2
			--local data = bitser.dumps(map(1))
			--local instance = bitser.loads(data)
			--map[mx][my]:setFlock(state.flock)
		  end
		   if button == 1 and state.selectItem == 2 and speedTime ~= 0 then   
			cmx = math.floor(mx /32)
			cmy = math.floor(my /32)
			--state.hero:setRandomPoints(mx,my,2)		
			state.hero:goDirection(7,mx,my,2)
			inkReserve = inkReserve - boidCostInk * 2
			--state.level:spawn_cube_explosion(200, 200, 200, 300, 300)
		  end
		  if button == 1 and state.selectItem == 5 and speedTime ~= 0 then
			cmx = math.floor(mx /32)
			cmy = math.floor(my /32)
			--state.hero:putEgg(mx-25,my-25,0)
			--state.hero:setRandomPoints(mx,my,4) -- 0 = boid
			
			local level_map = state.level:get_level_map()
			local p = level_map:add_point_to_polygonizer(mx, my, 500)
			level_map:update_polygonizer()
			state.level:addRock(cmx,cmy)
			state.primitives[#state.primitives + 1] = p
			if #state.primitives == 1 then
			  --state.start_fade()
			end
		  end
		  if button == 1 and state.selectItem == 4 and speedTime ~= 0 then
			cmx = math.floor(mx /32)
			cmy = math.floor(my /32)
			if state.level:canILandHere(cmx,cmy,10) then
				--state.hero:putEgg(mx-25,my-25,0)
				--state.hero:setRandomPoints(mx,my,0) -- 0 = boid
				state.hero:goDirection(7,mx,my,1)
			end
		  end  
	  end
	end
end
food_demo_state.toggle_button = function(b)
  --local boids = state.flock.active_boids
  myText = b.text
  local vx,vy = state.level:get_camera():get_size()
  --for i=1,#boids do
	myText = b.text
    --local boid = boids[i]
    if     b.toggle == false then
		for i=1,#state.buttons-6 do
			local b = state.buttons[i]
			b.toggle = false
		end	
      if b.text == "bush" then
        state.selectItem = 1
		state.level:get_mouse():set_input("bush")
      elseif b.text == "tree" then
        state.selectItem = 2
		state.level:get_mouse():set_input("tree")
      elseif b.text == "bird" then
        state.selectItem = 3
		state.level:get_mouse():set_input("bird")
	  elseif b.text == "pred" then
        state.selectItem = 4
		state.level:get_mouse():set_input("pred")
	   elseif b.text == "ep" then
        --state.selectItem = 5
      elseif b.text == "pause" then
		speedTime = 0
		love.audio.pause(intro)
		state.selectItem = 0
      elseif b.text == "fastforward" then
		speedTime = 2
		intro:setPitch(2)
		state.selectItem = 50
	  elseif b.text == "recommencer" and escape then
		state.level:reload(state.flock)
	  elseif b.text == "quitter" and escape then
		love.event.quit() 
       elseif b.text == "play" then
	   intro:setPitch(1)
		speedTime = 1
		--love.audio.play(intro)
		state.selectItem = 0
      elseif b.text == "fullscreen" and escape then
		if love.window.getFullscreen()==true then
			lw.setFullscreen(false)
			local width = lg.getWidth()
			local height = lg.getHeight()
			newLightWorld:Resize(width, height)
			SCR_HEIGHT = height
			SRC_WIDTH = width
			state.resize(width, height)
			FULLSCREEN = 0
		else
			lw.setFullscreen(true)
			local width = lg.getWidth()
			local height = lg.getHeight()
			newLightWorld:Resize(width, height)
			SCR_HEIGHT = height
			SRC_WIDTH = width
			state.resize(width, height)
			FULLSCREEN = 1
		end
      elseif b.text == "music" and escape then
		if MUSIC == 1 then
			love.audio.stop()
			MUSIC = 0
		else
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
	  end
    elseif b.toggle == true then
	  state.level:get_mouse():set_input(nil)
	  
      if     b.text == "bush" then
        state.selectItem = 1
      elseif b.text == "tree" then
        state.selectItem = 2
      elseif b.text == "bird" then
         state.selectItem = 3
	  elseif b.text == "pred" then
        state.selectItem = 4
	  elseif b.text == "ep" then
        --state.selectItem = 5
      elseif b.text == "pause" then
		speedTime = 0
		state.selectItem = 0
		love.audio.pause(intro)
       elseif b.text == "play" then
		speedTime = 1
		intro:setPitch(1)
		state.selectItem = 0
		--love.audio.play(intro)
	   elseif b.text == "recommencer" and escape then
		state.level:reload(state.flock)
	   elseif b.text == "quitter" and escape then
		love.event.quit() 
      elseif b.text == "fastforward" then
		speedTime = 2
		state.selectItem = 0
		intro:setPitch(2)
	  elseif b.text == "fullscreen" and escape then
		if love.window.getFullscreen()==true then
			lw.setFullscreen(false)
			local width = lg.getWidth()
			local height = lg.getHeight()
			newLightWorld:Resize(width, height)
			SCR_HEIGHT = height
			SRC_WIDTH = width
			FULLSCREEN = 0
		else
			lw.setFullscreen(true)
			local width = lg.getWidth()
			local height = lg.getHeight()
			newLightWorld:Resize(width, height)
			SCR_HEIGHT = height
			SRC_WIDTH = width
			FULLSCREEN = 1
		end
      elseif b.text == "music" and escape then
		if MUSIC == 1 then
			love.audio.stop()
		else
			src1 = love.audio.newSource("sound/Magic_Escape_Room.mp3", "stream")
			src2 = love.audio.newSource("sound/Magic_Escape_Room.mp3", "stream")
			src3 = love.audio.newSource("sound/Magic_Escape_Room.mp3", "stream")
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
	  end
    end
 -- end
  b.toggle = not b.toggle
  print("state.selectItem by buton")
  print(state.selectItem)
end

function food_demo_state.createTown(x, y, r)
	
	--[[local x = math.random(0,ACTIVE_AREA_WIDTH)
	local y = math.random(0,ACTIVE_AREA_HEIGHT*2) 
    
	
	local mx, my = x, y
    local level_map = state.level:get_level_map()
    local p = level_map:add_point_to_polygonizer(mx, my, 1)
    level_map:update_polygonizer()
    
    state.primitives[#state.primitives + 1] = p
    if #state.primitives == 1 then
      state.start_fade()
    end--]]

	local p = state.town:add_town(x, y, 100)
	state.town:force_polygonizer_update()
	state.primitives[#state.primitives + 1] = p
	if #state.primitives == 1 then
	  state.start_fade()
	end
	local level = state.level:getTreeMap()
	local x = math.floor(x/32)
	local y = math.floor(y/32)
	level[x][y] = p
	
	print("ajout d'une ville en")
    print(x,y)
	
end

function food_demo_state.mousereleased(x, y, button)
  --if state.selectItem ==0 then
    state.flock:mousereleased(x, y, button)
	state.level:mousereleased(x, y, button)
  --end
end

function food_demo_state.wheelmoved(x, y)
	if y > 0 then
        text = "Mouse wheel moved up"
    elseif y < 0 then
        text = "Mouse wheel moved down"
    end
	print(text)
end

function food_demo_state.reset()
  for i=#state.primitives,1,-1 do
    state.food_source:remove_food_source(state.primitives[i])
    state.primitives[i] = nil
  end
  state.food_source:force_polygonizer_update()
  
  state.emitter:reset()
end

function food_demo_state.start_fade()
  if state.is_fade_active then return end
  state.is_fade_active = true
  state.current_time = 0
end

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_state.load(level)
  state.level = level
  love.window.setVSync( 2 )
  local tpad = 2
  local x, y = state.level.level_map.bbox.x + tpad * TILE_WIDTH, 
               state.level.level_map.bbox.y + tpad * TILE_HEIGHT
  local width, height = state.level.level_map.bbox.width,--state.level.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        state.level.level_map.bbox.height--state.level.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
  local depth = 3500
  
  local vx,vy = state.level:get_camera():get_size()
  print('vy est de .......')
  print(vy)
  --vx/2-350+i*120, vy-110
  state.block_actions = block_actions:new()
  state.block_actions:set_position(50,vy/2-340)
  local actionX, actionY = state.block_actions.x, state.block_actions.y + 10
  
  state.buttons = {}
  state.buttons[1] = {text="bush", x = actionX, y = actionY+1*90, toggle = false, 
                      bbox = bbox:new(actionX, actionY+1*90, 100, 70)}
  state.buttons[2] = {text="tree", x = actionX, y = actionY+2*90, toggle = false, 
                      bbox = bbox:new(actionX, actionY+2*90, 100, 70)}
  state.buttons[3] = {text="bird", x = actionX, y = actionY+3*90, toggle = false, 
                      bbox = bbox:new(actionX, actionY+3*90, 100, 70)}
  state.buttons[4] = {text="pred", x = actionX, y = actionY+4*90, toggle = false, 
                      bbox = bbox:new(actionX, actionY+4*90, 100, 70)}
  state.buttons[5] = {text="ep", x = actionX, y = actionY+5*90, toggle = false, 
                      bbox = bbox:new(actionX, actionY+5*90, 100, 70)}
  
  state.flock = flock:new(state.level,"boid", x+300, y+300, width-500, height-500, depth)
  state.flock:set_gradient(require("gradients/named/greenyellow"))
  local x, y, z = 1200, 300, 500
  local dx, dy, dz = 0, 1, 0.5
  local r = 200
  
  -- Create a light world
  newLightWorld = LightWorld:new()
  newLightWorld:Resize(vx, vy)
  newLightWorld:SetColor(0, 0, 0)
  --newLight = Light:new(newLightWorld, 50)
  -- Set the light's color to white
  --newLight:SetColor(255, 255, 255, 255)
  
  newStar = Star:new(newLightWorld, 500)	
	
  -- Set the light's position
  --newLight:SetPosition(400, 400)
  
  --state.emitter = boid_emitter:new(state.level, state.flock, x, y, z, dx, dy, dz, r, 1)
  --state.emitter:set_dead_zone( 0, 4000, 3000, 100)
  --state.emitter:set_type("boid")
  --state.emitter:set_emission_rate(200)
  --state.emitter:set_boid_limit(2000)
  --state.emitter:stop_emission()
  --state.emitter:start_emission()
  --state.start_fade()
  
  flux = require "flux"

  explosionSound = love.audio.newSource("sound/feu.mp3", "stream")
  
  local spritesheet = lg.newImage("images/animations/boidsheet.png")
  local data = require("images/animations/boidsheet_data")
  state.boid_hash = {}
  state.animation_set = animation_set:new(spritesheet, data)
  
  state.level.level_map:setWallMap()
  
  --state.flock2 = flock:new(state.level,"predator", x, y, width, height, depth)
  --state.flock2:set_gradient(require("gradients/named/whiteblack"))
  --local x, y, z = 1200, 300, 500
  --local dx, dy, dz = 0, 1, 0.5
  --local r = 200
  --state.emitter2 = boid_emitter:new(state.level, state.flock, x, y, z, dx, dy, dz, r)
  --state.emitter2:set_dead_zone( 0, 4000, 3000, 100)
  --state.emitter2:set_type("predator")
  --state.emitter2:set_emission_rate(1)
  --state.emitter2:set_boid_limit(100)
  --state.emitter:stop_emission()
  --state.emitter:start_emission()
  --state.start_fade()
  
  --state.food_source = boid_food_source:new(state.level, state.flock)
  --state.wood_source = boid_wood_source:new(state.level, state.flock)
  state.town = town:new(state.level, state.flock)
  
  state.hero = hero:new(state.level, state.flock, 100, 100)
  
  state.level:set_player(state.hero)
  
  state.nbHomePredator = 0

  state.point_radius = 200
  state.polygonizer_threshold = 0.65
  state.primitives = {}
  state.primitive_bbox = bbox:new(0, 0, 0, 0)
  state.fade_time = 1
  state.is_fade_active = false
  state.current_time = 0
  state.fade_text = nil
  state.selectItem = 0
  state.nbHome = 1
  
  --musique = love.audio.newSource("sound/wild.mp3", "stream")
 
  button = lg.newImage("images/Jungle/upgrade/btn.png")
  buttonpress = lg.newImage("images/Jungle/upgrade/btn-push.png")
  --panelImg = lg.newImage("images/PNG/panel_beige.png")
  panelImg1 = state.newAnimation(love.graphics.newImage("images/ui/stackFood.png"), 82, 80, 7)
  panelImg2 = state.newAnimation(love.graphics.newImage("images/PNG/panel_beige.png"), 102, 101, 7)
  panelImg3 = state.newAnimation(love.graphics.newImage("images/PNG/panel_beige.png"), 102, 101, 7)
  
  table.insert(tableAnimRessources, panelImg1)
  table.insert(tableAnimRessources, panelImg2)
  table.insert(tableAnimRessources, panelImg3)
  
  inkReserveImg = state.newAnimation(love.graphics.newImage("images/ui/reserve-ink.png"), 80, 100, 9)
  animationStomach = state.newAnimation(love.graphics.newImage("images/ui/stomach.png"), 80, 100, 5)
  animationEnergy = state.newAnimation(love.graphics.newImage("images/ui/energyIcon.png"), 80, 100, 5)
  
  foodIcon = lg.newImage("images/ui/food.png")
  woodIcon = lg.newImage("images/ui/wood_icon.png")
  nbBoidsIcon = lg.newImage("images/ui/nbBoids.png")
 
  birdIcon = lg.newImage("images/env/bird.png")
  bushIcon = lg.newImage("images/env/Bush2-1x1.png")
  predatorIcon = lg.newImage("images/env/predator.png")
  epIcon = lg.newImage("images/env/Stump3-1x1.png")
  treeIcon = lg.newImage("images/env/treeIcon.png")
  rockIcon = lg.newImage("images/env/rockIcon.png")
  
  fondui = lg.newImage("images/ui/fondui.png")
  
  fonduiBag = lg.newImage("images/ui/bag.png")
  fonduiBagFond = lg.newImage("images/ui/bagfond.png")
  
  
  menuFond = lg.newImage("images/Jungle/pause/table.png")
  menuTxt = lg.newImage("images/Jungle/pause/text.png")
  
  pause = lg.newImage("images/Black/1x/pause.png")
  play = lg.newImage("images/Black/1x/forward.png")
  fastforward = lg.newImage("images/Black/1x/fastForward.png")
  fullscreenOn = lg.newImage("images/ui/fullscreenOn-min.png")
  fullscreen = lg.newImage("images/ui/fullscreen-min.png")
  exitIcon = lg.newImage("images/ui/exit.png")
  retryIcon = lg.newImage("images/ui/retry.png")
  width = pause:getWidth()
  height = pause:getHeight()
  
  musicImg = love.graphics.newImage("images/ui/music-min.png")
  musicOff = love.graphics.newImage("images/ui/musicOff-min.png")
  
  voiceImg = lg.newImage("images/env/voice.png")
  
  showEmoteCriImg = love.graphics.newImage("images/emote/emote_cri.png")
  
  state.buttons[6] = {text="pause", x = actionX+vx/2+100-200, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+vx/2+100-200, 30, 50, 50)}
  state.buttons[7] = {text="play", x = actionX+vx/2+150-200, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+vx/2+150-200, 30, 50, 50)}
  state.buttons[8] = {text="fastforward", x = actionX+vx/2+200-200, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+vx/2+200-200, 30, 50, 50)}
  state.buttons[9] = {text="fullscreen", x = actionX+vx/2-200, y = vy/3, toggle = true, 
                      bbox = bbox:new(actionX+vx/2-200, vy/3, 100, 100)}
  state.buttons[10] = {text="recommencer", x = actionX+vx/2-200, y = vy/3+100, toggle = true, 
                      bbox = bbox:new(actionX+vx/2-200, vy/3+100, 100, 100)}
  state.buttons[11] = {text="quitter", x = actionX+vx/2-200, y = vy/3+200, toggle = true, 
                      bbox = bbox:new(actionX+vx/2-200, vy/3+200, 100, 100)}
  state.buttons[12] = {text="music", x = actionX+vx/2+200, y = vy/3, toggle = true, 
                      bbox = bbox:new(actionX+vx/2+200, vy/3, 100, 100)}					  
	
	local level = state.level:getTreeMap()
	local level_map = state.level:get_level_map()	
	local Poly = level_map.polygonizer
	local w, h = Poly.cell_width, Poly.cell_height
	local nbArbre = 0
	local boid
	local predator
	local count = 0
	local countRock = 0
	local countTown = 0
	local countPred = 0

local target = vector2:new(1000, 1000)
local cam = state.level:get_camera()

if DIFFICULTY == "easy" then
	for x=0, 1 do
		--human = state.flock:add_human()
	end
	for i = 0, 1 do
		state.flock:add_boid(math.random(2500,2700), math.random(2500,2700), 100, 10, 10, 10, true)
	end
	for i = 0, 0 do
		--state.flock:add_predator(math.random(7000,12500), math.random(7000,12500), 100, 10, 10, 10, true)
	end
elseif DIFFICULTY == "moy" then
	for x=1, 2 do
		human = state.flock:add_human()
	end
	for i = 1, 50 do
		state.flock:add_boid(math.random(500,12500), math.random(500,12500), 100, 10, 10, 10, true)
	end
elseif DIFFICULTY == "hard" then
	for x=1, 10 do
		human = state.flock:add_human()
	end
	for i = 1, 200 do
		state.flock:add_boid(math.random(500,12500), math.random(500,12500), 100, 10, 10, 10, true)
	end
end
--human2 = state.flock:add_human()
	
	for x=5, 800 do--Poly.rows-5 do
		for y=5, 800 do--Poly.cols-5 do
			local randX = 32*x
			local randY = 32*y
			local caseX = x--math.floor( randX / h ) 
			local caseY = y--math.floor( randY / w )
			--if math.random()>0.99 then
			if level[caseX] then --or (caseX==35 and caseY==25) or (caseX==55 and caseY==25)  then
				if level[caseX][caseY] and init==false then
					--print("position")
					--print(caseX)				
					--local p = level_map:add_point_to_polygonizer(randX, randY, 1)
					--level_map:update_polygonizer()
					--state.primitives[#state.primitives + 1] = p
					--if #state.primitives == 1 then
					 -- state.start_fade()
					--end
					--map[caseX][caseY] = state.level:addTree(0)
					--map[caseX][caseY]:set_position(randX,randY)
					--level[caseX][caseY]:add(state.level:addHome(randX-35,randY-60,10,10,0,state.flock,state.level,3))
					--level[caseX][caseY]:setNumEmits(1)
					
								
					
					--boid = state.flock:add_boid(200, 200, z, dx, dy, dz, true, require("gradients/named/orange"))
					--boid:setObjectiv("fly")
					--map[caseX][caseY]:setState(true)
					--[[for i=1,3 do
						local p = state.water_source:add_water(math.random(50,5000), math.random(50,5000), 3)
						state.water_source:force_polygonizer_update()
						state.primitives[#state.primitives + 1] = p
						if #state.primitives == 1 then
						  state.start_fade()
						end
					end--]]
					level_map:update_polygonizer()
					state.primitives[#state.primitives + 1] = p
					if #state.primitives == 1 then
					  state.start_fade()
					end				
					init=true
					print('OKKKKKKK4')
					--state.level:setFlock(state.flock)
					--[[state.level:addNuage(math.random(50,50), math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)
					state.level:addNuage(math.random(50,50),math.random(50,50), 50, state.flock)--]]
				end
				if state.level:canILandHere(caseX,caseY,20) then
					if caseX<160 and caseY<160 and caseX>100 and caseY>100 and countTown<1 then
						local randX = 32*x
						local randY = 32*y
						countTown = countTown + 1
						food_demo_state.createTown(randX,randY,100)
						--food_demo_state.createTown(randX,randY,100)
						state.hero:set_posX(randX)
						state.hero:set_posY(randY-200)
						target.x, target.y = caseX*32, caseY*32-200
						cam:set_target(target,true)
						state.hero:goDirection(10)
					end
				end
				if level[caseX][caseY]~=nil then
					if count<nbNids and level[caseX][caseY]:getNumEmits()==0 and level[caseX][caseY].table=="tree" then
						print('ajout de nid')
						if DIFFICULTY == "easy" then
							--local emit = state.level:addHome(randX-35,randY-60,10,10,0,state.flock,state.level,9,0)
						elseif DIFFICULTY == "moy" then
							--local emit = state.level:addHome(randX-35,randY-60,10,10,0,state.flock,state.level,5,0)
						elseif DIFFICULTY == "hard" then
							--local emit = state.level:addHome(randX-35,randY-60,10,10,0,state.flock,state.level,2,0)
						end
						--level[caseX][caseY]:add(emit)
						--level[caseX][caseY]:setNumEmits(1)
						count = count + 1
						--map[caseX][caseY] = state.level:addTree(0)
						--map[caseX][caseY]:set_position(randX,randY)
						--map[caseX][caseY]:add(nil)
						--map[caseX][caseY]:setNumEmits(0)
						--map[caseX][caseY]:setState(true)
						--nbArbre = nbArbre + 1
					--[[elseif level[caseX][caseY]:getNumEmits()==0 and countPred<nbNidsPred then
						if state.nbHomePredator <100 then
							level[caseX][caseY]:add(state.level:addPredatorHome(randX-35,randY-60,10,10,0,state.flock,state.level,3))
							--predator = state.flock:add_predator(200+math.random(1,100), 200+math.random(1,100), z, dx, dy, dz, true, require("gradients/named/orange"))
							state.nbHomePredator = state.nbHomePredator+1
							level[caseX][caseY]:setNumEmits(1)
							countPred = countPred + 1
							print("appel creation home predator")
						end--]]
						
						
						
					end
				elseif state.level:canILandHere(caseX,caseY,20) then
					--[[if caseX<190 and caseY<190 and caseX>10 and caseY>10 and countRock<10 then
						local randX = 32*x
						local randY = 32*y
						countRock = countRock + 1
						local p = level_map:add_point_to_polygonizer(randX, randY, 10)
						level[caseX][caseY] = state.level:addRock(caseX,caseY)
						print("Rock ajoute en")
						print(caseX,caseY)
						state.primitives[#state.primitives + 1] = p
						if #state.primitives == 1 then
						  state.start_fade()
						end	
						
					end--]]
				end	
				if level[caseX][caseY] then
					--if level[caseX][caseY].name>50 then
						level[caseX][caseY]:setFlock(state.flock)
						print("-------------------------------------------------------set flock")
						print(caseX,caseY)
						print(level[caseX][caseY].name)
					--end
				end
			end
		end
	end
	
	--[[for x=0,Poly.rows do
		local randY = math.random(-50,50)
		local p = level_map:add_point_to_polygonizer(x*32, 1000+randY, 350)
		state.primitives[#state.primitives + 1] = p
			
		local p = level_map:add_point_to_polygonizer(x*32, 10100+randY, 350)
		state.primitives[#state.primitives + 1] = p	
	end
	
	for y=0,Poly.cols do
		local randX = math.random(-50,50)
		local p = level_map:add_point_to_polygonizer(2000+randX, y*32, 350)
		state.primitives[#state.primitives + 1] = p
		local randX = math.random(-50,50)
		local p = level_map:add_point_to_polygonizer(10100+randX, y*32, 350)
		state.primitives[#state.primitives + 1] = p
	end
	
	if #state.primitives == 1 then
		state.start_fade()
	end
	
	level_map:update_polygonizer()
	state.level:setTreeMap(level)--]]
	state.nbHome = state.nbHome -1	
	
	level_map:setWallMap()
	
	
	intro = love.audio.newSource("sound/intro.mp3", "stream")
	intro:setVolume(0.1)
end

function food_demo_state.newAnimation(image, width, height, duration)
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

function food_demo_state.getTreeAround(caseX, caseY, radius)
local startX = caseX
local startY = caseY
local maxX = 0
local maxY= 0
local level_map = state.level:get_level_map()	
local Poly = level_map.polygonizer
local returnVar = 0 
if caseX-radius>5 then
	startX = caseX-radius
else
	startX = caseX
end
if caseY-radius>5 then
	startY = caseY-radius
else
	startY = caseY
end
if caseX+radius<Poly.cols-5 then
	maxX = caseX+radius
else
	maxX = caseX
end
if caseY+radius>Poly.rows-5 then
	maxY = caseY+radius
else
	maxY = caseY
end
local mapTrees = state.level:getTreeMap()

for stepX = startX, maxX do
	for stepY = startY, maxY do
		if mapTrees[stepX] then
			if mapTrees[stepX][stepY] then
				if mapTrees[stepX][stepY] ~= nil then
					returnVar = returnVar + 1 
				else
				end
			end
		end
	end
end

return returnVar
end

function food_demo_state.escape()
	if escape then
		escape = false
	else
		escape = true
	end
end

function food_demo_state.resize(w, h, scale)

  
  local vx,vy = state.level:get_camera():get_size()
  print(("Window resized to width: %d and height: %d."):format(w, h))
  --scale = scale + 1000
  scaleNow = true
  local hpos =  state.hero:get_pos()
  local cam = state.level:get_camera()
  local x, y = cam:get_viewport()
  state.block_actions:set_position(50,h/2-340)
  local actionX, actionY = state.block_actions.x, state.block_actions.y + 10
  local width, height = lg.getDimensions()
  local target = vector2:new(hpos.x, hpos.y)
  local camPos = cam:get_center()
  --state.hero:set_position(target)
  --cam:set_scale(scale)
  print("go .")
  print(target.x,target.y)
  
  state.buttons[1].bbox:set_position(actionX, actionY+1*90) 
  state.buttons[2].bbox:set_position(actionX, actionY+2*90) 
  state.buttons[3].bbox:set_position(actionX, actionY+3*90) 
  state.buttons[4].bbox:set_position(actionX, actionY+4*90)
  state.buttons[5].bbox:set_position(actionX, actionY+5*90) 	
  
  state.buttons[6].bbox:set_position(actionX+w/2+100-200, 30) 
  state.buttons[7].bbox:set_position(actionX+w/2+150-200, 30) 
  state.buttons[8].bbox:set_position(actionX+w/2+200-200, 30) 
  state.buttons[9].bbox:set_position(actionX+w/2-200, h/3)
  state.buttons[10].bbox:set_position(actionX+w/2-200, h/3+100) 	
  state.buttons[11].bbox:set_position(actionX+w/2-200, h/3+200)
  state.buttons[12].bbox:set_position(actionX+w/2+200, h/3)   
  
  --if w > 1920 then
    --camPos.x = hpos.x
	--camPos.y = hpos.y
  cam:set_size(w, h)
  cam:set_target(target,true)
  --end
  
  
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local t = 0
function food_demo_state.update(dt)

  -- camera movement test
  local cam = state.level:get_camera()
  local hpos =  state.hero:get_pos()
  local target = vector2:new(hpos.x, hpos.y)
  local tx, ty = 0, 0
  local cam = state.level:get_camera()
  local x, y = cam:get_viewport()
  local mouse = state.level:get_mouse()
  local mpos = mouse:get_position()
  local vx,vy = cam:get_size()
  local mx, my = x + mpos.x, y + mpos.y
  local camPos = cam:get_center()
  local firstDance = state.hero:getFirstDance()
  local r = newStar:GetRadius()
  --local dt = 0.004
  
  
  local speedSpeed = speedTime
  local speed = 0
  if speedSpeed==0 then 
	if state.level.master_timer.is_stopped == false then
		state.level.master_timer:stop()
	end
    dt = 0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
	speed = 0
  elseif speedSpeed==1 then
	  if state.level.master_timer.is_stopped == true then
			state.level.master_timer:start()
	  end
	dt = math.min(dt, 1/20)
	speed = 10
  elseif speedSpeed==2 then
	dt = math.min(dt*5, 1/2)
	speed = 20
  end
  
  if src1:isPlaying()==false and src2:isPlaying()==false and src3:isPlaying()==false and MUSIC == 1 then
	local i = math.random(1,3)
	if i == 1 then
		src1:play()
	elseif i == 2 then
		src2:play()
	elseif i == 3 then
		src3:play()
	 end
  end
  
  newLightWorld:Update()
  --newLight:SetPosition(vx/2, vy/2)
  newStar:SetPosition(vx/2, vy/2-50)
  local targetCam = vector2:new(hpos.x, hpos.y)
  if firstDance == true and speedSpeed~=0 then
	  --[[target2.x = (target.x + mx)/2
	  target2.y = (target.y + my)/2
	  target2.x = (target2.x + target.x)/2
	  target2.y = (target2.y + target.y)/2
	  target2.x = (target2.x + target.x)/2
	  target2.y = (target2.y + target.y)/2
	  cam:set_target(target2)--]]
	  if lk.isDown("z", "up", "w") or lk.isDown("q", "left", "a") or lk.isDown("s", "down") or lk.isDown("d", "right") or lk.isDown("lshift") or lk.isDown("space") or lk.isDown("e") then
		  if lk.isDown("lshift") then
			if state.hero:get_tired()>30 and state.hero:get_hunger()>30 then
				state.hero:set_run(true)
				speed = speed + 10
			end
		  end
		  if lk.isDown("z", "up", "w") then
			ty = ty - speed
			state.hero:goDirection(1)
			targetCam.y = targetCam.y-200
		  end
		  if lk.isDown("q", "left", "a") then
			tx = tx - speed
			state.hero:goDirection(2)
			targetCam.x = targetCam.x-200
		  end
		  if lk.isDown("s", "down") then
			ty = ty + speed
			state.hero:goDirection(3)
			targetCam.y = targetCam.y+200
		  end
		  if lk.isDown("d", "right") then
			tx = tx + speed
			state.hero:goDirection(4)
			targetCam.x = targetCam.x+200
		  end
		  if lk.isDown("space") then
			state.hero:goDirection(6)
		  end
		  if lk.isDown("e") and state.hero:getCanStateGrab()==true then
			state.hero:goDirection(9)
		  end
		  target.x, target.y = target.x + tx, target.y + ty
		  
		  local block = state.hero:canIGoHere(target)
		  if target.x>vx/2+300 and target.y>vy/2+300 and target.x<ACTIVE_AREA_WIDTH-vx/2-300 and target.y<ACTIVE_AREA_HEIGHT-vy/2-300 and block==false then
			state.hero:set_position(target,true)
			local w, h = lg.getDimensions()
			state.hero:set_target(target.x, target.y)
			--local target2 = vector2:new(target.x+w/2, target.y+h/2)
			
			state.hero:resetBlock()
			state.hero:showWarning(false)
		  else
			state.hero:showWarning(true)
		  end
	  elseif state.hero:getBreathe() == 0 then
		state.hero:goDirection(5)
	  end
	  cam:set_target(targetCam)
  else
	local radius = r-2
	newStar:SetRadius(radius)
	--newLightWorld:SetColor(local_time_color, local_time_color, local_time_color)
  end
  
  --[[if mpos.x>vx/10 and mpos.y>vy/10 and mpos.x<vx-100 and mpos.y<vy-100 and block==false then
	
  elseif mpos.x<vx/10 and mpos.y>vy/10 and mpos.x<vx-100 and mpos.y<vy-100 and block==false then
    target.x = camPos.x - 100
	target.y = camPos.y
	cam:set_target(target)
  elseif mpos.x>vx/10 and mpos.y<vy/10 and mpos.x<vx-100 and mpos.y<vy-100 and block==false then
    target.y = camPos.y - 100
	target.x = camPos.x
	cam:set_target(target)
  elseif mpos.x>vx/10 and mpos.y>vy/10 and mpos.x>vx-100 and mpos.y<vy-100 and block==false then
    target.x = camPos.x + 100
	target.y = camPos.y
	cam:set_target(target)
  elseif mpos.x>vx/10 and mpos.y>vy/10 and mpos.x<vx-100 and mpos.y>vy-100 and block==false then
    target.y = camPos.y + 100
	target.x = camPos.x
	cam:set_target(target)
  end
  --print(target)
  --cam:set_target(target)

  --[[if x<100 then
	local target = vector2:new(vx/2, hpos.y)
    cam:set_target(target, true)
  end--]]  
  
  state.level:update(dt)
  --state.emitter:update(dt)
  --state.food_source:update(dt)
  --state.wood_source:update(dt)
  --state.water_source:update(dt)
  state.town:update(dt)
  --state.emitter2:update(dt)
  state.flock:update(dt)
  --state.flock2:update(dt)
  --state.hero:update(dt)
  state.animation_set:update(dt)
  
  flux.update(dt)
  
  --nbBoids = state.emitter:getnbBoids()
	
  
  local boids = state.flock.active_boids
  for i=1,#boids do
    local b = boids[i]
    if not state.boid_hash[b] then
      state.boid_hash[b] = true
      b.animation = state.animation_set:get_animation()
      b.animation:play()
    end
    
    if not b.animation:is_running() then
      b.animation:_init()
      b.animation:play()
    end
    --b.animation:set_position(x + b.position.x, y + b.position.y)
  end
  
  -- update fade
  if state.is_fading then
    state.current_time = state.current_time + dt
  end
  
   local r = state.point_radius
  local b = state.primitive_bbox
  b.x, b.y = mx - r, my - r
  b.width, b.height = 2 * r, 2 * r
  
  local local_time = math.floor(state.level.master_timer:get_time())
  local local_time_color =  local_time*(5/2)
  
  if firstDance == true then
	  if local_time>25 and local_time<40 then
		journeyTime = "MIDI"
		--newLightWorld:SetColor(255, 255, 255)
	  elseif local_time>41 and local_time<70 then
		journeyTime = "SOIR"
		--newLightWorld:SetColor(255-local_time_color, 255-local_time_color, 255-local_time_color)
	  elseif local_time>71 and local_time<100 then
		journeyTime = "NUIT"
		--newLightWorld:SetColor(255-local_time_color, 255-local_time_color, 255-local_time_color)
		--love.audio.play(music_2)
	  elseif local_time>1 and local_time<24 then
		journeyTime = "MATIN"
		state.call=0
		--love.audio.stop(music_2)
		local_time_color = local_time_color * 5
		--newLightWorld:SetColor(local_time_color, local_time_color, local_time_color)
		--love.audio.play(music)
	  end
	  newLightWorld:SetColor(255, 255, 255)
	end
  
  if os.time() >= endTime then
	--[[endTime = endTime + 1
	if journeyTime == "SOIR" and state.call<6 then
		local boids = state.flock.active_boids
		if #boids > 10 then
			nbGrpBird = math.floor(#boids/5)
			local call = state.call
			for i=1+call*nbGrpBird,nbGrpBird*(call+1) do
				local boid = boids[i]
				if boid then
					if boid.free == false then
						boid:goHome()
					end
				end
				--boid.rule_weights[boid.separation_vector] = 0.1
			end
			state.call=state.call+1
		else
			print('go rentrer solo')
			nbGrpBird = #boids
			for i=1,nbGrpBird do
				local boid = boids[i]
				if boid then
					if boid.free == false then
						boid:goHome()
					end
				end
				--boid.rule_weights[boid.separation_vector] = 0.1
			end
			state.call=state.call+1
		end
	end--]]
	if journeyTime == "NUIT" then
	    --local actualFood = state.level:getFood()
		--state.level:_feed_boids()
	end
  end
  food = state.level:getFood()
  wood = state.level:getWood()
  nbBoids,nbBoidsPrey,nbBoidsPred = state.level:getBoids()
  
  local heroFood = math.floor(state.hero:getFood())
  
	tableAnimRessources[1].currentTime = heroFood
	
	if food > 90 then
		tableAnimRessources[2].currentTime = 6
	elseif food > 70 then
		tableAnimRessources[2].currentTime = 5
	elseif food > 50 then
		tableAnimRessources[2].currentTime = 4
	elseif food > 30 then
		tableAnimRessources[2].currentTime = 3
	elseif food > 10 then
		tableAnimRessources[2].currentTime = 2
	elseif food > 1 then
		tableAnimRessources[2].currentTime = 1
	elseif food < 1 then
		tableAnimRessources[2].currentTime = 0
	end
	
	if wood > 90 then
		tableAnimRessources[3].currentTime = 6
	elseif wood > 70 then
		tableAnimRessources[3].currentTime = 5
	elseif wood > 50 then
		tableAnimRessources[3].currentTime = 4
	elseif wood > 30 then
		tableAnimRessources[3].currentTime = 3
	elseif wood > 10 then
		tableAnimRessources[3].currentTime = 2
	elseif wood > 1 then
		tableAnimRessources[3].currentTime = 1
	elseif wood < 1 then
		tableAnimRessources[3].currentTime = 0
	end
	
	if inkReserve > 90 then
		inkReserveImg.currentTime = 0
	elseif inkReserve > 80 then
		inkReserveImg.currentTime = 1
	elseif inkReserve > 60 then
		inkReserveImg.currentTime = 2
	elseif inkReserve > 40 then
		inkReserveImg.currentTime = 3
	elseif inkReserve > 30 then
		inkReserveImg.currentTime = 4
	elseif inkReserve > 20 then
		inkReserveImg.currentTime = 5
	elseif inkReserve > 10 then
		inkReserveImg.currentTime = 6
	elseif inkReserve > 1 then
		inkReserveImg.currentTime = 7
	elseif inkReserve < 1 then
		inkReserveImg.currentTime = 8
	end
	
    local hunger = state.hero:get_hunger()
  
    if hunger > 80 then
	  animationStomach.currentTime = 0
    elseif hunger > 60 then
	  animationStomach.currentTime = 1
    elseif hunger > 40 then
	  animationStomach.currentTime = 2
    elseif hunger > 20 then
	  animationStomach.currentTime = 3
    else
	  animationStomach.currentTime = 4
    end
	
	local energy = state.hero:get_energy()
  
	if energy > 80 then
		animationEnergy.currentTime = 0
	elseif energy > 60 then
		animationEnergy.currentTime = 1
	elseif energy > 40 then
		animationEnergy.currentTime = 2
	elseif energy > 20 then
		animationEnergy.currentTime = 3
	else
		animationEnergy.currentTime = 4
	end
	
	
	local click = false
	for i=1, #state.buttons do
		if i > 8 and escape then
			if state.buttons[i].bbox:contains_coordinate(mpos.x, mpos.y) == true then
				click = true
			end
		elseif i < 9 then
			if state.buttons[i].bbox:contains_coordinate(mpos.x, mpos.y) == true then
				click = true
			end
		end
	end
    
	if click then
		mouse:setClick(true)
	else
		mouse:setClick(false)
	end
  --love.audio.play(musique)
  
end
  

--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function state.draw_field_vector()
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  local nx, ny, f = state.level.level_map:get_field_vector_at_position({x=mx, y=my})
  
  if f <= 0 then return end
  
  local len = 150
  local width = 10
  local perpx, perpy = -ny, nx
  local x1, y1 = mx - 0.5 * perpx * width, my - 0.5 * perpy * width
  local x2, y2 = mx + 0.5 * perpx * width, my + 0.5 * perpy * width
  local x3, y3 = x2 + len * nx, y2 + len * ny
  local x4, y4 = x1 + len * nx, y1 + len * ny
  
  lg.setColor(255, 255, 255, 255)
  lg.polygon("fill", x1, y1, x2, y2, x3, y3, x4, y4)
  
  local len = f * len
  local x5, y5 = x2 + len * nx, y2 + len * ny
  local x6, y6 = x1 + len * nx, y1 + len * ny
  
  lg.setColor(0, 255, 0, 255)
  lg.polygon("fill", x1, y1, x2, y2, x5, y5, x6, y6)
  lg.setColor(0, 0, 0, 255)
  lg.polygon("line", x1, y1, x2, y2, x3, y3, x4, y4)
end

function food_demo_state.draw()

  --state.hero:draw()
  
  state.level:draw()
  -- draw boids
  state.level.camera:set()
  state.town:draw()
  state.flock:draw()
  
  -- obstacle radius
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mouse = state.level:get_mouse()
  local vx,vy = state.level:get_camera():get_size()
  local mx, my = x + mpos.x, y + mpos.y
  local actionX, actionY = state.block_actions.x, state.block_actions.y
  local firstDance = state.hero:getFirstDance()
  local monX,monY = vx+x,vy+y
  
  --lg.line( x, y, monX, monY)
  
  --state.food_source.debug = true
  --state.food_source:draw()
  
  --state.wood_source.debug = true
  --state.wood_source:draw()
  
  --state.water_source.debug = true
  --state.water_source:draw()
  
  state.town.debug = true
  
  
  lg.setColor(255, 255, 255, 255)
  
  -- obstacle radius
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  --lg.circle("line", mpos.x + x, mpos.y + y, state.point_radius * (1-state.polygonizer_threshold))
    lg.setColor(255, 255, 255, 50)
    if not state.level.level_map.bbox:contains(state.primitive_bbox) then
      lg.setColor(255, 0, 0, 50)
    end
  --lg.circle("line", mpos.x + x, mpos.y + y, state.point_radius)
  
  --state.draw_field_vector()
  --if journeyTime ~= "MIDI" then
  newLightWorld:Draw()
  --end
  --state.draw_field_vector()
  state.level.camera:unset()
  
  local masterTimer = state.level.master_timer:get_time()
  --if masterTimer > 45 then
	
  --end
  if firstDance == false then
	  lg.draw(showEmoteCriImg, actionX+950, actionY+250)
	  lg.setColor(0, 0, 0, 255)
	  lg.setFont(FONTS.rubikMed)
	  lg.print("Get out !", actionX+1100, actionY+350)
  end
  if firstDance == false then return end
  
  
  -- intruction text
  lg.setColor(255, 255, 255, 255)
  lg.draw(fondui, actionX-20, actionY-20)
  
  lg.draw(fonduiBagFond, 20, vy-170)
  local spriteNum = math.floor( tableAnimRessources[1].currentTime /  tableAnimRessources[1].duration * #tableAnimRessources[1].quads) + 1
  love.graphics.draw(tableAnimRessources[1].spriteSheet,  tableAnimRessources[1].quads[spriteNum], 120+1*70, vy-110)
  lg.draw(fonduiBag, 20, vy-170)
  
  
  -- draw buttons
  for i=1,#state.buttons-6 do
    local b = state.buttons[i]
	lg.setColor(255, 255, 255, 255)
	
    if b.toggle then
      lg.draw(buttonpress, actionX, actionY+i*90)
    else
      lg.draw(button, actionX, actionY+i*90)
    end
	if i==1 then
		lg.draw(bushIcon, actionX+10, actionY+i*90+10)
	elseif i==2 then
		lg.draw(treeIcon, actionX+20, actionY+i*90+10)
	elseif i==3 then
		lg.draw(birdIcon, actionX+15, actionY+i*90+20)
	elseif i==4 then
		lg.draw(predatorIcon, actionX+20, actionY+i*90+20)
	elseif i==5 then
		--lg.draw(epIcon, actionX, actionY+i*90)
	end
	--lg.rectangle("fill", 200+i*90,920, 50,50)
  end
  
  
  lg.setColor(255, 255, 255, 255)
  --lg.draw(menuBar, 250, 910)
  
  lg.setColor(255, 255, 255, 255)
  --lg.draw(panelImg, 10, 10)
  --lg.draw(panelImg, 120, 10)
  --lg.draw(panelImg, 240, 10)
  
  
  
  local spriteNum = math.floor( inkReserveImg.currentTime /  inkReserveImg.duration * #inkReserveImg.quads) + 1
  love.graphics.draw(inkReserveImg.spriteSheet,  inkReserveImg.quads[spriteNum], vx-250, 20)
  
  
  
  local spriteNum = math.floor(animationStomach.currentTime / animationStomach.duration * #animationStomach.quads) + 1
  love.graphics.draw(animationStomach.spriteSheet, animationStomach.quads[spriteNum], vx-100, 20)
  
  
  local spriteNum = math.floor(animationEnergy.currentTime / animationEnergy.duration * #animationEnergy.quads) + 1
  love.graphics.draw(animationEnergy.spriteSheet, animationEnergy.quads[spriteNum], vx-175, 20)
  
  lg.setColor(255, 255, 255, 255)
  
  local width = vx
  local height = vy
  
  --lg.draw(foodIcon, 235, 25)
  --lg.draw(nbBoidsIcon, 120, 30)
  --lg.draw(woodIcon, 345, 30)
  lg.setColor(0, 0, 0, 255)
  --lg.print(food, 235, 85)
  --lg.print(nbBoids, 120, 85)

  --lg.print(nbBoids, 50, 180)
  --lg.print(nbBoidsPrey, 125, 170)
  --lg.print(nbBoidsPred, 125, 130)
  --lg.print(journeyTime, 40, 40)
  lg.setColor(255, 255, 255, 255)
  lg.draw(play, actionX+vx/2+150-200, 30)
  lg.draw(pause, actionX+vx/2+100-200, 30)
  lg.draw(fastforward, actionX+vx/2+200-200, 30)
  
  if escape then
	lg.draw(menuFond, actionX+vx/3,vy/4)
	lg.draw(button, actionX+vx/2-210,vy/3-10)
	if FULLSCREEN == 1 then
		lg.draw(fullscreen, actionX+vx/2-195,vy/3)
	else
		lg.draw(fullscreenOn, actionX+vx/2-195,vy/3)
	end
	--lg.setColor(0, 0, 0, 255)
	--lg.print("Recommencer la partie", actionX+vx/2-200,vy/3+100)
	lg.draw(button, actionX+vx/2-210,vy/3+90)
	lg.draw(retryIcon, actionX+vx/2-195,vy/3+110)
	lg.draw(button, actionX+vx/2-210,vy/3+190)
	lg.draw(exitIcon, actionX+vx/2-195,vy/3+208)
	if MUSIC == 1 then
		lg.draw(button, actionX+vx/2+210,vy/3)
		love.graphics.draw(musicImg, actionX+vx/2+215,vy/3+10)
    else
		lg.draw(button, actionX+vx/2+210,vy/3)
		love.graphics.draw(musicOff, actionX+vx/2+215,vy/3+10)
    end
	--lg.print("Quitter le jeu", actionX+vx/2-200,vy/3+200)
  end
  
  if state.selectItem ~=0 and state.selectItem ~=50 then
	local cmx = math.floor(mx/32)
	local cmy = math.floor(my/32)
	
	if state.level:canILandHere(cmx,cmy,10) then
		mouse:setColor(0,0,0)
	else
		mouse:setColor(255,255,255)
	end
  end
  
  --state.flock:draw()
  local boids = state.flock.active_boids
  lg.setColor(255, 255, 255, 1)
  --[[for i=1,#boids do
    boids[i].animation:draw()
  end--]]
  if playIntro then
	lg.draw(voiceImg,0,vy-635)
  end
  
  
  for i=1,#state.buttons do
	--state.buttons[i].bbox:draw()
  end
  
end

return food_demo_state












