
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
egg.needHome = nil

local egg_mt = { __index = egg }
function egg:new(boidEmit,index,flock,needHome)
  local egg = setmetatable({}, egg_mt)
  egg.boidEmit = boidEmit
  egg.index = index
  egg.eclose = false
  egg.flock = flock
  egg.needHome = needHome
  
  egg.hour_birth = 0
  print('new egg !')
  
  return egg
end

function egg:emit()
  self.boidEmit:_emit_boid("boid",self.index)
end

function egg:getI()
  return self.index
end

function egg:update(dt)
	if self.eclose then return end
	local hour_birth = self.hour_birth
	local boidEmit = self.boidEmit
	local index = self.index
	local eclose = self.eclose
	local needHome = self.needHome
	
	if hour_birth>math.random(3000,10000) and eclose==false then
		boidEmit:_emit_boid("boid",index,needHome)
		self.eclose = true
	else
		self.hour_birth = self.hour_birth + math.random (-9,10)
	end	
end

------------------------------------------------------------------------------
function egg:draw()
	
end

return egg



