local food_demo_state = state:new()
food_demo_state.label = 'food_demo_state'
local state = food_demo_state
local food = 10
local wood = 30
local nbBoids = 0
local speedTime = 1
local journeyTime = "Matin"
local startTime = os.time()
local endTime = startTime+1
local feed = false
local map = {}
local click = nil

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function food_demo_state.keypressed(key)
  state.flock:keypressed(key)
  
  if key == "return" then
    BOIDS:load_next_state()
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
function food_demo_state.mousepressed(x, y, button)

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
  local buttons = state.buttons
  if button == 2 then
    local button = buttons[state.selectItem]
	if button then
		food_demo_state.toggle_button(button)
		state.selectItem = 20
	end
  end

  state.flock:mousepressed(x, y, button)
  print("BUTTO")
  print(button)
  state.level:mousepressed(x, y, button)
  
  if button == 1 and state.selectItem == 3 then
	local x, y = state.level:get_camera():get_viewport()
	local mpos = state.level:get_mouse():get_position()
	local mx, my = x + mpos.x, y + mpos.y
    
    local level_map = state.level:get_level_map()
    local p = level_map:add_point_to_polygonizer(mx, my, 100)
    level_map:update_polygonizer()
    
    state.primitives[#state.primitives + 1] = p
    if #state.primitives == 1 then
      state.start_fade()
    end	
	--state.level:spawn_cube_explosion(200, 200, 200, 300, 300)
	
  end
  if button == 1 and state.selectItem == 2 then
	local x, y = state.level:get_camera():get_viewport()
	local mpos = state.level:get_mouse():get_position()
	local mx, my = x + mpos.x, y + mpos.y
	local p = state.food_source:add_food(mx, my, 1)
    state.food_source:force_polygonizer_update()
    state.primitives[#state.primitives + 1] = p
    if #state.primitives == 1 then
      state.start_fade()
    end
    
  end
   if button == 1 and state.selectItem == 4 then
	local x, y = state.level:get_camera():get_viewport()
	local mpos = state.level:get_mouse():get_position()
	local mx, my = x + mpos.x, y + mpos.y
	local p = state.wood_source:add_wood(mx, my, 100)
    state.wood_source:force_polygonizer_update()
    state.primitives[#state.primitives + 1] = p
    if #state.primitives == 1 then
      state.start_fade()
    end
  end
  if button == 1 and state.selectItem == 5 then
	
  end
  if button == 1 and state.selectItem == 1 then
	
  end
  
  
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  
  
  myText = mpos.y
  for i=1,#buttons do
    local b = buttons[i]
    if b.bbox:contains_coordinate(mpos.x, mpos.y) then
      food_demo_state.toggle_button(b)
	  if b.toggle == true and state.selectItem == 20 then
		b.toggle = false
	  end
      return
    end
  end
  
  
end
food_demo_state.toggle_button = function(b)
  --local boids = state.flock.active_boids
  myText = b.text
  --for i=1,#boids do
	myText = b.text
    --local boid = boids[i]
    if     b.toggle == false then
			
      if b.x == 260 then
        state.selectItem = 1
      elseif b.x == 320 then
        state.selectItem = 2
      elseif b.x == 380 then
        state.selectItem = 3
	  elseif b.x == 440 then
        state.selectItem = 4
	   elseif b.x == 500 then
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
      end
    elseif b.toggle == true then
      if     b.x == 260 then
        state.selectItem = 1
      elseif b.x == 320 then
        state.selectItem = 2
      elseif b.x == 380 then
         state.selectItem = 3
	  elseif b.x == 440 then
        state.selectItem = 4
	  elseif b.x == 500 then
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
	  end
    end
 -- end
  b.toggle = not b.toggle
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
  local width, height = state.level.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        state.level.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
  local depth = 1500
  
  state.buttons = {}
  state.buttons[1] = {text="", x = 260, y = 910, toggle = false, 
                      bbox = bbox:new(260, 910, 50, 50)}
  state.buttons[2] = {text="", x = 320, y = 910, toggle = false, 
                      bbox = bbox:new(320, 910, 50, 50)}
  state.buttons[3] = {text="", x = 380, y = 910, toggle = false, 
                      bbox = bbox:new(380, 910, 50, 50)}
  state.buttons[4] = {text="", x = 440, y = 910, toggle = false, 
                      bbox = bbox:new(440, 910, 50, 50)}
  state.buttons[5] = {text="", x = 500, y = 910, toggle = false, 
                      bbox = bbox:new(500, 910, 50, 50)}
  
  state.flock = flock:new(state.level,"boid", x, y, width, height, depth)
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
  state.wood_source = boid_wood_source:new(state.level, state.flock)
  state.town = town:new(state.level, state.flock)
  state.hero = hero:new(state.level, state.flock, 100, 100)
  
  state.level:set_player(state.hero)

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
  
  musique = love.audio.newSource("sound/wilds.mp3", "stream")
 
  button = love.graphics.newImage("images/PNG/grey_button10.png")
  buttonpress = love.graphics.newImage("images/PNG/grey_button11.png")
  panelImg = love.graphics.newImage("images/PNG/panel_beige.png")
  foodIcon = love.graphics.newImage("images/ui/food.png")
  nbBoidsIcon = love.graphics.newImage("images/ui/nbBoids.png")
 
  -- speed up/slow down buttons
  local speedb = {}
  local text = "descend vit"
  local tw1, th1 = FONTS.bebas_smallest:getWidth(text), FONTS.bebas_smallest:getHeight(text)
  local pad = 5
  local offx, offy = 5, 0
  local x, y = 0 + offx, SCR_HEIGHT - th1 + offy
  speedb.slow = {font = FONTS.bebas_smallest,
                 text = text,
                 state = false,
                 x = x,
                 y = y,
                 bbox = bbox:new(x-pad, y-pad, tw1 + 2*pad, th1 + 2*pad)}
  local text = "monte vit"
  local tw2, th2 = FONTS.bebas_smallest:getWidth(text), FONTS.bebas_smallest:getHeight(text)
  local offx, offy = 10, 0
  local x, y = x + tw1 + offx, SCR_HEIGHT - th2 + offy
  speedb.fast = {font = FONTS.bebas_smallest,
                 text = text,
                 state = false,
                 x = x,
                 y = y,
                 bbox = bbox:new(x-pad, y-pad, tw2 + 2*pad, th2 + 2*pad)}
  state.speedb = speedb
  
  pause = love.graphics.newImage("images/Black/1x/pause.png")
  play = love.graphics.newImage("images/Black/1x/forward.png")
  fastforward = love.graphics.newImage("images/Black/1x/fastForward.png")
  width = pause:getWidth()
  height = pause:getHeight()
  
  state.buttons[6] = {text="pause", x = 1600, y = 30, toggle = true, 
                      bbox = bbox:new(1600, 30, 50, 50)}
  state.buttons[7] = {text="play", x = 1650, y = 30, toggle = true, 
                      bbox = bbox:new(1650, 30, 50, 50)}
  state.buttons[8] = {text="fastforward", x = 1700, y = 30, toggle = true, 
                      bbox = bbox:new(1700, 30, 50, 50)}					  
	
	local level_map = state.level:get_level_map()	
	local Poly = level_map.polygonizer
	local w, h = Poly.cell_width, Poly.cell_height
	
	print("position")
	print(w)
	
	for x = 1, Poly.rows do
		map[x] = {}
		for y = 1, Poly.cols do
			map[x][y] = nil
		end
	end
	
	for x=5,Poly.rows-5 do
		for y=5,Poly.cols-5 do
			local randX = 32*y
			local randY = 32*x
			local caseX = math.floor( randX / h ) + 1
			local caseY = math.floor( randY / w ) + 1
			--if math.random()>0.99 then
			if (caseX==15 and caseY==15) or (caseX==35 and caseY==10) or (caseX==55 and caseY==10)  then
				--print("position")
				--print(caseX)				
				--local p = level_map:add_point_to_polygonizer(randX, randY, 1)
				--level_map:update_polygonizer()
				--state.primitives[#state.primitives + 1] = p
				--if #state.primitives == 1 then
				 -- state.start_fade()
				--end
				map[caseX][caseY] = state.level:addTree(0)
				map[caseX][caseY]:set_position(randX,randY)
				map[caseX][caseY]:setNumEmits(1)
				state.level:addHome(randX,randY-20,10,10,0,state.flock,state.level,50)
			elseif (math.random()>0.995) then
				map[caseX][caseY] = state.level:addTree(0)
				map[caseX][caseY]:setNumEmits(0)
			else
				--map[caseX][caseY] = state.level:addTree(0)
				if math.random()>0.9985 then
					for i=1,math.random(1,10) do
						local p = level_map:add_point_to_polygonizer(math.random(randX-200,randX+200), math.random(randY-200,randY+200), 0)
						level_map:update_polygonizer()
						
						state.primitives[#state.primitives + 1] = p
						if #state.primitives == 1 then
						  state.start_fade()
						end	
					end
				end
			end
			if (caseX==7 and caseY==8) then
				--food_demo_state.createTown(500,500,100)
			end
		end
	end	
	state.level:setTreeMap(map)
	state.buttons[1].text = ""
	state.nbHome = state.nbHome -1	
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
  local speed = 1000
  local cam = state.level:get_camera()
  --local dt = 0.004
  if lk.isDown("w", "up") then
    ty = ty - speed * dt
	state.hero:goDirection(1)
  elseif lk.isDown("a", "left") then
    tx = tx - speed * dt
	state.hero:goDirection(2)
  elseif lk.isDown("s", "down") then
    ty = ty + speed * dt
	state.hero:goDirection(3)
  elseif lk.isDown("d", "right") then
    tx = tx + speed * dt
	state.hero:goDirection(4)
  elseif lk.isDown("space") then
	state.hero:goDirection(6)
  else
	state.hero:goDirection(5)
  end
  
  local speedSpeed = speedTime
  target.x, target.y = target.x + tx, target.y + ty
  
  local block = state.hero:canIGoHere(target)
  if target.x>100 and target.y>100 and target.x<ACTIVE_AREA_WIDTH-100 and target.y<ACTIVE_AREA_HEIGHT-100 and block==false then
	state.hero:set_position(target)
  end
  state.hero:resetBlock()
  cam:set_target(target, true)
  if speedSpeed==0 then 
	if state.level.master_timer.is_stopped == false then
		state.level.master_timer:stop()
	end
    dt = 0.000000000000000000000000001 
  elseif speedSpeed==1 then
	  if state.level.master_timer.is_stopped == true then
			state.level.master_timer:start()
	  end
	--dt = 0.004
  elseif speedSpeed==2 then
	dt = 0.01
  end
  
  state.level:update(dt)
  --state.emitter:update(dt)
  state.food_source:update(dt)
  state.wood_source:update(dt)
  state.town:update(dt)
  --state.emitter2:update(dt)
  state.flock:update(dt)
  --state.flock2:update(dt)
  state.hero:update(dt)
  state.animation_set:update(dt)
  
  --nbBoids = state.emitter:getnbBoids()

  local x, y = cam:get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  
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
    b.animation:set_position(b.position.x, b.position.y)
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
  
  if local_time>25 and local_time<40 then
	journeyTime = "MIDI"
  elseif local_time>41 and local_time<70 then
	journeyTime = "SOIR"
  elseif local_time>71 and local_time<100 then
	journeyTime = "NUIT"
  elseif local_time>1 and local_time<24 then
	journeyTime = "MATIN"
	feed=false
  end
  
  if os.time() >= endTime then
	endTime = endTime +1
	if journeyTime == "SOIR" then
		local boids = state.flock.active_boids
			for i=1,#boids do
				local boid = boids[i]
				boid:goHome()
				--boid.rule_weights[boid.separation_vector] = 0.1
			end
	end
	if journeyTime == "NUIT" then
	    --local actualFood = state.level:getFood()
		state.level:_feed_boids()
	end
	food = state.level:getFood()
    wood = state.level:getWood()
	nbBoids = state.level:getBoids()
  end
  
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
  state.level:draw()
  -- draw boids
  state.level.camera:set()
  --state.emitter:draw()
  
  state.hero:draw()
  state.flock:draw()
  
  local canDraw = true
  -- obstacle radius
  local x, y = state.level:get_camera():get_viewport()
  local mpos = state.level:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  
  state.food_source.debug = true
  state.food_source:draw()
  
  state.wood_source.debug = true
  state.wood_source:draw()
  
  state.town.debug = true
  state.town:draw()
  
  lg.setColor(255, 255, 255, 255)
  if not state.level.level_map.bbox:contains(state.primitive_bbox) then
    canDraw = false
  end
  
  
  --state.draw_field_vector()
  state.level.camera:unset()
  
  
  -- intruction text
  local x, y = 20, 900
  lg.setColor(255, 255, 255, 255)
  lg.setFont(FONTS.bebas_text)
  local txt
  if not state.is_fade_active then
    state.fade_text = txt
    --lg.print(txt, x, y)
  else
    state.current_time = state.current_time + love.timer.getDelta()
    local t = math.min(state.fade_time, state.current_time)
    if state.current_time > 2 * state.fade_time then
      state.is_fade_active = false
    end
    
    local prog = t / state.fade_time
    prog = 1 - prog * prog * (3 - 2 * prog)
    local min, max = 0, 255
    local alpha = lerp(min, max, prog)
    lg.setColor(255, 255, 255, alpha)
    --lg.print(state.fade_text, x, y)
  end
  
  
  local x, y = 250, 910
  -- draw buttons
  lg.setFont(FONTS.bebas_text)
  for i=1,#state.buttons-4 do
    local b = state.buttons[i]
	lg.setColor(255, 255, 255, 255)
    if b.toggle then
      love.graphics.draw(buttonpress, 200+i*60, 920)
    else
      love.graphics.draw(button, 200+i*60, 920)
    end
	--lg.rectangle("fill", 200+i*60,920, 50,50)
  end
  lg.setColor(255, 255, 255, 255)
  --love.graphics.draw(menuBar, 250, 910)
  
  
  -- draw speed buttons
  local b = state.speedb
  if b.slow.state then
    lg.setColor(0, 255, 0, 255)
  else
    lg.setColor(0, 0, 0, 100)
  end
  lg.setFont(b.slow.font)
  lg.print(b.slow.text, b.slow.bbox.x, b.slow.bbox.y)
  
  if b.fast.state then
    lg.setColor(0, 255, 0, 255)
  else
    lg.setColor(0, 0, 0, 100)
  end
  lg.setFont(b.fast.font)
  lg.print(b.fast.text, b.fast.bbox.x, b.fast.bbox.y)
  
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(panelImg, 10, 10)
  love.graphics.draw(panelImg, 120, 10)
  love.graphics.draw(panelImg, 10, 120)
  love.graphics.draw(panelImg, 240, 10)
  
  lg.setColor(0, 0, 0, 255)
  
  love.graphics.draw(foodIcon, 150, 20)
  love.graphics.draw(nbBoidsIcon, 30, 130)
  lg.setColor(0, 0, 0, 255)
  lg.print(food, 150, 60)
  lg.print(wood, 280, 50)
  lg.print(nbBoids, 50, 170)
  lg.print(journeyTime, 40, 40)
  lg.setColor(255, 255, 255, 255)
  love.graphics.draw(play, 1650, 30)
  love.graphics.draw(pause, 1600, 30)
  love.graphics.draw(fastforward, 1700, 30)
  
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












