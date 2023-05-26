
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- level object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local level = {}
level.table = 'level'
level.tile_palette = nil
level.master_timer = nil
level.hero = nil
level.camera = nil
level.screen_canvas = nil
level.level_map = nil
level.audio_set = nil
level.collider = nil
level.mouse = nil
level.active_area_bbox = nil

level.animation_sets = nil
level.shard_sets = nil
level.shard_explosions = nil

level.emitters = {}

level.eggs = {}
level.nbEggs = 1
level.treeSelect = nil
level.trees = {}
level.bushs = {}
level.nuages = {}


-- cube explosions
level.cube_motion_curves = nil
level.cube_height_curves = nil
level.cube_shard_set = nil
level.min_num_cubes = 5
level.max_num_cubes = 15
level.cube_min_radius = 500
level.cube_max_radius = 1000

-- tile explosions
level.tile_explosion_is_initialized = false
level.tile_explosions = nil
level.tile_explosion_fade_curves = nil
level.tile_explosion_flash_curves = nil
level.tile_explosion_min_radius = 150
level.tile_explosion_max_radius = 400

-- sounds
level.audio_sample_sets = nil
level.explosion_sample_set = nil

-- camera shake
level.camera_shake_enabled = true

-- explosion sound effects
level.explosion_sound_effect_volume = 0.3
level.explosion_sound_effect_launch_time = 0.08
level.explosion_sound_effect_min_num_samples = 1
level.explosion_sound_effect_max_num_samples = 3
level.explosion_sound_effect_radius = 1000
level.explosion_sound_effect_spread = 50

level.food = 0
level.wood = 0
level.treeMap = nil
level.pollution = 10
level.wood_source = {}
level.initMap=false

level.nbTree = 0
level.nbNuage = 0

level.imageAnimationBushInspire = nil
level.imageAnimationBushExpire = nil
level.imageAnimationBushBirth = nil
level.imageAnimationBigBushInspire = nil
level.imageAnimationBigBushExpire = nil

level.imageAnimationTreeInspire = nil
level.imageAnimationTreeExpire = nil
level.imageAnimationTreeBirth = nil
level.imageAnimationBigTreeInspire = nil
level.imageAnimationBigTreeExpire = nil
level.imageAnimationOmbre = nil
level.imageAnimationOmbreBirth = nil

level.imageAnimationnuage = nil

level.boids = 0
level.boidPrey = 0
level.boidPred = 0


local level_mt = { __index = level }
function level:new()
  local level = setmetatable({}, level_mt)
  level.master_timer = master_timer:new()
  level.audio_set = asset_set:new()
  level.animation_sets = {}
  level.shard_sets = {}
  level.shard_explosions = {}
  level.cube_motion_curves = {}
  level.cube_height_curves = {}

  
  level.tile_explosions = {}
  level.tile_explosion_fade_curves = {}
  level.tile_explosion_flash_curves = {}
  level.audio_sample_sets = {}
  
  level.eggs = {}
  level.nbEggs = 1
  
  level.screen_canvas = lg.newCanvas(SCR_WIDTH, SCR_HEIGHT)
  
  level.imageAnimationBushInspire = love.graphics.newImage("images/bushInspire.png")
  level.imageAnimationBushExpire = love.graphics.newImage("images/bushExpire.png")
  level.imageAnimationBushBirth = love.graphics.newImage("images/birthBush.png")
  level.imageAnimationBigBushInspire = love.graphics.newImage("images/bigBushInspire.png")
  level.imageAnimationBigBushExpire = love.graphics.newImage("images/bigBushExpire.png")
  
  level.imageAnimationTreeInspire = love.graphics.newImage("images/treeInspire.png")
  level.imageAnimationTreeExpire = love.graphics.newImage("images/treeExpire.png")
  level.imageAnimationTreeBirth = love.graphics.newImage("images/birthTree.png")
  level.imageAnimationBigTreeInspire = love.graphics.newImage("images/bigTreeInspire.png")
  level.imageAnimationBigTreeExpire = love.graphics.newImage("images/bigTreeExpire.png")
  level.imageAnimationOmbre = love.graphics.newImage("images/ombreTree.png")
  level.imageAnimationOmbreBirth = love.graphics.newImage("images/ombreTreeBirth.png")
  
  level.imageAnimationNuage = love.graphics.newImage("images/nuage.png")
  
  level:init()
  
  return level
