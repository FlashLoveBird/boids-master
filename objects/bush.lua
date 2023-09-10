
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- bush object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local bush = {}
bush.table = 'bush'
bush.pos = nil
bush.target = nil
bush.level = nil
bush.level_map = nil
bush.flock = nil
bush.sources = nil
bush.center = nil
bush.posX = nil
bush.posY = nil
bush.collider = nil
bush.map_point = nil
bush.collision_table = nil
bush.numFood = 0
bush.drawInfo = false
bush.x = 0
bush.y = 0
bush.state = false
bush.emmiter = nil
bush.name = 1
bush.graphic = nil
bush.emitFood = false
bush.emitFoodTime = 1
bush.flock = nil
bush.food_source = nil
bush.xFood = 0
bush.yFood = 0
bush.yFood = 0
bush.numEmits = 0
bush.animation = nil
bush.animationExpire = nil
bush.animationInspire = nil
bush.animationBigTreeInspire = nil
bush.animationBigTreeExpire = nil
bush.animationBirth = nil
bush.animationOmbre = nil
bush.animationOmbreBirth = nil
bush.timeBirth = 101
bush.timeInspire = true
bush.timeExpire = false
bush.timeBigInspire = false
bush.timeBigExpire = false

local bush_mt = { __index = bush }
function bush:new(level,i, flock,animationBushInspire,animationBushExpire,animationBushBirth,animationBigBushInspire,animationBigBushExpire)
  local bush = setmetatable({}, bush_mt)
  bush.level_map = level:get_level_map()
  bush.level = level
  bush.flock = flock
  print("creation bush")
  print(flock)
  bush:initGraphics(animationBushInspire,animationBushExpire,animationBushBirth,animationBigBushInspire,animationBigBushExpire)
  bush.food_source = boid_food_source:new(level, flock, self, 1)
  bush.name=i
  print('MON NOM EST')
  print(i)
  return bush
end

function bush:initGraphics(animationBushInspire,animationBushExpire,animationBushBirth,animationBigBushInspire,animationBigBushExpire)
  self.animationInspire = animationBushInspire
  self.animationExpire = animationBushExpire
  self.animationBirth = animationBushBirth
  self.animationBigTreeInspire = animationBigBushInspire
  self.animationBigTreeExpire = animationBigBushExpire
  --self.animationOmbre = self:newAnimation(love.graphics.newImage("images/ombreBush.png"), 326, 282, 2)
  --self.animationOmbreBirth = self:newAnimation(love.graphics.newImage("images/ombreBushBirth.png"), 326, 293, 8)
end

function bush:_update_map_point(dt)
  
end

function bush:_handle_tile_collision(normal, point, offset, tile)

end

function bush:getNumEmits()
local num = self.numEmits
	return num
end

function bush:getType()
	return 3
end

------------------------------------------------------------------------------
function bush:update(dt)

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
if not self.food_source:get_food() then
	if self.emitFood == true and timeBigInspire==true then
		--print(self.emitFoodTime)
		self.emitFoodTime = emitFoodTime + dt * math.random(-1,2)
		if self.emitFoodTime>3 then
			self.emitFoodTime=0
			self:emiterFood()
		end
	end
end

if self.food_source~=nil then
	self.food_source:update(dt) --le probleme est avec la flock
end

end

function bush:emiterFood()
	local x, y = self.x , self.y
	local xFood = 0
	local yFood = 0
	local level = self.level
	local flock = self.flock
	self.xFood = xFood
	self.yFood = yFood
	--self.food_source = boid_food_source:new(level, flock, self)
	local p = self.food_source:add_food(x*32, y*32, 200)
    --self.food_source:force_polygonizer_update()
	self.emitFood = false
	self.emitFoodTime=0
end

function bush:setFlock(flock)
	local level = self.level
	self.flock = flock
	if self.food_source==nil then
		self.food_source = boid_food_source:new(level, flock, self, i)
	end
	self.emitFood = true
	self.food_source:setFlock(flock)
