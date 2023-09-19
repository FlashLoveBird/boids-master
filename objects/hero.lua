local vector3 = require("vector3")
local Vector = require( "vector" )

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- hero object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local hero = {}
local woosh = nil
hero.table = 'hero'
hero.pos = nil
hero.target = nil
hero.level = nil
hero.level_map = nil
hero.flock = nil
hero.sources = nil
hero.center = nil
hero.posX = nil
hero.posY = nil
hero.collider = nil
hero.map_point = nil
hero.map_point_2 = nil
hero.map_point_3 = nil
hero.map_point_4 = nil
hero.animations = {}
hero.animation1 = {}
hero.animation2 = {}
hero.animation3 = {}
hero.animation4 = {}
hero.animation5 = {}
hero.animation50 = {}
hero.animation6 = {}
hero.startBreathe = 0
hero.breathing = false
hero.collision_table = nil
hero.block = false
hero.boidsIn = false
hero.nbEggs = 1
hero.eggs = {}
hero.curves = {}
hero.t = nil
hero.destXEgg = {}
hero.destYEgg = {}
hero.balls = {}
hero.elements = {}
hero.animationBlast = {}
hero.activeBlast = {}
hero.activeBlastX = {}
hero.activeBlastY = {}
hero.run = false
local walk = nil
local running = nil
hero.tired = 100
hero.hunder = 0
hero.social = 0
hero.name = "Thomas"
hero.sex = 0
hero.foodGrab = 0
hero.woodGrab = 0
hero.action = {}
hero.launch = false
hero.showWarningBool = false
hero.boidType = 10
hero.temp_vector = nil
hero.stateGrab = false
hero.canStateGrab = false
hero.getOut = false

local hero_mt = { __index = hero }
function hero:new(level, flock, x, y)
  local hero = setmetatable({}, hero_mt)
  hero:init(level, flock, x, y)
  return hero
end