end

function level:init()
   --self.wood_source = boid_wood_source:new(self)
   
end

function level:newAnimation(image, width, height, duration)
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

function level:load()
  self.level_map:load()
  self.audio_set:load()
end

function level:is_loaded()
  local map_loaded = false
  if self.level_map then
    map_loaded = self.level_map:is_loaded()
	--self.wood_source = boid_wood_source:new(self)
  end
  
  local audio_loaded = false
  if self.audio_set then
    audio_loaded = self.audio_set:is_loaded()
  end
  return map_loaded and audio_loaded
end

function level:setFlock(flock)
	if #self.wood_source>0 then
		for i=1, #self.wood_source do
			self.wood_source[i] = boid_wood_source:new(self, flock)
		end
	end
	--self.wood_source:setFlock(flock)
end

----- set
function level:set_camera(camera)
  self.camera = camera
  
  -- compute active area
  local center = camera:get_center()
  local x, y = 0,0--center.x - 0.5 * ACTIVE_AREA_WIDTH, center.y - ACTIVE_AREA_HEIGHT
  self.active_area_bbox = bbox:new(x, y, ACTIVE_AREA_WIDTH, ACTIVE_AREA_HEIGHT)
end

function level:set_camera_shake_curves(xcurves, ycurves)
  if self.camera then
    self.camera:set_shake_curves(xcurves, ycurves)
    self.camera_shake_enabled = true
  end
end

