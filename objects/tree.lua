
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- tree object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local tree = {}
tree.table = 'tree'
tree.pos = nil
tree.target = nil
tree.level = nil
tree.level_map = nil
tree.flock = nil
tree.sources = nil
tree.center = nil
tree.posX = nil
tree.posY = nil
tree.collider = nil
tree.map_point = nil
tree.collision_table = nil
tree.numEmits = 0
tree.drawInfo = false
tree.x = 0
tree.y = 0
tree.state = false
tree.emmiter = nil
tree.graphic = 0
tree.treeGraphic = nil
tree.animationExpire = nil
tree.animationInspire = nil
tree.animationBigTreeInspire = nil
tree.animationBigTreeExpire = nil
tree.animationBirth = nil
tree.animationOmbre = nil
tree.animationOmbreBirth = nil
tree.timeBirth = 0
tree.timeInspire = true
tree.timeExpire = false
tree.timeBigInspire = false
tree.timeBigExpire = false
tree.tronc = 0
tree.emitWoodTime = 1
tree.xWood = 0
tree.yWood = 0
tree.emitWood = false
tree.wood_source = nil
tree.woodPrim = nil
tree.food = 0

local tree_mt = { __index = tree }
function tree:new(level,i,flock, animationTreeInspire,animationTreeExpire,animationTreeBirth,animationBigTreeInspiree,animationBigTreeExpiree,animationOmbree,animationOmbreBirthe)
  local tree = setmetatable({}, tree_mt)
  tree.level_map = level:get_level_map()
  tree.level = level
  tree.numEmits = 0
  --treeGraphic = love.graphics.newImage("images/env/tree.png")
  
  tree:initGraphics(animationTreeInspire,animationTreeExpire,animationTreeBirth,animationBigTreeInspiree,animationBigTreeExpiree,animationOmbree,animationOmbreBirthe)
  --tree.wood_source = boid_wood_source:new(level, flock, self, 1)
  treeGraphicSelect = love.graphics.newImage("images/env/treeSelect.png")
  bg = love.graphics.newImage("images/Jungle/settings/bg.png")
  tableImg = love.graphics.newImage("images/Jungle/settings/table.png")
  foodIcon = love.graphics.newImage("images/ui/food.png")
  birdSleep = love.graphics.newImage("images/home/bird-sleep.png")
  troncImg = love.graphics.newImage("images/home/tronc.png")
  troncImg = love.graphics.newImage("images/home/tronc.png")
  tree.name = "Arbre"..i
  print('Arbe ajoute')
  print(tree.name)
  treeGroSound = love.audio.newSource("sound/tree_gro.wav", "stream")
  return tree
end

function tree:_update_map_point(dt)
  local x, y = self.pos.x , self.pos.y
  self.map_point:set_position_coordinates(x, y)
  self.map_point:update(dt)
  --self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, 
        collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile)
  end
end

function tree:_handle_tile_collision(normal, point, offset, tile)

end

function tree:getType()
	return 1
end

function tree:initGraphics(animationTreeInspire,animationTreeExpire,animationTreeBirth,animationBigTreeInspiree,animationBigTreeExpiree,animationOmbree,animationOmbreBirthe)
  self.animationInspire = animationTreeInspire
  self.animationExpire = animationTreeExpire
  self.animationBirth = animationTreeBirth
  self.animationBigTreeInspire = animationBigTreeInspiree
  self.animationBigTreeExpire = animationBigTreeExpiree
  self.animationOmbre = animationOmbree
  self.animationOmbreBirth = animationOmbreBirthe
  
  --self.timeBigInspire = true
  --self.timeInspire = false
  --self.tronc = 300
end

function tree:getTableVersion()
	 local tree = {}
	 tree = {x=self.x, y = self.y}	 
	 return tree
end

------------------------------------------------------------------------------
function tree:update(dt)

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
local tronc = self.tronc