function hero:init(level, flock, x, y)
	self.animation1 = self:newAnimation(love.graphics.newImage("images/hero_images/walkUp.png"), 426, 240, 3/2)
	self.animation2 = self:newAnimation(love.graphics.newImage("images/hero_images/walkLeft.png"), 426, 240, 3/2)
	self.animation3 = self:newAnimation(love.graphics.newImage("images/hero_images/walkDown.png"), 426, 240, 3/2)
	self.animation4 = self:newAnimation(love.graphics.newImage("images/hero_images/walkRight.png"), 426, 240, 3/2)
	self.animation5 = self:newAnimation(love.graphics.newImage("images/hero_images/noWalk.png"), 426, 240, 3)
	self.animation50 = self:newAnimation(love.graphics.newImage("images/hero_images/noWalk-Night.png"), 322, 282, 3)
	self.animation6 = self:newAnimation(love.graphics.newImage("images/hero_images/breathe.png"), 426, 240, 2)
	self.animation7 = self:newAnimation(love.graphics.newImage("images/hero_images/expire.png"), 426, 240, 2)
	self.animation8 = self:newAnimation(love.graphics.newImage("images/hero_images/runUp.png"), 426, 240, 0.5)
	self.animation9 = self:newAnimation(love.graphics.newImage("images/hero_images/runLeft.png"), 426, 240, 0.5)
	self.animation10 = self:newAnimation(love.graphics.newImage("images/hero_images/runDown.png"), 426, 240, 0.5)
	self.animation11 = self:newAnimation(love.graphics.newImage("images/hero_images/runRight.png"), 426, 240, 0.5)
	
	self.animation12 = self:newAnimation(love.graphics.newImage("images/hero_images/throw_down.png"), 426, 240, 1)
	self.animation13 = self:newAnimation(love.graphics.newImage("images/hero_images/grabFood.png"), 426, 266, 3)
	self.animation14 = self:newAnimation(love.graphics.newImage("images/hero_images/getOut.png"), 426, 240, 5)
	
	showWarningImg = love.graphics.newImage("images/ui/sensInterdit.png")
	
	table.insert(self.animations, self.animation1)
	table.insert(self.animations, self.animation2)
	table.insert(self.animations, self.animation3)
	table.insert(self.animations, self.animation4)
	table.insert(self.animations, self.animation5)
	table.insert(self.animations, self.animation6)
	table.insert(self.animations, self.animation7)
	table.insert(self.animations, self.animation8)
	table.insert(self.animations, self.animation9)
	table.insert(self.animations, self.animation10)
	table.insert(self.animations, self.animation11)
	table.insert(self.animations, self.animation12)
	table.insert(self.animations, self.animation13)
	table.insert(self.animations, self.animation14)
	
	  self.level_map = level:get_level_map()
	  self.level = level
	  self.flock = flock
	  
	  local pos = vector2:new(600, 600, 100)
	  -- for smooth movement
	  local target = physics.steer:new(pos)
	  target:set_dscale(1)
	  target:set_target(pos)
	  target:set_mass(camera2d.mass)  
	  target:set_max_speed(500)
	  target:set_force(500)
	  target:set_radius(300)
	  
	  self.collision_table = {}
	  self.t = 0
	  
	  self.getOut = false
	  
	  self.temp_vector = {}
	  
	  self.hunger = 100
	  self.social = 0
	  
	  local center = vector2:new(SCR_WIDTH/2, SCR_HEIGHT/2)
	  
	  self.pos = pos
	  self.position = pos
	  self.center = center
	  self.target = target
	  
	  local tmap = level:get_level_map().tile_maps[10]
	  x, y, z = x or tmap.bbox.x + TILE_WIDTH, y or tmap.bbox.y + TILE_HEIGHT , 0
	  self.map_point = map_point:new(level, vector2:new(x, y, z))
	  self.map_point_2 = map_point:new(level, vector2:new(x+50, y, z))
	  self.map_point_3 = map_point:new(level, vector2:new(x+50, y+50, z))
	  self.map_point_4 = map_point:new(level, vector2:new(x, y+50, z))
	  
	  woosh = love.audio.newSource("sound/whoosh.wav", "stream")
	  woosh:setVolume(0.3)
	  
	  walk = love.audio.newSource("sound/steps-through-the-forest.mp3", "stream")
	  running = love.audio.newSource("sound/running.mp3", "stream")
	  breath1 = love.audio.newSource("sound/breath-1.mp3", "stream")
	  breath2 = love.audio.newSource("sound/breath-2.mp3", "stream")
	  breath3 = love.audio.newSource("sound/breath-3.mp3", "stream")
	  
	  eatFood = love.audio.newSource("sound/eat-food.mp3", "stream")
	  stomach = love.audio.newSource("sound/stomach.mp3", "stream")
	  
	  walk:setVolume(0.2)
	  running:setVolume(0.3)
	  breath1:setVolume(0.3)
	  breath2:setVolume(0.3)
	  breath3:setVolume(0.3)
	  
	  --level:set_player(hero)
	  -- collider
	  self.collider = flock:get_collider()
	  self.map_point:update_position(vector2:new(x,y))
	  self.collider:add_object(self.map_point, self)
	  
	  inspiration = love.audio.newSource("sound/inspiration_forte.mp3", "stream")
	  expiration = love.audio.newSource("sound/expiration.mp3", "stream")
	  appeau = love.audio.newSource("sound/chouette.wav", "stream")
	  vol = love.audio.newSource("sound/vol.wav", "stream")
	  fuite = love.audio.newSource("sound/sing-4.mp3", "stream")
	  lookForFoodSound = love.audio.newSource("sound/looking_in_bushes.mp3", "stream")
	  
	  eggHeroImg = love.graphics.newImage("images/solo-egg.png")
	
	self.boidType=10
	
end

function hero:set_run(param)
	self.run = param
end

function hero:sing()
	
end

function hero:getStateGrab()
	return self.stateGrab
end

function hero:setStateGrab(bool)
	self.stateGrab = bool
end

function hero:canSetStateGrab(bool)
	self.canStateGrab = bool
end

function hero:getCanStateGrab()
	return self.canStateGrab
end

function hero:get_tired()
	return self.tired
end

function hero:set_emote(emoteType)
	
end

function hero:getFood()
	return self.foodGrab
end

