
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
local running = nil


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
  hero.t = 0
  
  local center = vector2:new(SCR_WIDTH/2, SCR_HEIGHT/2)
  
  hero.pos = pos
  hero.center = center
  hero.target = target
  
  local tmap = level:get_level_map().tile_maps[1]
  x, y = x or tmap.bbox.x + TILE_WIDTH, y or tmap.bbox.y + TILE_HEIGHT
  self.map_point = map_point:new(level, vector2:new(x, y))
  self.map_point_2 = map_point:new(level, vector2:new(x+50, y))
  self.map_point_3 = map_point:new(level, vector2:new(x+50, y+50))
  self.map_point_4 = map_point:new(level, vector2:new(x, y+50))
  
  woosh = love.audio.newSource("sound/whoosh.wav", "stream")
  woosh:setVolume(0.3)
  
  running = love.audio.newSource("sound/running.mp3", "stream")
  running:setVolume(0.1)
  
  --level:set_player(hero)
  -- collider
  --self.collider = flock:get_collider()
  --self.map_point:update_position(vector2:new(x,y))
  --self.collider:add_object(self.map_point, self)
  
  inspiration = love.audio.newSource("sound/inspiration_forte.mp3", "stream")
  expiration = love.audio.newSource("sound/expiration.mp3", "stream")
  appeau = love.audio.newSource("sound/chouette.wav", "stream")
  
  eggHeroImg = love.graphics.newImage("images/solo-egg.png")
  hero:init()
  return hero
end

function hero:init()
	hero.animation1 = hero:newAnimation(love.graphics.newImage("images/hero_images/walkUp.png"), 322, 282, 0.5)
	hero.animation2 = hero:newAnimation(love.graphics.newImage("images/hero_images/walkLeft.png"), 322, 282, 0.5)
	hero.animation3 = hero:newAnimation(love.graphics.newImage("images/hero_images/walkDown.png"), 322, 282, 0.5)
	hero.animation4 = hero:newAnimation(love.graphics.newImage("images/hero_images/walkRight.png"), 322, 282, 0.5)
	hero.animation5 = hero:newAnimation(love.graphics.newImage("images/hero_images/noWalk.png"), 322, 282, 3)
	hero.animation50 = hero:newAnimation(love.graphics.newImage("images/hero_images/noWalk-Night.png"), 322, 282, 3)
	hero.animation6 = hero:newAnimation(love.graphics.newImage("images/hero_images/call.png"), 144, 200, 0.5)
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
  --self.collider:update_object(self.map_point)
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 1)
	print("collision")
  end
  
  self.map_point_2:set_position_coordinates(x+50, y)
  --self.collider:update_object(self.map_point)
  
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_2:get_collision_data()
  if collided then
	print("collision")
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 2)
  end
  
  self.map_point_3:set_position_coordinates(x+50, y+50)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_3:get_collision_data()
  if collided then
	print("collision")
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile, 3)
  end
  
  self.map_point_4:set_position_coordinates(x, y+50)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, collision_offset, collsion_tile = self.map_point_4:get_collision_data()
  if collided then
	print("collision")
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
			hero.animation50.currentTime = hero.animation50.currentTime - hero.animation50.duration
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
	
	local eggs = self.eggs
	
	if self.nbEggs>0 then
		for i=1,#eggs do
			if self.eggs[i] ~= nil then
				self.eggs[i]:update(dt)
			end
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
				local woosh = love.audio.newSource("sound/whooosh.wav", "stream")
				woosh:setVolume(0.1)
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
			if self.animationBlast[i].currentTime > 1.9 then
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
	if not block then
		self.pos:set(pos.x , pos.y )
	end
  --self:set_target_position(pos)
end

function hero:resetBlock()
	self.block = false
end

function hero:putEgg(x,y,boidType)
	local nbEggs = self.nbEggs
	
	self.eggs[nbEggs] = egg:new(nil,nbEggs,self.flock,true,true,x,y,100,self.level,boidType)
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

function hero:goDirection(dir)
  if dir == 1 then
	self.direction = 1
	love.audio.play(running)
  elseif dir == 2 then
	self.direction = 2
	love.audio.play(running)
  elseif dir == 3 then
	self.direction = 3
	love.audio.play(running)
  elseif dir == 4 then
	self.direction = 4
	love.audio.play(running)
  elseif dir == 5 then
	self.direction = 5
	love.audio.stop(running)
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

function hero:set_posX(position)
   self.pos.x = position
end

function hero:set_posY(position)
   self.pos.y = position
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
local boidsIn = self.boidsIn
if self.breathing then
  local radius = MASTER_TIMER.current_time - self.startBreathe
  self.breathing = false
  love.audio.play(appeau)
  
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
				end
			end
	  end
  end
  self.boidsIn = true