if timeInspire == true and timeBirth <= 100 then
	animationInspire.currentTime = animationInspire.currentTime + dt
	if animationInspire.currentTime >= animationInspire.duration then
		self.animationInspire.currentTime = 0
		self.timeInspire = false
		self.timeExpire = false
		self.timeBirth = timeBirth + 101
	end
end
if timeExpire == true and timeBirth <= 100 then
	animationExpire.currentTime = animationExpire.currentTime + dt
	if animationExpire.currentTime >= animationExpire.duration then
		self.animationExpire.currentTime = 0
		self.timeInspire = true
		self.timeExpire = false
	end
end

if timeBirth > 100 and timeBigInspire == false and timeBigExpire == false then
	animationBirth.currentTime = animationBirth.currentTime + dt
	animationOmbreBirth.currentTime = animationOmbreBirth.currentTime + dt
	self.timeInspire = false
	self.timeExpire = false
	self.tronc = self.tronc + dt*60
	
	if animationBirth.currentTime >= animationBirth.duration then
		self.animationBirth.currentTime = animationBirth.currentTime - animationBirth.duration
		--self.animationOmbreBirth.currentTime = animationOmbreBirth.currentTime - animationOmbreBirth.duration
		self.timeBigInspire = true
		self.timeBigExpire = false
		
		if self.tronc > 20 and self.tronc < 25 then
			love.audio.play(treeGroSound)
			print(self.tronc)
		end
	end
	if animationOmbreBirth.currentTime >= animationOmbreBirth.duration then
		--self.animationBirth.currentTime = animationBirth.currentTime - animationBirth.duration
		self.animationOmbreBirth.currentTime = 0
		--self.timeBigInspire = true
	end
else
	if timeBigInspire == true then
		animationBigTreeInspire.currentTime = animationBigTreeInspire.currentTime + dt
		if animationBigTreeInspire.currentTime >= animationBigTreeInspire.duration then
			self.animationBigTreeInspire.currentTime = self.animationBigTreeInspire.currentTime - self.animationBigTreeInspire.duration
			self.timeBigInspire = false
			self.timeBigExpire = true
		end
	end
	if timeBigExpire == true then
		animationBigTreeExpire.currentTime = animationBigTreeExpire.currentTime + dt
		if animationBigTreeExpire.currentTime >= animationBigTreeExpire.duration then
			self.animationBigTreeExpire.currentTime = self.animationBigTreeExpire.currentTime - self.animationBigTreeExpire.duration
			self.timeBigInspire = true
			self.timeBigExpire = false
		end
	end
end

local emitWoodTime = self.emitWoodTime

if self.emitWoodTime~=0 then
	self.emitWoodTime = emitWoodTime + dt * math.random(0,2)
	if emitWoodTime>10 then
		self.emitWoodTime=0
		self:emiterWood()
	end
end

if self.wood_source~=nil then
	self.wood_source:update(dt) --le probleme est avec la flock
end

end

function tree:setFlock(flock)
	local level = self.level
	self.flock = flock
	if self.wood_source==nil then
		self.wood_source = boid_wood_source:new(level, flock, self, 1)
		print('crer woodsource')
		print(self.wood_source)
	end
	self.emitWood = true
	self.wood_source:setFlock(flock)
end

function tree:emiterWood()
	local x, y = self.x , self.y
	local rand = math.random(1,4)
	local xWood = 0
	local yWood = 0
	local level = self.level
	local flock = self.flock
	if rand==1 then
		xWood = math.random(-75,-50)
		yWood = math.random(-75,-50)
		self.xWood = xWood
		self.yWood = yWood
	elseif rand==2 then
		xWood = math.random(-75,-50)
		yWood = math.random(50,75)
		self.xWood = xWood
		self.yWood = yWood
	elseif rand==3 then
		xWood = math.random(50,75)
		yWood = math.random(-75,-50)
		self.xWood = xWood
		self.yWood = yWood
	else
		xWood = math.random(50,75)
		yWood = math.random(50,75)
		self.xWood = xWood
		self.yWood = yWood
	end
	--self.food_source = boid_food_source:new(level, flock, self)
	if level:canILandHere(x+xWood,y+yWood,20)==true then
		local p, primtive = self.wood_source:add_wood(x*32+xWood*32, y*32+yWood*32, 100)
		self.wood_source:force_polygonizer_update()
		self.emitWood = false
		local map = level:getTreeMap()
		print("x+xWood,y+yWood1")
		print(x+xWood,y+yWood)
		map[x+xWood][y+yWood] = p
		level:setTreeMap(map)
		self.emitWoodTime=0
		self.woodPrim = primtive
	else
		--self:resetWood()
	end