function hero:grabFood(food)
	local foodGrab = self.foodGrab
	local rand = math.floor(math.random(0,30)/30)
	if foodGrab < 7 then
		local testFood = foodGrab + rand
		if testFood < 7 then
			self.foodGrab = testFood
			self:set_emote('food')
		elseif testFood == 7 then
			self.foodGrab = 6
			--self:set_emote('food')
		end
	else
		self.stateGrab = false
	end
	--[[if self.foodGrab > 3 and self.emit then 
		--self:set_waypoint(self.originX,self.originY,self.originZ)
		self:goOnHomeWith()
		self:setObjectiv("goOnHomeWith")
		--self.body_graphic:set_color1(0)
		self.rule_weights[self.waypoint_vector] = 200
		self.rule_weights[self.obstacle_vector] = 0
	end--]]
end

function hero:_update_map_point(dt)
  local x, y = self.target.pos.x , self.target.pos.y
  self.map_point:set_position_coordinates(x, y)
  self.map_point:update(dt)
  self.map_point_2:set_position_coordinates(x+50, y)
  self.map_point_2:update(dt)
  self.map_point_3:set_position_coordinates(x+50, y+50)
  self.map_point_3:update(dt)
  self.map_point_4:set_position_coordinates(x, y+50)
  self.map_point_4:update(dt)
  self.collider:update_object(self.map_point)
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 1)
  end
  
  self.map_point_2:set_position_coordinates(x+50, y)
  --self.collider:update_object(self.map_point)
  
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_2:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 2)
  end
  
  self.map_point_3:set_position_coordinates(x+50, y+50)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_3:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 3)
  end
  
  self.map_point_4:set_position_coordinates(x, y+50)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_4:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 4)
  end
  
end

function hero:_handle_tile_collision(normal, point, offset, tile, move)
  --self.block = true
  if self.direction==1 then
	self:set_target(self.pos.x,self.pos.y+20)
	self.pos.x, self.pos.y = self.pos.x,self.pos.y+20
	self:set_position(self.pos)
  elseif self.direction==2 then
	self.pos.x, self.pos.y = self.pos.x+20,self.pos.y
	self:set_target(self.pos.x+20,self.pos.y)
	self:set_position(self.pos)
  elseif self.direction==3 then
	self.pos.x, self.pos.y = self.pos.x,self.pos.y-20
	self:set_target(self.pos.x,self.pos.y-20)
	self:set_position(self.pos)
  elseif self.direction==4 then
	self.pos.x, self.pos.y = self.pos.x-20,self.pos.y
	self:set_target(self.pos.x-20,self.pos.y)
	self:set_position(self.pos)
  end
end

function hero:get_emote()
  return self.emoteType
end

function hero:get_hunger()
  return self.hunger
end

function hero:get_energy()
  return self.tired
end

function hero:feed(nb)
local myHunger = self.hunger
	if myHunger < 100 then
		if myHunger + nb > 100 then
			self.hunger = 100
			--self.body_graphic:set_color4(255)
			--self.age = self.age + 1
			return true
		else
			self.hunger = myHunger + nb
			--self.body_graphic:set_color4(255)
			--self.age = self.age + 1
			return true
		end
	else
		return false
	end
end

function hero:minusFood(food)
	self.foodGrab = self.foodGrab - food
end

