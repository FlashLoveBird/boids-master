
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- hero object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local hero = {}
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
hero.animation1 = {}
hero.animation2 = {}
hero.animation3 = {}
hero.animation4 = {}
hero.animation5 = {}
hero.animation6 = {}
hero.startBreathe = 0
hero.breathing = false
hero.collision_table = nil
hero.block = false

local hero_mt = { __index = hero }
function hero:new(level, flock, x, y)
  local hero = setmetatable({}, hero_mt)
  hero.level_map = level:get_level_map()
  hero.level = level
  hero.flock = flock
  
  local pos = vector2:new(600, 600)
  -- for smooth movement
  local target = physics.steer:new(pos)
  target:set_dscale(1)
  target:set_target(pos)
  target:set_mass(camera2d.mass)  
  target:set_max_speed(500)
  target:set_force(500)
  target:set_radius(300)
  
  hero.collision_table = {}
  
  hero:newAnimation1(love.graphics.newImage("images/hero_images/walkUp.png"), 144, 200, 1)
  hero:newAnimation2(love.graphics.newImage("images/hero_images/walkLeft.png"), 144, 200, 1)
  hero:newAnimation3(love.graphics.newImage("images/hero_images/walkDown.png"), 144, 200, 1)
  hero:newAnimation4(love.graphics.newImage("images/hero_images/walkRight.png"), 144, 200, 1)
  hero:newAnimation5(love.graphics.newImage("images/hero_images/noWalk.png"), 144, 200, 1)
  hero:newAnimation6(love.graphics.newImage("images/hero_images/call.png"), 144, 200, 1)
  
  local center = vector2:new(SCR_WIDTH/2, SCR_HEIGHT/2)
  
  hero.pos = pos
  hero.center = center
  hero.target = target
  
  local tmap = level:get_level_map().tile_maps[1]
  x, y = x or tmap.bbox.x + TILE_WIDTH, y or tmap.bbox.y + TILE_HEIGHT
  self.map_point = map_point:new(level, vector2:new(x, y))
  
  --level:set_player(hero)
  -- collider
  --self.collider = flock:get_collider()
  --self.map_point:update_position(vector2:new(x,y))
  --self.collider:add_object(self.map_point, self)
  
  inspiration = love.audio.newSource("sound/inspiration_forte.mp3", "stream")
  expiration = love.audio.newSource("sound/expiration.mp3", "stream")
  appeau = love.audio.newSource("sound/chouette.wav", "stream")
  
  return hero
end

function hero:_update_map_point(dt)
  local x, y = self.target.pos.x , self.target.pos.y
  self.map_point:set_position_coordinates(x, y)
  self.map_point:update(dt)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, 
        collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile)
  end
end

function hero:_handle_tile_collision(normal, point, offset, tile)
  self.block = true
  self:set_target(self.pos.x,self.pos.y)
end

------------------------------------------------------------------------------
function hero:update(dt)
	if self.pos then
		dt = dt
		self:_update_map_point(dt)
		hero.animation1.currentTime = hero.animation1.currentTime + dt
		if hero.animation1.currentTime >= hero.animation1.duration then
			hero.animation1.currentTime = hero.animation1.currentTime - hero.animation1.duration
		end
		hero.animation2.currentTime = hero.animation2.currentTime + dt
		if hero.animation2.currentTime >= hero.animation2.duration then
			hero.animation2.currentTime = hero.animation2.currentTime - hero.animation2.duration
		end
		hero.animation3.currentTime = hero.animation3.currentTime + dt
		if hero.animation3.currentTime >= hero.animation3.duration then
			hero.animation3.currentTime = hero.animation3.currentTime - hero.animation3.duration
		end
		hero.animation4.currentTime = hero.animation4.currentTime + dt
		if hero.animation4.currentTime >= hero.animation4.duration then
			hero.animation4.currentTime = hero.animation4.currentTime - hero.animation4.duration
		end
		hero.animation5.currentTime = hero.animation5.currentTime + dt
		if hero.animation5.currentTime >= hero.animation5.duration then
			hero.animation5.currentTime = hero.animation5.currentTime - hero.animation5.duration
		end
		hero.animation6.currentTime = hero.animation6.currentTime + dt
		if hero.animation6.currentTime >= hero.animation6.duration then
			hero.animation6.currentTime = hero.animation6.currentTime - hero.animation6.duration
		end
		
		if self.level.master_timer then
		local masterTime = self.level.master_timer:get_time()
			if self.startBreathe < masterTime - 10 and self.breathing then
				hero:cry()
			end
		end
	end
end

function hero:newAnimation1(image, width, height, duration)
    hero.animation1.spriteSheet = image;
    hero.animation1.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation1.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation1.duration = duration or 1
    hero.animation1.currentTime = 0
end

function hero:newAnimation2(image, width, height, duration)
    hero.animation2.spriteSheet = image;
    hero.animation2.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation2.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation2.duration = duration or 1
    hero.animation2.currentTime = 0
end