end

function tree:resetWood()
	local xWood = self.xWood
	local yWood = self.yWood
	local x, y = self.x , self.y
	local level = self.level
	self.emitWood = true
	self:setGrow()
	self.emitWoodTime = 1
	--self.wood_source = nil
	
	if self.wood_source:get_wood() then
		local map = level:getTreeMap()
		map[x+xWood][y+yWood] = nil
		level:setTreeMap(map)
		print('supprime wooooood')
		print(x+xWood, y+yWood)
		self.wood_source:remove_wood_source(self.woodPrim)
	end
end

function tree:setGrow()
	self.emitWoodTime = 1
end

function tree:getGrow()
	return self.emitWood
end

function tree:setNumEmits(num)
	self.numEmits = self.numEmits + num
end

function tree:getNumEmits()
local num = self.numEmits
	return num
end

function tree:getState()
	return self.state
end

function tree:add(emit)
	self.emmiter = emit
end

function tree:getEmit()
	return self.emmiter
end

function tree:getTree()
	return self
end

function tree:newAnimation(image, width, height, duration)
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

function tree:getNumBoids()
local emmiter = self.emmiter
	if emmiter~=nil then
		return emmiter:get_boids()
	else
		return 0
	end
end

function tree:setState(bol)
	self.state = bol
end

function tree:getFood()
	local emmiter = self.emmiter
	if emmiter~=nil then
		return emmiter:get_food()
	else
		return 0
	end
end

function tree:set_target(pos, immediate)
  if immediate then
    self.target:set_position(pos)
    self:set_position(pos)
  end
  self.target:set_target(pos)
end

function tree:set_position(tx,ty)
  self.x = tx
  self.y = ty
end

function tree:get_pos()
  return self.pos
end

function tree:get_posX()
  return self.pos.x
end

function tree:get_posY()
  return self.pos.y
end

function tree:unselect()
  self.drawInfo = false
  self.level:set_select(nil)
end

function tree:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx/32>x-5 and mx/32<x+5 and my/32>y-5 and my/32<y+5 then
		self.drawInfo = true
		self.level:set_select(self)
	end
end