------------------------------------------------------------------------------
function hero:update(dt)
	if self.pos then
		dt = dt
		self:_update_map_point(dt)
		self:_update_boid_life(dt)
		local action = self.action
		local launch = self.launch
		local breathing = self.breathing
		local startBreathe = self.startBreathe
		for i=1, #self.animations do
			if i == 6 and self.animations[6].currentTime < 1.95 then
				self.animations[i].currentTime = self.animations[i].currentTime + dt
			elseif i ~= 6 then
				self.animations[i].currentTime = self.animations[i].currentTime + dt
			end
			if i == 12 then
				if action[1] ~= nil and self.animations[i].currentTime >= self.animations[i].duration/2 and launch==false then
					self:setRandomPoints(action[1], action[2], action[3])
					self.launch = true
				end
				if self.animations[i].currentTime >= self.animations[i].duration/4+self.animations[i].duration/2 then
					if action[1] ~= nil then
						self.action = {}
						self.launch = false
						--self:setRandomPoints(action[1], action[2], action[3])
					end
				end
			end
			if i == 6 and self.animations[i].currentTime >= self.animations[i].duration and breathing == false then
				self.animations[i].currentTime = self.animations[i].currentTime - self.animations[i].duration
			end
			if i == 7 and self.animations[7].currentTime >= 1.95 and startBreathe ~= 0 and breathing == false then
				self.startBreathe = 0
			end
			if i ~= 6 and i ~= 7 and self.animations[i].currentTime >= self.animations[i].duration then
				self.animations[i].currentTime = self.animations[i].currentTime - self.animations[i].duration
				if i == 14 then
					self.getOut = true
				end
			end
		end
		
		--[[if self.level.master_timer then
		local masterTime = self.level.master_timer:get_time()
			if self.startBreathe < masterTime - 10 and self.breathing then
				hero:cry()
			end
		end--]]
	end
	
	local eggs = self.eggs
	local radius = self.startBreathe
	
	if radius > 0 then
		self.startBreathe = radius + 10
	end
	
	--[[if self.nbEggs>0 then
		for i=1,#eggs do
			if self.eggs[i] ~= nil then
				self.eggs[i]:update(dt)
			end
		end
	end--]]
	
	if self.direction==10 then
		local pos = self:get_position()
		pos.y = pos.y - 0.1
		self:set_position(pos)
	end
	
	local run = self.run
	local tired = self.tired
	if run==true and tired>1 then
		--self.tired = tired - 0.1
	elseif run==false and tired<100 and tired>0 then
		self.tired = tired + 1/2
	elseif run==true and tired<50 then
		self:set_run(false)
		self.tired = 1
		local rand = math.random(1,3)
		if rand==1 then
			love.audio.play(breath1)
		elseif rand==2 then
			love.audio.play(breath2)
		elseif rand==3 then
			love.audio.play(breath3)
		end
	end
	local balls = self.balls
	local activeBlast = self.activeBlast
	
	if #balls>0 then
		for i=1,#balls do
			self.balls[i] = self.balls[i] + 0.02
			if balls[i] > 0.99 and self.activeBlast[i]==false then
				self.balls[i] = 0
				self.activeBlast[i]=true
				local i = math.random(1,2)
				local woosh = love.audio.newSource("sound/champ"..i..".wav", "stream")
				woosh:setVolume(1)
				love.audio.play(woosh)
			end
		end
	end
	for i=1,#activeBlast do
		if activeBlast[i]==true then		
			local animationBlast = self.animationBlast			
			self.animationBlast[i].currentTime = self.animationBlast[i].currentTime + dt
			if self.animationBlast[i].currentTime >= self.animationBlast[i].duration then
				self.animationBlast[i].currentTime = self.animationBlast[i].currentTime - self.animationBlast[i].duration
			end
			if self.animationBlast[i].currentTime > 0.9 then
				self:putEgg(self.destXEgg[i]-25,self.destYEgg[i]-25,self.elements[i])
				table.remove(self.curves, i)
				table.remove(self.balls, i)
				table.remove(self.activeBlast, i)
				table.remove(self.destXEgg, i)
				table.remove(self.destYEgg, i)
				table.remove(self.elements, i)
				table.remove(self.activeBlastX, i)
				table.remove(self.activeBlastY, i)
				table.remove(self.animationBlast, i)					
				break
			end
		end
	end
end

