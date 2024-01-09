
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- lake object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local lake = {}
lake.table = 'lake'
lake.pos = nil
lake.target = nil
lake.level = nil
lake.level_map = nil
lake.flock = nil
lake.sources = nil
lake.center = nil
lake.posX = nil
lake.posY = nil
lake.collider = nil
lake.map_point = nil
lake.collision_table = nil
lake.numFood = 0
lake.drawInfo = false
lake.x = 0
lake.y = 0
lake.state = false
lake.emmiter = nil
lake.name = 1
lake.graphic = nil
lake.emitFood = false
lake.emitFoodTime = 1
lake.flock = nil
lake.water_source = nil
lake.xFood = 0
lake.yFood = 0
lake.yFood = 0
lake.numEmits = 0
lake.animation = nil
lake.animationExpire = nil
lake.animationInspire = nil
lake.animationBigTreeInspire = nil
lake.animationBigTreeExpire = nil
lake.animationBirth = nil
lake.animationOmbre = nil
lake.animationOmbreBirth = nil
lake.timeBirth = 101
lake.timeInspire = true
lake.timeExpire = false
lake.timeBigInspire = false
lake.timeBigExpire = false

local lake_mt = { __index = lake }
function lake:new(level,i, flock)
  local lake = setmetatable({}, lake_mt)
  lake.level_map = level:get_level_map()
  lake.level = level
  lake.flock = flock
  print("creation lake")
  print(flock)
  lake.water_source = boid_water_source:new(level, flock, self, 1)
  lake.name=i
  print('MON NOM EST')
  print(i)
  return lake
end

function lake:_update_map_point(dt)
  
end

function lake:_handle_tile_collision(normal, point, offset, tile)

end

function lake:getNumEmits()
local num = self.numEmits
	return num
end

function lake:getType()
	return 8
end

------------------------------------------------------------------------------
function lake:update(dt)

if self.state==false then return end

local animationInspire = self.animationInspire
local animationExpire = self.animationExpire
local animationBirth = self.animationBirth
local animationBigTreeInspire = self.animationBigTreeInspire
local animationBigTreeExpire = self.animationBigTreeExpire
local animationOmbre = self.animationOmbre
local animationOmbreBirth = self.animationOmbreBirth
local timeInspire = self.timeInspire
local timeExpire = self.timeExpire
local timeBigInspire = self.timeBigInspire
local timeBigExpire = self.timeBigExpire
local timeBirth = self.timeBirth

local dt = dt * 10

if timeInspire == true and timeBirth <= 100 then
	animationInspire.currentTime = animationInspire.currentTime + dt
	if animationInspire.currentTime >= animationInspire.duration then
		self.animationInspire.currentTime = animationInspire.currentTime - animationInspire.duration
		self.timeInspire = false
		self.timeExpire = true
		self.timeBirth = timeBirth + 50
		timeBirth = self.timeBirth
	end
end
if timeExpire == true and timeBirth <= 100 then
	animationExpire.currentTime = animationExpire.currentTime + dt
	if animationExpire.currentTime >= animationExpire.duration then
		self.animationExpire.currentTime = animationExpire.currentTime - animationExpire.duration
		self.timeInspire = true
		self.timeExpire = false
	end
end
if timeBirth > 100 and timeBigInspire == false and timeBigExpire == false then
	animationBirth.currentTime = animationBirth.currentTime + dt
	--animationOmbreBirth.currentTime = animationOmbreBirth.currentTime + dt
	self.timeInspire = false
	self.timeExpire = false
	--self.tronc = tronc + dt*60
	
	if timeBirth > 100 and animationBirth.currentTime >= animationBirth.duration then
		self.animationBirth.currentTime = animationBirth.currentTime - animationBirth.duration
		--self.animationOmbreBirth.currentTime = animationOmbreBirth.currentTime - animationOmbreBirth.duration
		self.timeBigInspire = true
	end
end
if timeBigInspire == true then
	animationBigTreeInspire.currentTime = animationBigTreeInspire.currentTime + dt
	if animationBigTreeInspire.currentTime >= animationBigTreeInspire.duration then
		self.animationBigTreeInspire.currentTime = animationBigTreeInspire.currentTime - animationBigTreeInspire.duration
		self.timeBigInspire = false
		self.timeBigExpire = true
	end