end

function bush:setNumEmits(num)
end

function bush:resetFood()
	self.emitFood = true
	self:setGrow()
end

function bush:getFood()
	if self.food_source:get_food() then
		return 1
	else
		return 0
	end
end

function bush:getTree()
	return self
end

function bush:setGrow()
	self.emitFoodTime = 1
	print('----------------------REGARDE ICI')
	print(self.emitFoodTime)
	print(self.name)
end

function bush:getGrow()
	return self.emitFood
end

function bush:getState()
	return self.state
end

function bush:add(emit)
	self.emmiter = emit
end

function bush:getEmit()
	return self.emmiter
end

function bush:getBush()
	return self
end

function bush:setState(bol)
	self.state = bol
end

function bush:set_target(pos, immediate)
end

function bush:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function bush:get_pos()
  return self.pos
end

function bush:get_posX()
  return self.pos.x
end

function bush:get_posY()
  return self.pos.y
end

function bush:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx>x-20 and mx<x+20 and my>y-20 and my<y+20 then
		self.drawInfo = true
	end
end

------------------------------------------------------------------------------
function bush:draw()
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
	
	love.graphics.push()
	love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
	
	lg.setColor(255, 255, 255, 255)
	if timeInspire==true then
		local spriteNum = math.floor(animationInspire.currentTime / animationInspire.duration * #animationInspire.quads) + 1
		love.graphics.draw(animationInspire.spriteSheet, animationInspire.quads[spriteNum], mx*2-100, my*2-100)
	elseif timeExpire==true then
		local spriteNum = math.floor(animationExpire.currentTime / animationExpire.duration * #animationExpire.quads) + 1
		love.graphics.draw(animationExpire.spriteSheet, animationExpire.quads[spriteNum], mx*2-100, my*2-100)
	elseif timeBirth > 100 and timeBigExpire==false and timeBigInspire==false then
		
		local spriteNum = math.floor(animationBirth.currentTime / animationBirth.duration * #animationBirth.quads) + 1
		love.graphics.draw(animationBirth.spriteSheet, animationBirth.quads[spriteNum], mx*2-50, my*2-100)
	elseif timeBigInspire == true then
		--local spriteNum = math.floor(animationOmbre.currentTime / animationOmbre.duration * #animationOmbre.quads) + 1
		--love.graphics.draw(animationOmbre.spriteSheet, animationOmbre.quads[spriteNum], mx-225, my-tronc/2-35)
		
		local spriteNum = math.floor(animationBigTreeInspire.currentTime / animationBigTreeInspire.duration * #animationBigTreeInspire.quads) + 1
		love.graphics.draw(animationBigTreeInspire.spriteSheet, animationBigTreeInspire.quads[spriteNum], mx*2-100, my*2-100)
	elseif timeBigExpire == true then
		--local spriteNum = math.floor(animationOmbre.currentTime / animationOmbre.duration * #animationOmbre.quads) + 1
		--love.graphics.draw(animationOmbre.spriteSheet, animationOmbre.quads[spriteNum], mx-225, my-tronc/2-35)
		
		
		local spriteNum = math.floor(animationBigTreeExpire.currentTime / animationBigTreeExpire.duration * #animationBigTreeExpire.quads) + 1
		love.graphics.draw(animationBigTreeExpire.spriteSheet, animationBigTreeExpire.quads[spriteNum], mx*2-100, my*2-100)
	end

	if self.food_source then
		if self.food_source:get_food() then
			self.food_source:draw(mx*2+50,my*2)
		end
	end
	
	love.graphics.pop()
	
	--[[if self.food_source then
		if self.food_source:get_food() then
			lg.print("OK", mx, my)
		else
			lg.print("Pousse", mx, my)
		end
	end--]]
	
end

function bush:newAnimation(image, width, height, duration)
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

return bush