function hero:_update_boid_life(dt)
	
	local inHome = self.inHome
	local objectiv = self.objectiv
	local tired = self.tired
	local foodGrab = self.foodGrab
	local hunger = self.hunger
	local destroy = self.destroy
	local flock = self.flock
	local myTime = flock:get_time()
	local emoteTime = self.emoteTime
	local confuseTime = self.confuseTime
	local predatorInViewTime = self.predatorInViewTime
	local emote = self:get_emote()
	local needHome = self.needHome
	local age = self.age
	local confuse = self.confuse
	local predatorInView = self.predatorInView
	local hadKid = self.hadKid
	local hadKidTime = self.hadKidTime
	local pollution = self.level:get_pollution()
	local searchObjRad = self.searchObjRad
	
	self.sight_radius = 200 --- pollution
	
	if self.stateGrab == true then
		self.canStateGrab = false
	end
	
	if inHome == true then
		if tired<101 then
			self.tired = tired + dt
		end
	else
		if needHome and active==false then

		end
		if self.objectiv~="goFloor" and self.hunger > 0 then
			self.hunger = hunger - dt
		end
		if self.objectiv~="goFloor" and self.tired > 0 then
			--self.tired = tired - dt*20
		end
		if hunger < 55 and foodGrab > 0 then 
			self:feed(50)
			self:minusFood(1)
			love.audio.play(eatFood)
		elseif hunger < 50 and self.emit and active==false then
			if self.emit:get_food() > 0 then
				self:goHome()
			else
				self:seekFood(searchObjRad)
				self:set_emote('hungry')
			end
		elseif hunger < 25 and foodGrab == 0 then 
			--self:seekFood(searchObjRad)
			love.audio.play(stomach)
		end
		if hunger == 0 then 
			self.dead = true
		end
		if tired < 40 then 
			if tired > 20 and math.random(1,300) == 3 and self.objectiv~="goFloor" then
				
			elseif tired < 20 then 
				
			elseif tired < 0 then 
				self.dead = true
			end
		end
		if emote~=nil then
			self.emoteTime = emoteTime + dt*10
			if emoteTime>2 then
				self:set_emote(nil)
				self.emoteTime=0
			end
		end
		if confuse then
			self.confuseTime = confuseTime + dt
			if confuseTime>1000 then
				self:unconfuse()
				self.confuseTime=0
				self.confuse = false
			end
		end
	end
	
end

function hero:newAnimation(image, width, height, duration)
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

function hero:set_target(posX,posY)
  self.target.pos.x = posX
  self.target.pos.y = posY
end

function hero:set_position(pos)
	local block = self.block
	if not block and self:getStateGrab()==false then
		self.pos:set(pos.x , pos.y )
		self:set_big_position(pos.x , pos.y, 0)
	end
  --self:set_target(pos)
end

function hero:get_position()
	return self.pos
end

function hero:resetBlock()
	self.block = false
end

function hero:putEgg(x,y,boidType)
	local nbEggs = self.nbEggs
	local egg = egg:new(nil,nbEggs,self.flock,true,true,x,y,100,self.level,boidType)
	self.level:addEgg(egg)
	
	--self.eggs[nbEggs] = egg:new(nil,nbEggs,self.flock,true,true,x,y,100,self.level,boidType)
	self.nbEggs = nbEggs + 1
		--[[local map = self.level:getTreeMap()
		local newX = math.floor( x / 32 ) + 1
		local newY = math.floor( y / 32 ) + 1
		map[newX][newY] = self.level:addTree(newX,newY)
		map[newX][newY]:add(nil)
		map[newX][newY]:setNumEmits(0)
		map[newX][newY]:setState(true)
		map[newX][newY]:set_position(newX,newY)
		self.level:setTreeMap(map)--]]
end

function hero:canIGoHere(pos)	
  return self.block
end

function hero:goDirection(dir, mx, my, bType)
  local run = self.run 
  if dir == 1 then
	self.direction = 1
		if run==true then
			love.audio.play(running)
			love.audio.stop(walk)
		else
			love.audio.play(walk)
			love.audio.stop(running)
		end
  elseif dir == 2 then
	self.direction = 2
	if run==true then
			love.audio.play(running)
			love.audio.stop(walk)
	else
			love.audio.play(walk)
			love.audio.stop(running)
	end
  elseif dir == 3 then
	self.direction = 3
	if run==true then
		love.audio.play(running)
		love.audio.stop(walk)
	else
		love.audio.play(walk)
		love.audio.stop(running)
	end
  elseif dir == 4 then
	self.direction = 4
	if run==true then
		love.audio.play(running)
		love.audio.stop(walk)
	else
		love.audio.play(walk)
		love.audio.stop(running)
	end
  elseif dir == 5 and self.action[1] == nil then
	self.direction = 5
	love.audio.stop(running)
	love.audio.stop(walk)
  elseif dir == 6 then
	self.direction = 6
  elseif dir == 7 then
	self.direction = 7
	self.action = {mx, my, bType}
	self.animations[12].currentTime = 0
  elseif dir == 8 then
	self.direction = 8
	self.animations[7].currentTime = 0
  elseif dir == 9 and self.canStateGrab==true then
	self.direction = 9
	self.stateGrab = true
	love.audio.play(lookForFoodSound)
	--self.animations[13].currentTime = 0
  elseif dir == 10 then--and self.firstDance==false then
	self.direction = 10
	--self.animations[13].currentTime = 0
  end