end
if timeBigExpire == true then
	animationBigTreeExpire.currentTime = animationBigTreeExpire.currentTime + dt
	if animationBigTreeExpire.currentTime >= animationBigTreeExpire.duration then
		self.animationBigTreeExpire.currentTime = animationBigTreeExpire.currentTime - animationBigTreeExpire.duration
		self.timeBigInspire = true
		self.timeBigExpire = false
	end
end

local dt = dt / 5

local emitFoodTime = self.emitFoodTime
if not self.water_source:get_food() then
	self.emitFoodTime = emitFoodTime + dt * math.random(-1,2)
	if self.emitFoodTime>3 then
		self.emitFoodTime=0
		self:emiterFood()
	end
end

if self.water_source~=nil then
	self.water_source:update(dt) --le probleme est avec la flock
end

end

function lake:emiterFood()
	local x, y = self.x , self.y
	local xFood = 0
	local yFood = 0
	local level = self.level
	local flock = self.flock
	self.xFood = xFood
	self.yFood = yFood
	--self.water_source = boid_water_source:new(level, flock, self)
	local p = self.water_source:add_water(x*32, y*32, 200)
    --self.water_source:force_polygonizer_update()
	self.emitFood = false
	self.emitFoodTime=0
end

function lake:setFlock(flock)
	local level = self.level
	self.flock = flock
	if self.water_source==nil then
		self.water_source = boid_water_source:new(level, flock, self, i)
	end
	self.emitFood = true
	self.water_source:setFlock(flock)
end

function lake:setNumEmits(num)
end

function lake:resetFood()
	print('RESET FOOD---------------')
	self.emitFood = true
	self:setGrow()
end

function lake:getFood()
	if self.water_source:get_food() then
		return 1
	else
		return 0
	end
end

function lake:getTree()
	return self
end

function lake:setGrow()
	self.emitFoodTime = 0
end

function lake:getGrow()
	return self.emitFood
end

function lake:getState()
	return self.state
end

function lake:add(emit)
	self.emmiter = emit
end

function lake:getEmit()
	return self.emmiter
end

function lake:getlake()
	return self
end

function lake:setState(bol)
	self.state = bol
end

function lake:set_target(pos, immediate)
end

function lake:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function lake:get_pos()
  return self.pos
end

function lake:get_posX()
  return self.pos.x
end

function lake:get_posY()
  return self.pos.y
end

function lake:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx>x-20 and mx<x+20 and my>y-20 and my<y+20 then
		self.drawInfo = true
	end
end

------------------------------------------------------------------------------
function lake:draw()
	local mx, my = self.x , self.y
	local cx, cy = self.level:get_camera():get_viewport()
	mx, my = mx*32-cx, my*32-cy
	local xFood = self.xFood
	local yFood = self.yFood
	local animationBirth = self.animationBirth
	local animationOmbreBirth = self.animationOmbreBirth
	local animationInspire = self.animationInspire
	local animationExpire = self.animationExpire
	local animationBigTreeInspire = self.animationBigTreeInspire
	local animationBigTreeExpire = self.animationBigTreeExpire
	local animationOmbre = self.animationOmbre
	local timeExpire = self.timeExpire
	local timeInspire = self.timeInspire
	local timeBigExpire = self.timeBigExpire
	local timeBigInspire = self.timeBigInspire
	local timeBirth = self.timeBirth
	local emitFood = self.emitFood
	local emitFoodTime = self.emitFoodTime
	
	lg.setColor(255, 255, 255, 255)
	--lg.print(self.name, mx-50, my-84)
	
	--[[if self.graphic==3 then
		love.graphics.draw(plantGraphic1, mx-50, my-64)
	elseif self.graphic==2 then
		love.graphics.draw(plantGraphic2, mx-50, my-64)
	else
		love.graphics.draw(plantGraphic3, mx-50, my-64)
	end--]]
	--love.graphics.rectangle("fill", mx,my, 32,32)
	
	
	lg.rectangle( "fill",mx,my, 100, 100 )
	
	if self.water_source then
		if self.water_source:get_food() then
			self.water_source:draw(mx+50,my)
			print('draw water')
		end
	end	
	--[[if self.water_source then
		if self.water_source:get_food() then
			lg.print("OK", mx, my)
		else
			lg.print("Pousse", mx, my)
		end
	end--]]
	
end

function lake:newAnimation(image, width, height, duration)
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

return lake