function hero:newAnimation3(image, width, height, duration)
    hero.animation3.spriteSheet = image;
    hero.animation3.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation3.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation3.duration = duration or 1
    hero.animation3.currentTime = 0
end

function hero:newAnimation4(image, width, height, duration)
    hero.animation4.spriteSheet = image;
    hero.animation4.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation4.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation4.duration = duration or 1
    hero.animation4.currentTime = 0
end

function hero:newAnimation5(image, width, height, duration)
    hero.animation5.spriteSheet = image;
    hero.animation5.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation5.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation5.duration = duration or 1
    hero.animation5.currentTime = 0
end

function hero:newAnimation6(image, width, height, duration)
    hero.animation6.spriteSheet = image;
    hero.animation6.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(hero.animation6.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    hero.animation6.duration = duration or 1
    hero.animation6.currentTime = 0
end

function hero:set_target(posX,posY)
  self.target.pos.x = posX
  self.target.pos.y = posY
end

function hero:set_position(pos)
	local block = self.block
	if not block then
		self.pos:set(pos.x , pos.y )
	end
  --self:set_target_position(pos)
end

function hero:resetBlock()
	self.block = false
end

function hero:canIGoHere(pos)	
  local data = false
  local block = self.block
  self:set_target(pos.x,pos.y)
  if block == true then 
	data = true
  else
	data = false
  end
  return data
end

function hero:goDirection(dir)
  if dir == 1 then
	self.direction = 1
  elseif dir == 2 then
	self.direction = 2
  elseif dir == 3 then
	self.direction = 3
  elseif dir == 4 then
	self.direction = 4
  elseif dir == 5 then
	self.direction = 5
  elseif dir == 6 then
	self.direction = 6
  end
end

function hero:get_pos()
  return self.pos
end

function hero:get_posX()
  return self.pos.x
end

function hero:get_posY()
  return self.pos.y
end

function hero:cry()
  love.audio.play(expiration)
end

function hero:breathe()
	love.audio.play(inspiration)
	self.startBreathe = MASTER_TIMER.current_time
	self.breathing = true
end

function hero:expire(activeFlock)
if self.breathing then
  local radius = MASTER_TIMER.current_time - self.startBreathe
  print('start')
  print(self.startBreathe)
  print('current')
  print(MASTER_TIMER.current_time)
  print('radius')
  print(radius)
  self.breathing = false
  love.audio.play(appeau)
  
  print("APPEL")
  
  if self.pos.x then
	  local objects = {}
	  local x = self.pos.x
	  local y = self.pos.y
	  if #activeFlock:get_active_boids()>0 then
		  activeFlock:get_boids_in_radius(x, y, radius*100, objects)
			local count = 0
			if #objects>0 then
				for i=1,#objects do
					local boid = objects[i]
					boid:goHero()
					print('goHero')
				end
			end
	  end
  end
end
end

------------------------------------------------------------------------------
function hero:draw()
	--if self.pos and hero.animation1 then
	  local x = self.pos.x
	  local y = self.pos.y
	  local radius = 0
	  if self.breathing == true then
		radius = MASTER_TIMER.current_time - self.startBreathe
	  end
	  --love.graphics.circle("fill", x, y, 50, 100)
	  lg.setColor(255, 255, 255, 255)
	  if self.direction == 1 then
		local spriteNum = math.floor( hero.animation1.currentTime /  hero.animation1.duration * #hero.animation1.quads) + 1
		love.graphics.draw(hero.animation1.spriteSheet,  hero.animation1.quads[spriteNum], x-50, y-50)
	  elseif self.direction == 2 then
		local spriteNum = math.floor( hero.animation2.currentTime /  hero.animation2.duration * #hero.animation2.quads) + 1
		love.graphics.draw(hero.animation2.spriteSheet,  hero.animation2.quads[spriteNum], x-50, y-50)
	  elseif self.direction == 3 then
		local spriteNum = math.floor( hero.animation3.currentTime /  hero.animation3.duration * #hero.animation3.quads) + 1
		love.graphics.draw(hero.animation3.spriteSheet,  hero.animation3.quads[spriteNum], x-50, y-50)
	  elseif self.direction == 4 then
		local spriteNum = math.floor( hero.animation4.currentTime /  hero.animation4.duration * #hero.animation4.quads) + 1
		love.graphics.draw(hero.animation4.spriteSheet,  hero.animation4.quads[spriteNum], x-50, y-50)
	  elseif self.direction == 5 then
		local spriteNum = math.floor( hero.animation5.currentTime /  hero.animation5.duration * #hero.animation5.quads) + 1
		love.graphics.draw(hero.animation5.spriteSheet,  hero.animation5.quads[spriteNum], x-50, y-50)
	  elseif self.direction == 6 then
		local spriteNum = math.floor( hero.animation6.currentTime /  hero.animation6.duration * #hero.animation6.quads) + 1
		love.graphics.draw(hero.animation6.spriteSheet,  hero.animation6.quads[spriteNum], x-50, y-50)
	  end
	  
	  lg.setColor(255, 0, 0, 255)
	  lg.circle("line", x+60, y+60, radius*100)
	  
	--end
end

return hero