end

function hero:get_pos()
  return self.pos
end

function hero:draw_shadow()
  
end

function hero:getObjectiv()
  return "fly"
end

function hero:set_waypoint()

end

function hero:unObstacleMe()

end

function hero:setObjectiv()

end

function hero:get_posX()
  return self.pos.x
end

function hero:get_posY()
  return self.pos.y
end

function hero:set_posX(position)
   self.pos.x = position
end

function hero:set_posY(position)
   self.pos.y = position
end

function hero:set_big_position(x, y, z)
  vector3.set(self.position, x, y, z)
  --self.seeker:set_position(x, y, z)
  self.position.x = x
  self.position.y = y
  self.position.z = z
  local pos = self.temp_vector
  vector3.set(pos, x, y, nil)
  if pos.x~=nil then
	--self.map_point:update_position(pos)
  end
end

function hero:cry()
  love.audio.play(expiration)
end

function hero:breathe()
	love.audio.play(inspiration)
	self.startBreathe = 1
	self.breathing = true
	self.animations[6].currentTime = 0
end

function hero:getBreathe()
	return self.startBreathe
end

function hero:expire(activeFlock)
local boidsIn = self.boidsIn
if self.breathing then
  local radius = self.startBreathe
  self.breathing = false
  love.audio.play(appeau)
  self:goDirection(8)
  if self.pos.x then
	  local objects = {}
	  local x = self.pos.x
	  local y = self.pos.y
	  if #activeFlock:get_active_boids()>0 then
		  activeFlock:get_boids_in_radius(x, y, radius, objects)
			local count = 0
			if #objects>0 then
				local maxI = 0
				if #objects>50 then
					maxI = 50
				else
					maxI = #objects
				end
				for i=1,maxI do
					if objects[i].boidType == 1 then
						local boid = objects[i]
						boid:goHero()
						self.boidsIn = true
					end
				end
			end
	  end
  end
end
end

function hero:wakeUp(activeFlock)
local boidsIn = self.boidsIn
if self.breathing then
return end
  local radius = 500
  self.breathing = false
  love.audio.play(fuite)
  
  if self.pos.x then
	  local objects = {}
	  local x = self.pos.x
	  local y = self.pos.y
	  if #activeFlock:get_active_boids()>0 then
		  activeFlock:get_boids_in_radius(x, y, radius, objects)
			local count = 0
			if #objects>0 then
				local maxI = 0
				if #objects>50 then
					maxI = 50
				else
					maxI = #objects
				end
				for i=1,maxI do
					local boid = objects[i]
					boid:activate()
					boid:setObjectiv("fly")
				end
			end
	  end
  end
end

function hero:showWarning(bool)
	self.showWarningBool = bool
end

function hero:release(activeFlock)
local boidsIn = self.boidsIn
local objects = {}
local x = self.pos.x
local y = self.pos.y
activeFlock:get_boids_in_radius(x, y, 500, objects)
	if #objects>0 then
		for i=1,#objects do
			local boid = objects[i]
			boid:setObjectiv("fly")
			love.audio.play(vol)
		end
	end
	self.boidsIn = false
end

function hero:fear(activeFlock)
local boidsIn = self.boidsIn
local objects = {}
local x = self.pos.x
local y = self.pos.y
activeFlock:get_boids_in_radius(x, y, 500, objects)
	if #objects>0 then
		for i=1,#objects do
			if objects[i].boidType==5 then
				objects[i]:set_panic(true)
			end
		end
	end
end

function hero:getFirstDance()
	return self.getOut
end