end
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
		end
	end
	self.boidsIn = false
end

function hero:setRandomPoints(mx, my, element)
	--source point
	local x = self.pos.x
	local y = self.pos.y
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
	self.animationBlast[#self.animationBlast+1] = self:newAnimation(love.graphics.newImage("images/blast.png"), 90, 120, 2)
	self.activeBlast[#self.activeBlast+1]=false
	self.activeBlastX[#self.activeBlastX+1]=dx
	self.activeBlastY[#self.activeBlastY+1]=dy
		
	if element==2 then
		local map = self.level:getTreeMap()
		local newX = math.floor( dx / 32 ) + 1
		local newY = math.floor( dy / 32 ) + 1
		map[newX][newY] = self.level:addTree(newX,newY)
	elseif element==3 then
		local map = self.level:getTreeMap()
		local newX = math.floor( dx / 32 ) + 1
		local newY = math.floor( dy / 32 ) + 1
		map[newX][newY] = self.level:addBush(cmx,cmy,state.flock)
		--map[cmx][cmy] = state.level:addBush(cmx,cmy,state.flock)
		--map[cmx][cmy]:setState(true)
		--map[cmx][cmy]:set_position(cmx,cmy)
		--state.level:setTreeMap(map)
	end

end

------------------------------------------------------------------------------
function hero:draw()
	--if self.pos and hero.animation1 then
	
		if self.nbEggs>0 then
			for i=1,self.nbEggs do
				if self.eggs[i] ~= nil and self.eggs[i].eclose==false then
					self.eggs[i]:draw()
				end
			end
		end
	
	
	  local x = self.pos.x
	  local y = self.pos.y
	  local radius = 0
	  local current_time = self.level.master_timer:get_time()
	  if self.breathing == true then
		radius = current_time - self.startBreathe
	  end
	  --love.graphics.circle("fill", x, y, 50, 100)
	  lg.setColor(255, 255, 255, 255)
	  
	  love.graphics.push()
	  love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
	  
	  if self.direction == 1 then
		local spriteNum = math.floor( hero.animation1.currentTime /  hero.animation1.duration * #hero.animation1.quads) + 1
		love.graphics.draw(hero.animation1.spriteSheet,  hero.animation1.quads[spriteNum], x*2, y*2)
	  elseif self.direction == 2 then
		local spriteNum = math.floor( hero.animation2.currentTime /  hero.animation2.duration * #hero.animation2.quads) + 1
		love.graphics.draw(hero.animation2.spriteSheet,  hero.animation2.quads[spriteNum], x*2, y*2)
	  elseif self.direction == 3 then
		local spriteNum = math.floor( hero.animation3.currentTime /  hero.animation3.duration * #hero.animation3.quads) + 1
		love.graphics.draw(hero.animation3.spriteSheet,  hero.animation3.quads[spriteNum], x*2, y*2)
	  elseif self.direction == 4 then
		local spriteNum = math.floor( hero.animation4.currentTime /  hero.animation4.duration * #hero.animation4.quads) + 1
		love.graphics.draw(hero.animation4.spriteSheet,  hero.animation4.quads[spriteNum], x*2, y*2)
	  elseif self.direction == 5 then
		local spriteNum = math.floor( hero.animation5.currentTime /  hero.animation5.duration * #hero.animation5.quads) + 1
		love.graphics.draw(hero.animation50.spriteSheet,  hero.animation50.quads[spriteNum], x*2, y*2)
		--if current_time<70 and current_time>20 then
			love.graphics.draw(hero.animation5.spriteSheet,  hero.animation5.quads[spriteNum], x*2, y*2)
		--end
	  elseif self.direction == 6 then
		local spriteNum = math.floor( hero.animation6.currentTime /  hero.animation6.duration * #hero.animation6.quads) + 1
		love.graphics.draw(hero.animation6.spriteSheet,  hero.animation6.quads[spriteNum], x*2, y*2)
	  end
	  
	  
	  
	  lg.setColor(255, 0, 0, 255)
	  lg.circle("line", x+60, y+60, radius*100)
	  
	--end
	
	--[[
	local pos = self.map_point:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	
	local pos = self.map_point_2:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	
	local pos = self.map_point_3:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	
	local pos = self.map_point_4:get_position()
	local x, y = pos.x, pos.y
	lg.circle("fill", x, y, 10, 100)
	--]]
	
	
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
				love.graphics.draw(animationBlast[i].spriteSheet,  animationBlast[i].quads[spriteNum], activeBlastX[i]*2, activeBlastY[i]*2)
			end
		end
	end
	
	love.graphics.pop()
	
end

return hero



