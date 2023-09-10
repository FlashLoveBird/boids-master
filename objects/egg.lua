
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- egg object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local egg = {}
egg.table = 'egg'
egg.pos = nil
egg.target = nil
egg.level = nil
egg.level_map = nil
egg.flock = nil
egg.sources = nil
egg.center = nil
egg.posX = nil
egg.posY = nil
egg.collider = nil
egg.map_point = nil
egg.collision_table = nil
egg.exist = nil
egg.boidEmit = nil
egg.hour_birth = nil
egg.index = nil
egg.eclose = nil
egg.ecloseAnim = false
egg.needHome = nil
egg.free = nil
egg.boidType = 0
egg.animationEclose = nil
egg.animationBird = nil
egg.eggImg = nil
egg.crack = nil
egg.crackSound = false
egg.speed = 20

local egg_mt = { __index = egg }
function egg:new(boidEmit,index,flock,needHome,free,x,y,z,level,boidType)
  local egg = setmetatable({}, egg_mt)
  
  egg:init(boidEmit,index,flock,needHome,free,x,y,z,level,boidType)
  
  return egg
end

function egg:init(boidEmit,index,flock,needHome,free,x,y,z,level,boidType)
  self.animationEclose = self:newAnimation(love.graphics.newImage("images/egg.png"), 192, 113, 10)
  self.animationBird = self:newAnimation(love.graphics.newImage("images/bird.png"), 85.5, 115, 10)
  self.eggImg = love.graphics.newImage("images/origami/rock-sheet0.png")
  
  self.level = level
  
  self.x = x
  self.y = y
  self.z = z
  
  self.boidEmit = boidEmit
  self.index = index
  self.eclose = false
  self.flock = flock
  self.needHome = needHome
  
  self.free = free
  self.hour_birth = 0
  
  self.boidType = boidType
  
  local rand = math.random(1,4)
  
  if rand == 1 then
	self.eggSound = love.audio.newSource("sound/pencil-1.mp3", "stream")
  elseif rand == 2 then
	self.eggSound = love.audio.newSource("sound/pencil-2.mp3", "stream")
  elseif rand == 3 then
	self.eggSound = love.audio.newSource("sound/pencil-3.mp3", "stream")
  else
	self.eggSound = love.audio.newSource("sound/pencil-4.mp3", "stream")
  end
  
  --self.crack = love.audio.newSource("sound/egg-crack.wav", "stream")
  --self.crack:setVolume(0.3)
  
end

function egg:emit()
  self.boidEmit:_emit_boid("boid",self.index)
end

function egg:getI()
  return self.index
end

function egg:distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function egg:update(dt, journeyTime, player)
	if self.eclose then return end
	local hour_birth = self.hour_birth
	local boidEmit = self.boidEmit
	local index = self.index
	local eclose = self.eclose
	local ecloseAnim = self.ecloseAnim
	local flock = self.flock
	local needHome = self.needHome
	local boidType = self.boidType
	local x = self.x 
    local y = self.y
    local z = self.z
	local free = self.free
	local timeLoc = journeyTime
	local animationEclose = self.animationEclose
	local animationBird = self.animationBird
	local speed = self.speed
	if hour_birth>100 and eclose==false and (timeLoc<70 or timeLoc>100) then --hour_birth>math.random(3000,10000) and eclose==false then
		if self.crackSound == false then
			local pos = player
			local volume = self:distance(pos.x, pos.y, x, y)
			if volume > 100 then
				--self.crack:setVolume(0)
			else
				--self.crack:setVolume((100-volume)/100)
			end
			--love.audio.play(self.crack)
			self.crackSound = true
		end
		if boidEmit then
			boidEmit:_emit_boid(boidType,index,needHome,free,speed)
			self.eclose = true
		elseif self.ecloseAnim == false then
			animationEclose.currentTime = animationEclose.currentTime + dt
			if animationEclose.currentTime >= animationEclose.duration then
				self.animationEclose.currentTime = animationEclose.currentTime - animationEclose.duration
			end
		end
		
		if animationEclose.currentTime > 9 then
			self.ecloseAnim = true
			love.audio.play(self.eggSound)
			if boidType == 0 then
				animationBird.currentTime = animationBird.currentTime + dt
				if animationBird.currentTime >= animationBird.duration then
					self.animationBird.currentTime = animationBird.currentTime - animationBird.duration
				end
				if animationBird.currentTime > 9 then
					local dx, dy, dz = random_direction3()
					flock:add_boid(x, y, z, dx, dy, dz, free, nil, speed)
					self.eclose = true
				end
			elseif boidType == 1 then
				local dx, dy, dz = random_direction3()
				flock:add_predator(x, y, z, dx, dy, dz, free)
				self.eclose = true
			elseif boidType == 2 then
				local map = self.level:getTreeMap()
				local newX = math.floor( x /32  ) + 1
				local newY = math.floor( y /32 ) + 1
				--map[newX][newY] = self.level:addTree(newX,newY)
				map[newX][newY]:add(nil)
				map[newX][newY]:setNumEmits(0)
				map[newX][newY]:setState(true)
				map[newX][newY]:set_position(newX,newY)
				map[newX][newY]:setFlock(flock)
				self.level:setTreeMap(map)
				self.eclose = true
			elseif boidType == 3 then
				local map = self.level:getTreeMap()
				local newX = math.floor( x /32 ) + 1
				local newY = math.floor( y /32 ) + 1
				--map[newX][newY] = self.level:addTree(newX,newY)
				map[newX][newY]:add(nil)
				map[newX][newY]:setState(true)
				map[newX][newY]:set_position(newX,newY)
				map[newX][newY]:setFlock(flock)
				self.level:setTreeMap(map)
				self.eclose = true
			elseif boidType == 4 then
				local dx, dy, dz = random_direction3()
				flock:add_ep(x, y, z, dx, dy, dz, free)
				self.eclose = true
			end
		end
	else
		self.hour_birth = self.hour_birth + math.random (-9,10)
	end	
end

----------------------------------------------------------------4--------------
function egg:draw(cx, cy)
local boidEmit = self.boidEmit
local x = self.x 
local y = self.y
local z = self.z
local animationEclose = self.animationEclose
local animationBird = self.animationBird

love.graphics.push()
love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates

	if boidEmit==nil then
		lg.setColor(255, 255, 255, 255)
		--lg.draw(eggImg, x, y)
	end

if self.ecloseAnim==false then
	local spriteNum = math.floor(animationEclose.currentTime / animationEclose.duration * #animationEclose.quads) + 1
	love.graphics.draw(animationEclose.spriteSheet, animationEclose.quads[spriteNum], (x-cx)*2, (y-cy)*2)
else
	local spriteNum2 = math.floor(animationBird.currentTime / animationBird.duration * #animationBird.quads) + 1
	love.graphics.draw(animationBird.spriteSheet, animationBird.quads[spriteNum2], (x-cx)*2, (y-cy)*2)
end

love.graphics.pop()

end

function egg:newAnimation(image, width, height, duration)
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

return egg