function hero:setRandomPoints(mx, my, element)
	--source point
	local x = self.pos.x
	local y = self.pos.y-20
	local balls = self.balls
	local curves = self.curves
	local curve = nil
	local destXEgg = self.destXEgg
	local destYEgg = self.destYEgg
	
	love.audio.play(woosh)

	--destination point
	local dx = mx - 25
	local dy = my - 25
	
	curve = love.math.newBezierCurve(
		x,
		y,
		(x+dx)/2,	
		(y+dy)/2-100,
		dx,
		dy
	)
	self.curves[#curves+1] = curve
		
	self.balls[#balls+1] = 0
		
	self.destXEgg[#destXEgg+1] = mx
	self.destYEgg[#destYEgg+1] = my
		
	self.elements[#self.elements+1] = element
	self.animationBlast[#self.animationBlast+1] = self:newAnimation(love.graphics.newImage("images/splash.png"), 350, 233, 1)
	self.activeBlast[#self.activeBlast+1]=false
	self.activeBlastX[#self.activeBlastX+1]=dx
	self.activeBlastY[#self.activeBlastY+1]=dy
		
	if element==2 then
		local map = self.level:getTreeMap()
		local newX = math.floor( dx / 32 ) + 1
		local newY = math.floor( dy / 32 ) + 1
		map[newX][newY] = self.level:addTree(newX,newY,state.flock)
	elseif element==3 then
		local map = self.level:getTreeMap()
		local newX = math.floor( dx / 32 ) + 1
		local newY = math.floor( dy / 32 ) + 1
		map[newX][newY] = self.level:addBush(newX,newY,state.flock)
		--map[cmx][cmy] = state.level:addBush(cmx,cmy,state.flock)
		--map[cmx][cmy]:setState(true)
		--map[cmx][cmy]:set_position(cmx,cmy)
		--state.level:setTreeMap(map)
	end

end

function hero:draw_debug()

end

------------------------------------------------------------------------------
function hero:draw()
	--if self.pos and hero.animation1 then
	
		--[[if self.nbEggs>0 then
			for i=1,self.nbEggs do
				if self.eggs[i] ~= nil and self.eggs[i].eclose==false then
					self.eggs[i]:draw()
				end
			end
		end--]]
	
	
	  local x = self.pos.x - 80
	  local y = self.pos.y - 80
	  local radius = self.startBreathe
	  local current_time = self.level.master_timer:get_time()
	  if self.breathing == true then
		lg.setColor(255, 0, 0, 255)
		lg.circle("line", x+60, y+60, radius)
	  end
	  --love.graphics.circle("fill", x, y, 50, 100)
	  lg.setColor(255, 255, 255, 255)
	  
	  love.graphics.push()
	  love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
	  
	  local run = self.run
	  
	  if self.direction == 1 then
		if run == false then
			local spriteNum = math.floor( self.animation1.currentTime /  self.animation1.duration * #self.animation1.quads) + 1
			love.graphics.draw(self.animation1.spriteSheet,  self.animation1.quads[spriteNum], x*2, y*2)
		else
			local spriteNum = math.floor( self.animation8.currentTime /  self.animation8.duration * #self.animation8.quads) + 1
			love.graphics.draw(self.animation8.spriteSheet,  self.animation8.quads[spriteNum], x*2, y*2)
		end
	  elseif self.direction == 2 then
		if run == false then
			local spriteNum = math.floor( self.animation2.currentTime /  self.animation2.duration * #self.animation2.quads) + 1
			love.graphics.draw(self.animation2.spriteSheet,  self.animation2.quads[spriteNum], x*2, y*2)
		else
			local spriteNum = math.floor( self.animation9.currentTime /  self.animation9.duration * #self.animation9.quads) + 1
			love.graphics.draw(self.animation9.spriteSheet,  self.animation9.quads[spriteNum], x*2, y*2)
		end
	  elseif self.direction == 3 then
		if run == false then
			local spriteNum = math.floor( self.animation3.currentTime /  self.animation3.duration * #self.animation3.quads) + 1
			love.graphics.draw(self.animation3.spriteSheet,  self.animation3.quads[spriteNum], x*2, y*2)
		else
			local spriteNum = math.floor( self.animation10.currentTime /  self.animation10.duration * #self.animation10.quads) + 1
			love.graphics.draw(self.animation10.spriteSheet,  self.animation10.quads[spriteNum], x*2, y*2)
		end
	  elseif self.direction == 4 then
		if run == false then
			local spriteNum = math.floor( self.animation4.currentTime /  self.animation4.duration * #self.animation4.quads) + 1
			love.graphics.draw(self.animation4.spriteSheet,  self.animation4.quads[spriteNum], x*2, y*2)
		else
			local spriteNum = math.floor( self.animation11.currentTime /  self.animation11.duration * #self.animation11.quads) + 1
			love.graphics.draw(self.animation11.spriteSheet,  self.animation11.quads[spriteNum], x*2, y*2)
		end
	  elseif self.direction == 5 then
		local spriteNum = math.floor( self.animation5.currentTime /  self.animation5.duration * #self.animation5.quads) + 1
		--love.graphics.draw(self.animation50.spriteSheet,  self.animation50.quads[spriteNum], x*2, y*2)
		--if current_time<70 and current_time>20 then
			love.graphics.draw(self.animation5.spriteSheet,  self.animation5.quads[spriteNum], x*2, y*2)
		--end
	  elseif self.direction == 6 then
		local spriteNum = math.floor( self.animation6.currentTime /  self.animation6.duration * #self.animation6.quads) + 1
		love.graphics.draw(self.animation6.spriteSheet,  self.animation6.quads[spriteNum], x*2, y*2)
	  
	  elseif self.direction == 7 then
		local spriteNum = math.floor( self.animation12.currentTime /  self.animation12.duration * #self.animation12.quads) + 1
		love.graphics.draw(self.animation12.spriteSheet,  self.animation12.quads[spriteNum], x*2, y*2)
	  
	  elseif self.direction == 8 then
		local spriteNum = math.floor( self.animation7.currentTime /  self.animation7.duration * #self.animation7.quads) + 1
		love.graphics.draw(self.animation7.spriteSheet,  self.animation7.quads[spriteNum], x*2, y*2)
	  
	  elseif self.direction == 9 then
		local spriteNum = math.floor( self.animation13.currentTime /  self.animation13.duration * #self.animation13.quads) + 1
		love.graphics.draw(self.animation13.spriteSheet,  self.animation13.quads[spriteNum], x*2-25, y*2)
	  
	  elseif self.direction == 10 then
		local spriteNum = math.floor( self.animation14.currentTime /  self.animation14.duration * #self.animation14.quads) + 1
		love.graphics.draw(self.animation14.spriteSheet,  self.animation14.quads[spriteNum], x*2-25, y*2)
	  end
	  
	  
	if self.showWarningBool == true then
		lg.draw(showWarningImg, x*2+150, y*2-80)
	end
	--end
	
	if #self.curves>0 then
		love.graphics.setColor(150,150,150,255)

		love.graphics.setColor(0,160,100,255)
		for i=1,#self.curves do
			if self.activeBlast[i]==false then
				local x,y=self.curves[i]:evaluate(self.balls[i])
				local element =  self.elements[i]
				--love.graphics.line(self.curves[i]:render())
				--love.graphics.circle("fill", x, y, 5)
				lg.setColor(255, 255, 255, 255)
				lg.draw(eggHeroImg, x*2, y*2)
			end
		end
	end
	
	if #self.animationBlast>0 then
		local animationBlast = self.animationBlast
		local activeBlastX = self.activeBlastX
		local activeBlastY = self.activeBlastY
		love.graphics.setColor(150,150,150,255)
		for i=1,#animationBlast do
			if self.activeBlast[i]==true then
				local spriteNum = math.floor( animationBlast[i].currentTime /  animationBlast[i].duration * #animationBlast[i].quads) + 1
				love.graphics.draw(animationBlast[i].spriteSheet,  animationBlast[i].quads[spriteNum], activeBlastX[i]*2-150, activeBlastY[i]*2-100)
			end
		end
	end
	
	love.graphics.pop()
	
	--lg.print(self.tired, x, y)
	
	--local pos = self.map_point:get_position()
	--local x, y = pos.x, pos.y
	--lg.circle("fill", x, y, 10, 100)
	
	--[[local pos = self.map_point_2:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	
	local pos = self.map_point_3:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	
	local pos = self.map_point_4:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)--]]
	
end

return hero