function level:addHome(x,y,width,height,depth,flock,level,nbEggs, boidType)
	local tpad = 2
	local width, height = self.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        self.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
	local depth = 1500
	local dx, dy, dz = 0, 1, 0.5
	local r = 200
	local lvl = level
	
	local emitter = boid_emitter:new(lvl, flock, x, y, z, dx, dy, dz, r, nbEggs, boidType)
	emitter:set_dead_zone( 0, 4000, 3000, 100)
	emitter:set_type("boid")
	emitter:set_emission_rate(200)
	emitter:set_boid_limit(2000)
	emitter:set_position(x,y,100)
	emitter:start_emission()
	self.emitters[#self.emitters + 1] = emitter
	
	if #self.emitters < 10 then
		emitter:add_food(0)
		emitter:add_wood(0)
	end
	return emitter
end

function level:addPredatorHome(x,y,width,height,depth,flock,level,nbEggs)
	local tpad = 2
	local width, height = self.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        self.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
	local depth = 1500
	local dx, dy, dz = 0, 1, 0.5
	local r = 200
	local lvl = level
	
	local emitter = predator_emitter:new(lvl, flock, x, y, z, dx, dy, dz, r, nbEggs)
	emitter:set_dead_zone( 0, 4000, 3000, 100)
	emitter:set_emission_rate(200)
	emitter:set_boid_limit(2000)
	emitter:set_position(x,y,100)
	emitter:start_emission()
	self.emitters[#self.emitters + 1] = emitter
	
	if #self.emitters == 1 then
		--self.emitters[1]:add_food(1000)
		--self.emitters[1]:add_wood(1000)
	end
	return emitter
end

function level:set_level_map(level_map)
  self.level_map = level_map
end

function level:get_level_map()
  return self.level_map
end

function level:canILandHere(caseX,caseY,r)
  local treeMap = self.treeMap
  local startX =  caseX-r 
  local startY =  caseY-r
  local maxX =  caseX+r
  local maxY =  caseY+r
  
  for caseX = startX, maxX do
	for caseY = startY, maxY do
		if treeMap[caseX] then
			if treeMap[caseX][caseY]~=nil then
				return false
			end
		end
		if caseX < 30 or caseY < 30 then
			return false
		end
		if caseX > 770 or caseY > 770 then
			return false
		end
	end
  end
  return true
end

function level:set_collider(level_collider)
  self.collider = level_collider
end

function level:set_player(hero)
  self.hero = hero
end

function level:_feed_boids()
  local minFood = 0
  for i=1,#self.emitters do
    if self.emitters[i] ~= nil then
		minFood = minFood + self.emitters[i]:_feed_boids()
		--self.emitters[i]:add_food(minFood)
		--self:addFood(minFood)
	end
  end
end

function level:get_nb_home()
   return #self.emitters
end

function level:get_player()  
  return self.hero
end

function level:set_mouse(mouse_input)
  self.mouse = mouse_input
end

function level:set_tile_explosion_curves(flash_curves, fade_curves)
  if #flash_curves == 0 or #fade_curves == 0 then
    return
  end
  
  for i=1,#flash_curves do
    self.tile_explosion_flash_curves[i] = flash_curves[i]
  end
  for i=1,#fade_curves do
    self.tile_explosion_fade_curves[i] = fade_curves[i]
  end
  self.tile_explosion_is_initialized = true
end

function level:set_tile_palette(tile_palette)
  self.tile_palette = tile_palette
end

----- get

function level:getFood()
local food = 0
  for i=1,#self.emitters do
    if self.emitters[i] ~= nil then
		food = food + self.emitters[i]:get_food()
	end
  end
return food
end

function level:getWood()
local wood = 0
  for i=1,#self.emitters do
    if self.emitters[i] ~= nil then
		wood = wood + self.emitters[i]:get_wood()
	end
  end
return wood
end

function level:setBoids(numBoids)
self.boids = self.boids + numBoids
self.boidPrey = 0
self.boidPred = 0
end

function level:getBoids()
return self.boids,self.boidPrey,self.boidPred
end

function level:get_pollution()
	return self.pollution
end

function level:get_collider()
  return self.collider
end

function level:get_mouse()
  return self.mouse
end

function level:get_camera()
  return self.camera
end

function level:get_master_timer()
  return self.master_timer
end

function level:get_level_map()
  return self.level_map
end

function level:get_audio_set()
  return self.audio_set
end

function level:get_active_area()
  return self.active_area_bbox
end

function level:get_camera_viewport()
  if self.camera then
    return self.camera:get_viewport_bbox()
  end
end

function level:get_screen_canvas()
  return self.screen_canvas
end

function level:get_tile_palette()
  return self.tile_palette
end

function level:get_tile_spritesheet()
  return self.tile_palette:get_spritebatch_image()
end

-- add

-- files is a table of key-value pairs where the value is a table of paths
-- to audio files and the key is the identification string to retrieve the audio
-- asset/assets once sources are loaded
-- if value.data exists, data will be added to the asset
function level:add_audio_files(files)
  local audio_set = self.audio_set
  for id,paths in pairs(files) do
    if #paths == 1 then
      audio_set:add_audio(paths[1], id)
    else
      audio_set:add_audio_set(paths, id)
    end
    
    if paths.data then
      audio_set:add_asset_data(paths.data, id)
    end
  end
end

function level:add_animation_set(anim_set)
  self.animation_sets[anim_set] = anim_set
end

function level:add_cube_shard_set(cube_shard_set, motion_curves, height_curves)
  self.cube_shard_set = cube_shard_set
  self.shard_sets[cube_shard_set] = cube_shard_set
  self.cube_motion_curves = motion_curves
  self.cube_height_curves = height_curves
end

function level:add_explosion_sound_effects(audio_sample_set)
  self.explosion_sample_set = audio_sample_set
  self.audio_sample_sets[#self.audio_sample_sets + 1] = audio_sample_set
end

-- spawn
function level:spawn_cube_explosion(x, y, power, dirx, diry)
  if not self.cube_shard_set then
    return
  end
  local angle
  if dirx and diry then
    angle = 160
  end
  
  local minr, maxr = self.cube_min_radius, self.cube_max_radius
  local minn, maxn = self.min_num_cubes, self.max_num_cubes
  local radius = minr + power * (maxr - minr)
  local num_cubes = math.floor(minn + power * (maxn - minn))
  cubes = shard_explosion:new(x, y, self.cube_shard_set, num_cubes, radius, 
                              self.cube_motion_curves, self.cube_height_curves,
                              dirx, diry, angle)
  cubes:play()
  self.shard_explosions[#self.shard_explosions + 1] = cubes
end

function level:spawn_tile_explosion(x, y, power, radius, walkable_state)
  if not self.tile_explosion_is_initialized then
    return
  end
  if walkable_state == nil then
    walkable_state = true
  end
  
  local min, max = self.tile_explosion_min_radius, self.tile_explosion_max_radius
  local radius = radius or min + math.random() * (max - min)
  
  local flash_curves = self.tile_explosion_flash_curves
  local fade_curves = self.tile_explosion_fade_curves
  local flash = flash_curves[math.random(1, #flash_curves)]
  local fade = fade_curves[math.random(1, #fade_curves)]
  
  local te = tile_explosion:new(self, x, y, radius, walkable_state, flash, fade, power)
  te:play()
  self.tile_explosions[#self.tile_explosions + 1] = te
end

function level:spawn_explosion_sound_effect(x, y, power)
  if not self.explosion_sample_set then
    return
  end
  
  
  local n, v, t, radius, spread
  if x and y then
    local min = self.explosion_sound_effect_min_num_samples
    local max = self.explosion_sound_effect_max_num_samples
    n = math.floor(lerp(min, max, power))
    t = self.explosion_sound_effect_launch_time
    v = self.explosion_sound_effect_volume * power
    radius = self.explosion_sound_effect_radius
    spread = self.explosion_sound_effect_spread
  else
    n = 1
    v = self.explosion_sound_effect_volume * (power or 1)
  end
  
  love.audio.setDistanceModel("exponent")
  self.explosion_sample_set:play(n, v, t, x, y, radius, spread)
end

function level:shake(power, duration)
  if self.camera and self.camera_shake_enabled then
    local n = 4
    for i=1,n do
      local r = i/n
      local min, max = math.min(0.03, power), power
      local power = min + r * (max - min)
      local min, max = math.min(0.5, duration), duration
      local time = min + r * (max - min)
      self.camera:shake(power, time)
    end
  end
end

function level:setTreeMap(treeMap)
self.treeMap = treeMap
end

function level:getTreeMap()
return self.treeMap
end

function level:getTreeMapSave()
return self.treeMapSave
end

function level:addTree(x,y,flock)
self.nbTree = self.nbTree + 1
local imageAnimationTreeInspire = self.imageAnimationTreeInspire
local imageAnimationTreeExpire = self.imageAnimationTreeExpire
local imageAnimationTreeBirth = self.imageAnimationTreeBirth
local imageAnimationBigTreeInspire = self.imageAnimationBigTreeInspire
local imageAnimationBigTreeExpire = self.imageAnimationBigTreeExpire
local imageAnimationOmbre = self.imageAnimationOmbre
local imageAnimationOmbreBirth = self.imageAnimationOmbreBirth

local animationTreeInspire = self:newAnimation(imageAnimationTreeInspire, 243, 182, 5)
local animationTreeExpire = self:newAnimation(imageAnimationTreeExpire, 189, 147, 5)
local animationTreeBirth = self:newAnimation(imageAnimationTreeBirth, 378, 376, 5)
local animationBigTreeInspire = self:newAnimation(imageAnimationBigTreeInspire, 378, 376, 2)
local animationBigTreeExpire = self:newAnimation(imageAnimationBigTreeExpire, 378, 376, 2)
local animationOmbre = self:newAnimation(imageAnimationOmbre, 361, 376, 2)
local animationOmbreBirth = self:newAnimation(imageAnimationOmbreBirth, 189, 376, 8)

local te = tree:new(self,self.nbTree,flock,animationTreeInspire,animationTreeExpire,animationTreeBirth,animationBigTreeInspire,animationBigTreeExpire,animationOmbre,animationOmbreBirth)
--self.treeMap[x][y]=te

self.trees[#self.trees + 1] = te

self.treeMap[x][y]= te

self.pollution = self.pollution - 1
return te
end

function level:addRock(x,y)
local rock = 1
--self.treeMap[x][y]=rock
end

function level:addBush(x,y,flock)

local imageAnimationBushInspire = self.imageAnimationBushInspire
local imageAnimationBushExpire = self.imageAnimationBushExpire
local imageAnimationBushBirth = self.imageAnimationBushBirth
local imageAnimationBigBushInspire = self.imageAnimationBigBushInspire
local imageAnimationBigBushExpire = self.imageAnimationBigBushExpire


local animationBushInspire = self:newAnimation(imageAnimationBushInspire, 529, 373, 5)
local animationBushExpire = self:newAnimation(imageAnimationBushExpire, 529, 373, 5)
local animationBushBirth = self:newAnimation(imageAnimationBushBirth, 529, 373, 5)
local animationBigBushInspire = self:newAnimation(imageAnimationBigBushInspire, 529, 373, 2)
local animationBigBushExpire = self:newAnimation(imageAnimationBigBushExpire, 529, 373, 2)


local bu = boush:new(self,#self.bushs + 1,flock,animationBushInspire,animationBushExpire,animationBushBirth,animationBigBushInspire,animationBigBushExpire)
self.treeMap[x][y]=bu
self.pollution = self.pollution - 1
self.bushs[#self.bushs + 1] = bu
return bu
end

function level:addNuage(x, y, z, flock)
self.nbNuage = self.nbNuage + 1
local imageAnimationNuage = self.imageAnimationNuage


local animationNuage = self:newAnimation(imageAnimationNuage, 427, 292, 1)

local nua = nouage:new(self,self.nbNuage,flock,animationNuage, x*32, y*32, z)
--nua:init(flock, x*32, y*32, 500)
--self.treeMap[x][y]=te

self.nuages[#self.nuages + 1] = nua

--self.treeMap[x][y]= nua
self.pollution = self.pollution - 1
end

function level:removeWood(i)
	table.remove(self.wood_source, i)
end

function level:keypressed(key)
  if key == 'c' and self.hero then
    self.hero:shoot_laser()
  end
end

function level:keyreleased(key)
end

function level:mousereleased(x, y, button)
  if self.mouse then
    self.mouse:mousereleased(x, y, button)
  end
end

function level:set_select(treeSelect)
  self.treeSelect = treeSelect
end

function level:mousepressed(x, y, button,flock)
  if self.mouse then
    self.mouse:mousepressed(x, y, button)
	local treeMap = self.treeMap
	  for mx = 1, 800 do
		for my = 1, 800 do
			if treeMap[mx][my]~=nil then
				local vx, vy = self:get_camera():get_viewport()
				local kx, ky = vx + x, vy + y
				if self.treeSelect == treeMap[mx][my] then
					treeMap[mx][my]:unselect()
				end
				treeMap[mx][my]:mousepressed(kx, ky, button)
			end
		end
	  end
  end
  local x, y = self:get_camera():get_viewport()
  local mpos = self:get_mouse():get_position()
  local mx, my = x + mpos.x, y + mpos.y
  --self.eggs[self.nbEggs] = egg:new(nil,self.nbEggs,flock,true,true,mx,my,100,self) --boidEmit,index,flock,needHome,x,y,z,free
  --self.nbEggs = self.nbEggs + 1
  
  if button == 2 and self.treeSelect then
	self.treeSelect:unselect()
  end
  
end

function level:_update_active_area()
  local bbox = self.active_area_bbox
  local center = self.camera:get_center()
  local x, y = center.x - 0.5 * ACTIVE_AREA_WIDTH, center.y - 0.5 * ACTIVE_AREA_HEIGHT
  bbox.x, bbox.y = x, y
  bbox.width, bbox.height = ACTIVE_AREA_WIDTH, ACTIVE_AREA_HEIGHT
end


------------------------------------------------------------------------------
function level:update(dt)
  self.master_timer:update(dt)
  if self.hero then
    self.hero:update(dt)
    if self.camera then
	  
	if track_x ~= nil then
		local target = vector2:new(track_x, track_y)
		local cam = self.camera
		--cam:set_target(target, true)
	end
    end
  end
  
  if self.audio_set then self.audio_set:update(dt) end
  if self.level_map then self.level_map:update(dt) end
  if self.camera then self.camera:update(dt) end
  if self.active_area_bbox then self:_update_active_area() end
  
  --if self.flock then self.emitter:update(dt) end
  
  for i=1,#self.emitters do
    if self.emitters[i] ~= nil then
		self.emitters[i]:update(dt)
	end
  end
  
  for _,anim_set in pairs(self.animation_sets) do
    anim_set:update(dt)
  end
  for _,shard_set in pairs(self.shard_sets) do
    shard_set:update(dt)
  end
  
  local explosions = self.shard_explosions
  for i=#explosions,1,-1 do
    explosions[i]:update(dt)
    if explosions[i]:is_finished() then
      table.remove(explosions, i)
    end
  end
  
  local tile_explosions = self.tile_explosions
  for i=#tile_explosions,1,-1 do
    tile_explosions[i]:update(dt)
    if tile_explosions[i]:is_finished() then
      table.remove(tile_explosions, i)
    end
  end
  
  local sample_sets = self.audio_sample_sets
  --for i=1,#sample_sets do
    --sample_sets[i]:update(dt)
  --end
	
  local trees = self.trees

  if #trees>0 then
		for i=#trees,1,-1 do
			if self.trees[i] ~= nil then
				self.trees[i]:update(dt)
			end
		end
	end
  
  local nuages = self.nuages
  
  if #nuages>0 then
		for i=#nuages,1,-1 do
			if self.nuages[i] ~= nil then
				self.nuages[i]:update(dt)
			end
		end
	end
	
  local bushs = self.bushs

  if #bushs>0 then
		for i=#bushs,1,-1 do
			if self.bushs[i] ~= nil then
				self.bushs[i]:update(dt)
			end
		end
	end
  
  local eggs = self.eggs
	
  if self.nbEggs>0 then
		for i=1,self.nbEggs do
			if self.eggs[i] ~= nil then
				self.eggs[i]:update(dt)
			end
		end
	end
  
end

------------------------------------------------------------------------------
function level:draw()
  
  if self.level_map then self.level_map:draw() end
  
  self.camera:set()
  
  for _,shard_set in pairs(self.shard_sets) do
    shard_set:draw_ground_layer()
  end
  

  
  for _,shard_set in pairs(self.shard_sets) do
    shard_set:draw_sky_layer()
  end
  
  for i=1,#self.shard_explosions do
    self.shard_explosions[i]:draw()
  end
  
  self.camera:unset()
  --self.camera:draw()
  
  local sample_sets = self.audio_sample_sets
  for i=1,#sample_sets do
    sample_sets[i]:draw()
  end
  local cx, cy = self:get_camera():get_viewport()
  local treeMap = self.treeMap
  local treeSelect = self.treeSelect
  lg.setColor(255, 255, 255, 255)
  
  
  for i=1,#self.bushs do
    if self.bushs[i] ~= nil then
		self.bushs[i]:draw()
	end
  end
  
  
  self.camera:set()
  
  if self.hero then self.hero:draw() end
  
  self.camera:unset()
   
  
  for i=1,#self.trees do
    if self.trees[i] ~= nil then
		self.trees[i]:draw()
	end
  end
  
  for i=1,#self.emitters do
    if self.emitters[i] ~= nil then
		self.emitters[i]:draw()
	end
  end
  
  for i=1,#self.nuages do
    if self.nuages[i] ~= nil then
		--self.nuages[i]:draw()
	end
  end
  
  if treeSelect then
		
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, 1450, 200)
		love.graphics.draw(tableImg, 1490, 220)
		lg.setColor(0, 0, 0, 255)
		lg.print(treeSelect.numEmits, 1600, 280)
		if treeSelect.emmiter then
			local nbBoids = treeSelect.emmiter:get_boids()
			lg.print(nbBoids, 1600, 320)
		end
  end
  self.camera:draw()
  --[[if self.nbEggs>0 then
		for i=1,self.nbEggs do
			if self.eggs[i] ~= nil and self.eggs[i].eclose==false then
				self.eggs[i]:draw(cx, cy)
			end
		end
	end--]]
end

return level










