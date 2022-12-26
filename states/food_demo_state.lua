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

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_state.keypressed(key)
  state.flock:keypressed(key)
  
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

  state.flock:mousepressed(x, y, button)
  state.level:mousepressed(x, y, button, state.flock)

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
		state.selectItem = 0
	end
  end
  
  ------------------------------------------------------------------AJOUT BOIS
  --[[local p = state.wood_source:add_wood(mx, my, 200)
  state.wood_source:force_polygonizer_update()--]]
    
  if button == 1 and state.selectItem == 3 then
  
	if mx > 5 and mx < 6400 and my > 5 and my < 6400 then
		cmx = math.floor(mx /32)
		cmy = math.floor(my /32)
		if state.level:canILandHere(cmx,cmy,10) then
			--state.hero:putEgg(mx-25,my-25,0)
			state.hero:setRandomPoints(mx,my,0)
		end
	end
	
  end
  if button == 1 and state.selectItem == 1 then
	cmx = math.floor(mx /32)
	cmy = math.floor(my /32)
	print(cmx,cmy)
	if cmx > 5 and cmx < 200 and cmy > 5 and cmy < 200 and state.level:canILandHere(cmx,cmy,10) then
		--map[cmx][cmy] = state.level:addBush(cmx,cmy,state.flock)
		--map[cmx][cmy]:setState(true)
		--map[cmx][cmy]:set_position(cmx,cmy)
		--state.level:setTreeMap(map)
		
		state.hero:setRandomPoints(mx,my,3)
		
		
		--[[save = nil
		save = {"1","2"} -- il faut créer un tableau avec position de chaque arbre/buisson + oiseaux et save les stats des oiseaux
		save = bitser.dumps(save)
		love.filesystem.write("cucu.txt",save)
		local printer = bitser.loads(love.filesystem.read("cucu.txt"))
		print(dump(printer))--]]
		
		--local data = bitser.dumps(map(1))
		--local instance = bitser.loads(data)
	end
	--map[mx][my]:setFlock(state.flock)
  end
   if button == 1 and state.selectItem == 2 then   
	cmx = math.floor(mx /32)
	cmy = math.floor(my /32)
	print("jai le droit de poser un mur ici")
	print(cmx,cmy)
	if state.level:canILandHere(cmx,cmy,10) then
		state.hero:setRandomPoints(mx,my,2)
		--[[
		local level_map = state.level:get_level_map()
		local p = level_map:add_point_to_polygonizer(mx, my, 200)
		level_map:update_polygonizer()
		map[cmx][cmy] = state.level:addRock(cmx,cmy)
		state.primitives[#state.primitives + 1] = p
		if #state.primitives == 1 then
		  state.start_fade()
		end
		level_map:setWallMap()
		--state.level:spawn_cube_explosion(200, 200, 200, 300, 300)
		--]]
	end
  end
  if button == 1 and state.selectItem == 5 then
	
  end
  if button == 1 and state.selectItem == 4 then
	if mx > 5 and mx < 6400 and my > 5 and my < 6400 then
		cmx = math.floor(mx /32)
		cmy = math.floor(my /32)
		if state.level:canILandHere(cmx,cmy,10) then
			--state.hero:putEgg(mx-25,my-25,0)
			state.hero:setRandomPoints(mx,my,0)
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
			
      if b.text == "bush" then
        state.selectItem = 1
      elseif b.text == "tree" then
        state.selectItem = 2
      elseif b.text == "bird" then
        state.selectItem = 3
	  elseif b.text == "pred" then
        state.selectItem = 4
	   elseif b.text == " " then
        state.selectItem = 5
      elseif b.text == "pause" then
		speedTime = 0
		state.selectItem = 0
      elseif b.text == "fastforward" then
		speedTime = 2
		state.selectItem = 50
       elseif b.text == "play" then
		speedTime = 1
		state.selectItem = 50
      elseif b.text == "fullscreen" and escape then
		if love.window.getFullscreen()==true then
			lw.setFullscreen(false)
		else
			lw.setFullscreen(true)
		end
      end
    elseif b.toggle == true then
      if     b.text == "bush" then
        state.selectItem = 1
      elseif b.text == "tree" then
        state.selectItem = 2
      elseif b.text == "bird" then
         state.selectItem = 3
	  elseif b.text == "pred" then
        state.selectItem = 4
	  elseif b.text == " " then
        state.selectItem = 5
      elseif b.text == "pause" then
		speedTime = 0
		state.selectItem = 0
       elseif b.text == "play" then
		speedTime = 1
		state.selectItem = 50
      elseif b.text == "fastforward" then
		speedTime = 2
		state.selectItem = 50
	  elseif b.text == "fullscreen" and escape then
		if love.window.getFullscreen()==true then
			lw.setFullscreen(false)
		else
			lw.setFullscreen(true)
		end
      end
    end
 -- end
  b.toggle = not b.toggle
  print("state.selectItem")
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

end

function food_demo_state.mousereleased(x, y, button)
  state.flock:mousereleased(x, y, button)
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
  
  local tpad = 2
  local x, y = state.level.level_map.bbox.x + tpad * TILE_WIDTH, 
               state.level.level_map.bbox.y + tpad * TILE_HEIGHT
  local width, height = state.level.level_map.bbox.width,--state.level.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        state.level.level_map.bbox.height--state.level.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
  local depth = 1500
  
  local vx,vy = state.level:get_camera():get_size()
  --vx/2-350+i*120, vy-110
  state.block_actions = block_actions:new()
  state.block_actions:set_position(vx/2-350,vy-130)
  local actionX, actionY = state.block_actions.x, state.block_actions.y
  
  state.buttons = {}
  state.buttons[1] = {text="bush", x = actionX+1*120, y = vy-110, toggle = false, 
                      bbox = bbox:new(actionX+1*120, vy-110, 100, 100)}
  state.buttons[2] = {text="tree", x = actionX+2*120, y = vy-110, toggle = false, 
                      bbox = bbox:new(actionX+2*120, vy-110, 100, 100)}
  state.buttons[3] = {text="bird", x = actionX+3*120, y = vy-110, toggle = false, 
                      bbox = bbox:new(actionX+3*120, vy-110, 100, 100)}
  state.buttons[4] = {text="pred", x = actionX+4*120, y = vy-110, toggle = false, 
                      bbox = bbox:new(actionX+4*120, vy-110, 100, 100)}
  state.buttons[5] = {text="pred", x = actionX+5*120, y = vy-110, toggle = false, 
                      bbox = bbox:new(actionX+5*120, vy-110, 100, 100)}
  
  state.flock = flock:new(state.level,"boid", x+100, y+100, width-100, height-100, depth)
  state.flock:set_gradient(require("gradients/named/whiteblack"))
  local x, y, z = 1200, 300, 500
  local dx, dy, dz = 0, 1, 0.5
  local r = 200
  
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
  
  local spritesheet = love.graphics.newImage("images/animations/boidsheet.png")
  local data = require("images/animations/boidsheet_data")
  state.boid_hash = {}
  state.animation_set = animation_set:new(spritesheet, data)
  
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
  
  state.food_source = boid_food_source:new(state.level, state.flock)
  --state.wood_source = boid_wood_source:new(state.level, state.flock)
  state.water_source = boid_water_source:new(state.level, state.flock)
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
 
  button = love.graphics.newImage("images/Jungle/upgrade/btn.png")
  buttonpress = love.graphics.newImage("images/Jungle/upgrade/btn-push.png")
  panelImg = love.graphics.newImage("images/PNG/panel_beige.png")
  foodIcon = love.graphics.newImage("images/ui/food.png")
  nbBoidsIcon = love.graphics.newImage("images/ui/nbBoids.png")
 
  birdIcon = love.graphics.newImage("images/env/bird.png")
  bushIcon = love.graphics.newImage("images/env/Bush2-1x1.png")
  predatorIcon = love.graphics.newImage("images/env/predator.png")
  treeIcon = love.graphics.newImage("images/env/treeIcon.png")
  rockIcon = love.graphics.newImage("images/env/rockIcon.png")
  
  menuFond = love.graphics.newImage("images/Jungle/pause/table.png")
  menuTxt = love.graphics.newImage("images/Jungle/pause/text.png")
  
  pause = love.graphics.newImage("images/Black/1x/pause.png")
  play = love.graphics.newImage("images/Black/1x/forward.png")
  fastforward = love.graphics.newImage("images/Black/1x/fastForward.png")
  fullscreen = love.graphics.newImage("images/Black/1x/smaller.png")
  width = pause:getWidth()
  height = pause:getHeight()
  
  state.buttons[6] = {text="pause", x = actionX+100, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+100, 30, 50, 50)}
  state.buttons[7] = {text="play", x = actionX+150, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+150, 30, 50, 50)}
  state.buttons[8] = {text="fastforward", x = actionX+200, y = 30, toggle = true, 
                      bbox = bbox:new(actionX+200, 30, 50, 50)}
  state.buttons[9] = {text="fullscreen", x = vx/2-vx/4+50, y = vy/2-vy/4+50, toggle = true, 
                      bbox = bbox:new(vx/2-vx/4+200, vy/2-vy/4+200, 100, 100)}						  
	
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
	
	for x=5, 200 do--Poly.rows-5 do
		for y=5, 200 do--Poly.cols-5 do
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
					--state.hero:set_posX(randX+50)
					--state.hero:set_posY(randY+50)
								
					
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
					state.level:setFlock(state.flock)
				end
				if level[caseX][caseY]~=nil then
					if count<nbNids and level[caseX][caseY]:getNumEmits()==0 and level[caseX][caseY].name<51 then
						print('ajout de nid')
						local emit = state.level:addHome(randX-35,randY-60,10,10,0,state.flock,state.level,10,0)
						level[caseX][caseY]:add(emit)
						level[caseX][caseY]:setNumEmits(1)
						count = count + 1
						state.hero:set_posX(randX+50)
						state.hero:set_posY(randY+50)
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
				elseif state.level:canILandHere(caseX,caseY,30) then
					if caseX<190 and caseY<190 and caseX>10 and caseY>10 and countRock<10 then
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
					end
					if math.random(1,1000)==1 and caseX<160 and caseY<160 and caseX>40 and caseY>40 and countTown<1 then
						local randX = 32*x
						local randY = 32*y
						countTown = countTown + 1
						food_demo_state.createTown(randX,randY,100)
					end
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
		local p = level_map:add_point_to_polygonizer(x*32, 200, 200)
		state.primitives[#state.primitives + 1] = p
			if #state.primitives == 1 then
			state.start_fade()
			end
		local p = level_map:add_point_to_polygonizer(x*32, 6100+randY, 250)
		state.primitives[#state.primitives + 1] = p
			if #state.primitives == 1 then
			state.start_fade()
		end	
	end
	
	for y=0,Poly.cols do
		local randX = math.random(-50,50)
		local p = level_map:add_point_to_polygonizer(300+randX, y*32, 250)
		state.primitives[#state.primitives + 1] = p
			if #state.primitives == 1 then
			state.start_fade()
			end
		local randX = math.random(-50,50)
		local p = level_map:add_point_to_polygonizer(6100+randX, y*32, 250)
		state.primitives[#state.primitives + 1] = p
			if #state.primitives == 1 then
			state.start_fade()
			end	
	end--]]
	
	level_map:update_polygonizer()
	level_map:setWallMap()
	state.level:setTreeMap(level)
	state.nbHome = state.nbHome -1	
	
	music = love.audio.newSource("sound/airtone2.mp3", "stream")
	music:setVolume(1)
	--love.audio.play(music)
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

function food_demo_state.resize(w, h)

  
  --[[local vx,vy = state.level:get_camera():get_size()
  print(("Window resized to width: %d and height: %d."):format(w, h))
  --scale = scale + 1000
  scaleNow = true
  local hpos =  state.hero:get_pos()
  local cam = state.level:get_camera()
  local x, y = cam:get_viewport()
  state.block_actions:set_position(w/2-350+1*120,h-110)
  local actionX, actionY = state.block_actions.x, state.block_actions.y
  local target = vector2:new(hpos.x, hpos.y)
  local camPos = cam:get_center()
  --state.hero:set_position(target)
  print("go target")
  print(target)
   
  
  for i=1,#state.buttons do
    local b = state.buttons[i]
	lg.setColor(255, 255, 255, 255)
	if i<6 then
		b.x = w/2-350+i*120
		b.y = h-110
		b.bbox:set(w/2-350+i*120, h-110, 100, 100)
	elseif i == 6 then
		b.x = w-200
		b.y = 30
		b.bbox:set(w-200, 30, 50, 50)
	elseif i == 7 then
		b.x = w-150
		b.y = 30
		b.bbox:set(w-150, 30, 50, 50)
	elseif i == 8 then
		b.x = w-100
		b.y = 30
		b.bbox:set(w-100, 30, 50, 50)
	end
	--lg.rectangle("fill", 200+i*60,920, 50,50)
  end
  
  if w > 1920 then
    camPos.x = camPos.x + 200
	camPos.y = camPos.y + 200
	cam:set_target(camPos, true)
  end--]]
  
  
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
  local speed = 15
  local cam = state.level:get_camera()
  local x, y = cam:get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local vx,vy = cam:get_size()
  local mx, my = x + mpos.x, y + mpos.y
  local camPos = cam:get_center()
  --local dt = 0.004
  
  --print("camPos")
  --print(camPos)
  if lk.isDown("w", "up") or lk.isDown("a", "left") or lk.isDown("s", "down") or lk.isDown("d", "right") then
	  if lk.isDown("w", "up") then
		ty = ty - speed
		state.hero:goDirection(1)
	  end
	  if lk.isDown("a", "left") then
		tx = tx - speed
		state.hero:goDirection(2)
	  end
	  if lk.isDown("s", "down") then
		ty = ty + speed
		state.hero:goDirection(3)
	  end
	  if lk.isDown("d", "right") then
		tx = tx + speed
		state.hero:goDirection(4)
	  end
	  if lk.isDown("space") then
		state.hero:goDirection(6)
	  end
	  target.x, target.y = target.x + tx, target.y + ty
	  
	  local block = state.hero:canIGoHere(target)
	  if target.x>30 and target.y>30 and target.x<ACTIVE_AREA_WIDTH-30 and target.y<ACTIVE_AREA_HEIGHT-30 and block==false then
		state.hero:set_position(target,true)
		state.hero:set_target(target.x, target.y)
		cam:set_target(target,true)
		state.hero:resetBlock()
	  end
  else
	state.hero:goDirection(5)
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
  local speedSpeed = speedTime
  if speedSpeed==0 then 
	if state.level.master_timer.is_stopped == false then
		state.level.master_timer:stop()
	end
    dt = 0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
  elseif speedSpeed==1 then
	  if state.level.master_timer.is_stopped == true then
			state.level.master_timer:start()
	  end
	dt = math.min(dt, 1/20)
  elseif speedSpeed==2 then
	dt = math.min(dt*10, 1/2)
  end
  
  state.level:update(dt)
  --state.emitter:update(dt)
  state.food_source:update(dt)
  --state.wood_source:update(dt)
  state.water_source:update(dt)
  state.town:update(dt)
  --state.emitter2:update(dt)
  state.flock:update(dt)
  --state.flock2:update(dt)
  --state.hero:update(dt)
  state.animation_set:update(dt)
  
  flux.update(dt)
  
  --nbBoids = state.emitter:getnbBoids()
	
  
  --[[local boids = state.flock.active_boids
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
    b.animation:set_position(b.position.x, b.position.y)
  end--]]
  
  -- update fade
  if state.is_fading then
    state.current_time = state.current_time + dt
  end
  
   local r = state.point_radius
  local b = state.primitive_bbox
  b.x, b.y = mx - r, my - r
  b.width, b.height = 2 * r, 2 * r
  
  local local_time = math.floor(state.level.master_timer:get_time())
  
  if local_time>25 and local_time<40 then
	journeyTime = "MIDI"
  elseif local_time>41 and local_time<70 then
	journeyTime = "SOIR"
  elseif local_time>71 and local_time<100 then
	journeyTime = "NUIT"
  elseif local_time>1 and local_time<24 then
	journeyTime = "MATIN"
	state.call=0
  end
  
  if os.time() >= endTime then
	endTime = endTime + 1
	if journeyTime == "SOIR" and state.call<6 then
		local boids = state.flock.active_boids
		if #boids > 10 then
			nbGrpBird = math.floor(#boids/5)
			local call = state.call
			for i=1+call*nbGrpBird,nbGrpBird*(call+1) do
				local boid = boids[i]
				if boid then
					if boid.free == false then
						boid.path=nil
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
						boid.path=nil
						boid:goHome()
					end
				end
				--boid.rule_weights[boid.separation_vector] = 0.1
			end
			state.call=state.call+1
		end
	end
	if journeyTime == "NUIT" then
	    --local actualFood = state.level:getFood()
		state.level:_feed_boids()
	end
  end
  food = state.level:getFood()
  wood = state.level:getWood()
  nbBoids,nbBoidsPrey,nbBoidsPred = state.level:getBoids()
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
  
  state.flock:draw()
  
  -- obstacle radius
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mouse = state.level:get_mouse()
  local vx,vy = state.level:get_camera():get_size()
  local mx, my = x + mpos.x, y + mpos.y
  local actionX, actionY = state.block_actions.x, state.block_actions.y
  
  local monX,monY = vx+x,vy+y
  
  --lg.line( x, y, monX, monY)
  
  state.food_source.debug = true
  state.food_source:draw()
  
  --state.wood_source.debug = true
  --state.wood_source:draw()
  
  state.water_source.debug = true
  state.water_source:draw()
  
  state.town.debug = true
  state.town:draw()
  
  lg.setColor(255, 255, 255, 255)
  
  
  --state.draw_field_vector()
  state.level.camera:unset()
  
  
  -- intruction text
  lg.setColor(255, 255, 255, 255)
  lg.setFont(FONTS.bebas_text)
  
  -- draw buttons
  lg.setFont(FONTS.bebas_text)
  for i=1,#state.buttons-5 do
    local b = state.buttons[i]
	lg.setColor(255, 255, 255, 255)
    if b.toggle then
      love.graphics.draw(buttonpress, actionX+i*120, actionY)
    else
      love.graphics.draw(button, actionX+i*120, actionY)
    end
	if i==1 then
		love.graphics.draw(bushIcon, actionX+i*120, actionY+20)
	elseif i==2 then
		love.graphics.draw(treeIcon, actionX+i*120, actionY+20)
	elseif i==3 then
		love.graphics.draw(birdIcon, actionX+i*120, actionY+20)
	elseif i==4 then
		love.graphics.draw(predatorIcon, actionX+i*120, actionY+20)
	end
	--lg.rectangle("fill", 200+i*60,920, 50,50)
  end
  lg.setColor(255, 255, 255, 255)
  --love.graphics.draw(menuBar, 250, 910)
  
  lg.setFont(FONTS.courier_small)
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(panelImg, 10, 10)
  love.graphics.draw(panelImg, 120, 10)
  love.graphics.draw(panelImg, 10, 120)
  love.graphics.draw(panelImg, 240, 10)
  
  lg.setColor(0, 0, 0, 255)
  
  local width = vx
  local height = vy
  
  love.graphics.draw(foodIcon, 150, 20)
  love.graphics.draw(nbBoidsIcon, 30, 130)
  lg.setColor(0, 0, 0, 255)
  lg.print(food, 150, 60)
  lg.print(wood, 280, 50)
  lg.print(nbBoids, 50, 180)
  lg.print(nbBoidsPrey, 125, 170)
  lg.print(nbBoidsPred, 125, 130)
  lg.print(journeyTime, 40, 40)
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(play, actionX+150, 30)
  love.graphics.draw(pause, actionX+100, 30)
  love.graphics.draw(fastforward, actionX+200, 30)
  
  if escape then
	love.graphics.draw(menuFond, width/2-width/4,height/2-height/4)
	love.graphics.draw(button, width/2-width/4+200,height/2-height/4+200)
	love.graphics.draw(fullscreen, width/2-width/4+200,height/2-height/4+200)
  end
  
  if state.selectItem ~=0 then
	local cmx = math.floor(mx/32)
	local cmy = math.floor(my/32)
	if state.level:canILandHere(cmx,cmy,10) then
		mouse:setColor(0)
	else
		mouse:setColor(200)
	end
  end
  
  --state.flock:draw()
  --[[local boids = state.flock.active_boids
  for i=1,#boids do
    boids[i]:draw_shadow()
  end
  lg.setColor(255, 255, 255, 255)
  for i=1,#boids do
    boids[i].animation:draw()
  end--]]
  
end

return food_demo_state