------------------------------------------------------------------------------
function tree:draw()
	local drawInfo = self.drawInfo
	local mx, my = self.x , self.y
	local cx, cy = self.level:get_camera():get_viewport()
	mx, my = mx*32-cx-100, my*32-cy
	--local mpos = level:get_mouse():get_position()
	--local mxx, myy = x + mpos.x, y + mpos.y
	--local numBoids = self:getNumBoids()
	--local cam = self.level:get_camera()
	local food = self:getFood()
	--if drawInfo==true then
		--love.graphics.draw(treeGraphicSelect, mx-50, my-64)
	--end
	
	if drawInfo==true then
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(treeGraphicSelect, mx-50, my-64)
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, 1450, 200)
		love.graphics.draw(tableImg, 1490, 220)
		lg.setColor(0, 0, 0, 255)
		lg.print(self.numEmits, 1600, 280)
		--lg.print(numBoids, 1600, 300)
		lg.print(food, 1600, 300)
		
	else
		
	end
	
	--lg.setColor(255, 255, 255, 255)
	--lg.draw(self.treeGraphic, mx-50, my-64)
	lg.setColor(0, 0, 0, 255)
	--lg.print(self.numEmits, mx-50, my-64)
	--lg.print(self.name, mx-50, my-84)
	
	lg.setColor(255, 255, 255, 1)
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
	local tronc = self.tronc
	local xWood = self.xWood
	local yWood = self.yWood
	
	lg.setColor(255, 255, 255, 1)
	if timeInspire==true then
		local spriteNum = math.floor(animationInspire.currentTime / animationInspire.duration * #animationInspire.quads) + 1
		love.graphics.draw(animationInspire.spriteSheet, animationInspire.quads[spriteNum], mx, my)
	elseif timeExpire==true then
		local spriteNum = math.floor(animationExpire.currentTime / animationExpire.duration * #animationExpire.quads) + 1
		love.graphics.draw(animationExpire.spriteSheet, animationExpire.quads[spriteNum], mx, my)
	elseif timeBirth > 100 and timeBigExpire==false and timeBigInspire==false then
		local spriteNum = math.floor(animationOmbreBirth.currentTime / animationOmbreBirth.duration * #animationOmbreBirth.quads) + 1
		--love.graphics.draw(animationOmbreBirth.spriteSheet, animationOmbreBirth.quads[spriteNum], mx, my-188)
		
		if tronc > 0 then
			lg.setColor(255, 255, 255, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			lg.setColor(102, 67, 5, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			--lg.draw(troncImg, mx+80, my)
		end
		local spriteNum = math.floor(animationBirth.currentTime / animationBirth.duration * #animationBirth.quads) + 1
		love.graphics.draw(animationBirth.spriteSheet, animationBirth.quads[spriteNum], mx-189, my-188)
	elseif timeBigInspire == true then
		local spriteNum = math.floor(animationOmbre.currentTime / animationOmbre.duration * #animationOmbre.quads) + 1
		--love.graphics.draw(animationOmbre.spriteSheet, animationOmbre.quads[spriteNum], mx, my-188)
		
		if tronc > 0 then
			lg.setColor(255, 255, 255, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			lg.setColor(102, 67, 5, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			--lg.draw(troncImg, mx+80, my)
		end	
		
		local spriteNum = math.floor(animationBigTreeInspire.currentTime / animationBigTreeInspire.duration * #animationBigTreeInspire.quads) + 1
		--[[lg.print("Inspiration", mx+200, my-54)
		lg.print(math.floor(animationBigTreeInspire.currentTime*100), mx+200, my-34)
		lg.print(animationBigTreeInspire.duration*100, mx+200, my-14)
		
		lg.print(spriteNum, mx, my)--]]
		love.graphics.draw(animationBigTreeInspire.spriteSheet, animationBigTreeInspire.quads[spriteNum], mx-189, my-188)
	elseif timeBigExpire == true then
		local spriteNum = math.floor(animationOmbre.currentTime / animationOmbre.duration * #animationOmbre.quads) + 1
		--love.graphics.draw(animationOmbre.spriteSheet, animationOmbre.quads[spriteNum], mx, my-188)
		
		if tronc > 0 then
			lg.setColor(255, 255, 255, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			lg.setColor(102, 67, 5, 1)
			--lg.rectangle("fill", mx+80,my+100, 10,-tronc/2)
			
			--lg.draw(troncImg, mx+80, my)
		end
		
		local spriteNum = math.floor(animationBigTreeExpire.currentTime / animationBigTreeExpire.duration * #animationBigTreeExpire.quads) + 1
		--[[lg.print("Expiration", mx+200, my-54)
		lg.print(math.floor(animationBigTreeExpire.currentTime*100), mx+200, my-34)
		lg.print(animationBigTreeExpire.duration*100, mx+200, my-14)--]]
		love.graphics.draw(animationBigTreeExpire.spriteSheet, animationBigTreeExpire.quads[spriteNum], mx-189, my-188)
	end
	
	if self.wood_source then
		if self.wood_source:get_wood() then
			self.wood_source:draw(mx+xWood*32,my+yWood*32)
		end
	end
	
	--love.graphics.draw(birdSleep, mx+50, my-100)
	
	
end

return tree



