vector3 = require("vector3")

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_emitter object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local be = {}
be.table = 'be'
be.debug  = true
be.position = nil
be.direction = nil
be.radius = nil
be.flock = nil
be.level = nil
be.rate = 200
be.nbEgg = 2000
be.boid_limit = 2000
be.boid_count = 0
be.dead_zone_bbox = nil
be.active_boids = nil
be.waypoint = nil
be.is_waypoint_set = false
be.is_active = false
be.is_random_direction = false
be.gradient = nil
be.collision_table = nil
be.graphic = nil
be.eggs = nil
be.food = 0
be.wood = 0
be.water = 0
be.i = nil

local be_mt = { __index = be }
function be:new(level, flock, x, y, z, dirx, diry, dirz, radius, nbEgg, boidType, parent, i)
  local be = setmetatable({}, be_mt)
  
  be:init(level, flock, x, y, z, dirx, diry, dirz, radius, nbEgg, boidType, parent, i)
  return be
end

function be:init(level, flock, x, y, z, dirx, diry, dirz, radius, nbEgg, boidType, parent, i)
	self.flock = flock
	self.level = level
	self.nbEgg = nbEgg
	  
	self.position = {}
	self.direction = {}
	self.waypoint = {}
	self.collision_table = {}
	self.radius = radius
	vector3.set(self.position, x, y, z)
	vector3.set(self.direction, dirx, diry, dirz)
	vector3.normalize(self.direction)
	
	print('AJOUT DUN OEUF EN MILIEU DE CHAINE en ')
    print(x, y ,z)
	  
	self.active_boids = {}
	self.eggs = {}
	self.i = i
	  
	  if level then
		  local t = poisson_interval(self.rate)
		  self.spawn_timer = timer:new(level:get_master_timer(), t)
		  self.spawn_timer:start()
	  end
	self.dead_zone_bbox = bbox:new(0, 0, 0, 0)
	self:initEgg(nbEgg)
	  
	nid = love.graphics.newImage("images/home/nid.png")
	emptyNid = love.graphics.newImage("images/home/empty-nid.png")
	  
	click = love.audio.newSource("sound/click1.mp3", "stream")
	  
	if parent then
	  self.active_boids[#self.active_boids + 1] = parent
	  parent.myIdTable = #self.active_boids
	end
end

function be:initEgg(nbEgg)
  local x, y, z = self.position.x, self.position.y, self.position.z
  for i=1, nbEgg do
	self.eggs[i] = egg:new(self,i,flock,false,false,x,y,z,level,boidType) --boidEmit,index,flock,needHome,free,x,y,z,level,boidType
  end
end

function be:reset()
  self.is_active = false
  for i=#self.active_boids,1,-1 do
    local b = self.active_boids[i]
    self.active_boids[i] = nil
    self:_destroy_boid(b)
  end
  self.boid_count = 0
end

function be:getnbBoids()
	return self.boid_count
end

function be:get_boids_prey()
  local count = 0
  if #self.active_boids>0 then
	  for i=1,#self.active_boids do
		local b = self.active_boids[i]
		if b~=nil then
			if b.boidType==1 then
				count = count + 1
			end
		end
	  end
  end
  return count
end

function be:get_boids_pred()
  local count = 0
  for i=#self.active_boids,1,-1 do
    local b = self.active_boids[i]
	if b~=nil then
		if b.boidType==2 then
			count = count + 1
		end
	end
  end
  return count
end

function be:set_position(x, y, z)
  vector3.set(self.position, x, y, z)
end


function be:set_direction(dx, dy, dz)
  vector3.set(self.direction, dx, dy, dz)
  vector3.normalize(self.direction)
end

function be:set_gradient(grad_table)
  self.gradient = grad_table
end

function be:set_random_direction_on()
  self.is_random_direction = true
end

function be:set_random_direction_off()
  self.is_random_direction = false
end

function be:set_emission_rate(r)
  self.rate = r
  local t = poisson_interval(self.rate)
  if self.spawn_timer then
	self.spawn_timer:set_length(t)
	self.spawn_timer:start()
  end
end

function be:set_type(t)
  self.type = t
end

function be:stop_emission()
  self.is_active = false
end

function be:start_emission()
  self.is_active = true
end

function be:get_boid_limit()
 return self.boid_limit
end

function be:set_boid_limit(n)
 self.boid_limit = n
end

function be:set_dead_zone(x, y, width, height)
  local b = self.dead_zone_bbox
  b:set(x, y, width, height)
end

function be:set_waypoint(x, y, z)
  if not x or not y then
    self.is_waypoint_set = false
  end

  z = z or self.position.z
  vector3.set(self.waypoint, x, y, z)
  
  self.is_waypoint_set = true
end

function be:add_food(add)
  self.food = self.food + add
end

function be:min_food(add)
  self.food = self.food - add
end

function be:get_food()
  return self.food
end

function be:add_wood(add)
  self.wood = self.wood + add
end

function be:add_water(add)
  self.water = self.water + add
end

function be:get_wood()
  return self.wood
end

function be:get_water()
  return self.water
end

function be:get_boids()
  return self.boid_count
end

function be:_get_spawn_point()
  -- random point on plane defined by direction within radius
  local x, y, z = self.position.x, self.position.y, self.position.z
  --[[local angle = math.random() * 2 * math.pi
  local r = math.random() * self.radius
  local n = self.direction
  local v1x, v1y, v1z = -n.y, n.x, 0
  local inv = 1 / math.sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
  v1x, v1y, v1z = v1x * inv, v1y * inv, v1z * inv
  local v2x, v2y, v2z = vector3_cross(n.x, n.y, n.z, v1x, v1y, v1z)
  local rx = x + r*math.cos(angle)*v1x + r*math.sin(angle)*v2x
  local ry = y + r*math.cos(angle)*v1y + r*math.sin(angle)*v2y
  local rz = z + r*math.cos(angle)*v1z + r*math.sin(angle)*v2z
  ]]--
  return x, y, z
end

function be:_emit_boid(boidType,index,needHome,free,speed)
  if not self.is_active then return end
  if self.boid_count >= self.boid_limit then return end
  if self.nbEgg <= 0 then return end
  local eggs = self.eggs
  if #eggs>0 then
	for i=1, #eggs do
		if self.eggs[i] ~= nil then
			local eggI = self.eggs[i]:getI()
			if eggI == index then
				--table.remove(self.eggs, i)
				--self.eggs[index] = nil
				self.nbEgg = self.nbEgg - 1
			end
		end
	end
  end
  local x, y, z = self:_get_spawn_point()
  local dir = self.direction
  local boid
  if free==true then
    local dx, dy, dz = random_direction3()
	if boidType == 0 then
		boid = self.flock:add_boid(x, y, z, dx, dy, dz, true, self.gradient,speed)
	else
		boid = self.flock:add_predator(x, y, z, dx, dy, dz, true, self.gradient,speed)
	end
	self.active_boids[#self.active_boids + 1] = boid
	boid.myIdTable = #self.active_boids
  else
	if boidType == 0 then
		boid = self.flock:add_boid(x, y, z, dir.x, dir.y, dir.z, false, self.gradient,speed)
	else
		boid = self.flock:add_predator(x, y, z, dir.x, dir.y, dir.z, false, self.gradient,speed)
	end
	self.active_boids[#self.active_boids + 1] = boid
	boid.myIdTable = #self.active_boids
  end
  
  if self.is_waypoint_set then
    --boid:set_waypoint(self.waypoint.x, self.waypoint.y, self.waypoint.z)
  end
  self.boid_count = #self.active_boids
  
  if needHome then
	boid:set_needHome(true)
  end
  boid:set_emit_parent(self)
  print('-----------------------------------#self.active_boids')
  print(#self.active_boids)
end

function be:remove_boid(boid)
	--self.active_boids[boid.myIdTable] = nil
	table.remove(self.active_boids, boid.myIdTable)
	self.boid_count = self.boid_count - 1	
	if #self.active_boids>0 then
	  for i=1,#self.active_boids do
		local b = self.active_boids[i]
		if b~=nil and (b.myIdTable > boid.myIdTable or b.myIdTable == boid.myIdTable) then
			b.myIdTable = b.myIdTable - 1
		end
	  end
    end
end

function be:removeAllBoid()
	if #self.active_boids>0 then
	  for i=1,#self.active_boids do
		local b = self.active_boids[i]
		if b~=nil then
			b:destructHome()
		end
	  end
    end
	self.active_boids = {}
end

--[[function be:add_boid(boid)
	self.active_boids[#self.active_boids+1] = boid
	self.boid_count = self.boid_count + 1
	 print('++++++++++++++++++++++++++++111111111111111111111')
     print(#self.active_boids)
end--]]

function be:_destroy_boid(b)
  self.flock:remove_boid(b)
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function be:try_egg()
local objects = self.collision_table
local minFood = 0
local nbFood = self.food
local active = self.active_boids
local flock = self.flock
flock:get_boids_in_radius(self.position.x, self.position.y, 70, objects)
	if self.level:getBoids()<200 then
		for i=1,#objects do	
			if objects[i]:haveKid() == true then
				for j=1,math.random(1,5) do
					if nbFood > 1 then
						self.nbEgg = self.nbEgg + 1
						nbFood = nbFood - 1
						minFood = minFood + 1
						local nbEggs = self.nbEgg
						if #active > 19 then
							self.eggs[nbEggs] = egg:new(self,nbEggs,flock,true,true, self.position.x, self.position.y, 20, self.level)
						else
							self.eggs[nbEggs] = egg:new(self, nbEggs, flock, false, true, self.position.x, self.position.y, 20, self.level)
						end
					end
				end
				objects[i]:pushKid()
			end
		end
	end

return (-minFood)
end

------------------------------------------------------------------------------
function be:update(dt)
  local active = self.active_boids
  local bbox = self.dead_zone_bbox
  if not self.is_active then return end
  for i=#active,1,-1 do
    local b = active[i]
    --if bbox:contains_coordinate(b.position.x, b.position.y) then
      --table.remove(active, i)
     -- self:_destroy_boid(b)
      --self.boid_count = #active
    --end
  end
	if #self.flock>0 then 
		self.boid_count =  #self.flock:get_active_boids()
	end

	if self.type == "predator" then
		--self:_emit_boid("predator")
	elseif self.type == "boid" then
		--self:_emit_boid("boid")
	end
    local t = poisson_interval(self.rate)
	if self.spawn_timer then 
		self.spawn_timer:set_length(t)
		self.spawn_timer:start()
	end
	
	local eggs = self.eggs
	local journeyTime = self.level.master_timer:get_time()
	local player = self.level:get_player():get_position()
	
	if self.nbEgg>0 then
		for i=1,#eggs do
			if self.eggs[i] ~= nil then
				self.eggs[i]:update(dt, journeyTime, player)
				--print(self.position.x)
			end
		end
	end
end

------------------------------------------------------------------------------
function be:draw()
  if not self.is_active then return end
  local x, y = self.position.x-20, self.position.y-50
  --[[lg.setColor(255, 0, 0, 255)
  lg.setPointSize(5)
  lg.points(x, y)
  
  local len = 100
  local dir = self.direction
  local x2, y2 = x + len * dir.x, y + len * dir.y
  lg.setColor(0, 0, 0, 255)
  lg.setLineWidth(2)
  lg.line(x, y, x2, y2)
  lg.circle("line", x, y, len)
  
  -- points around radius
  local r = self.radius
  local n = self.direction
  local v1x, v1y, v1z = -n.y, n.x, 0
  local len = math.sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
  v1x, v1y, v1z = v1x/len, v1y/len, v1z/len
  local v2x, v2y, v2z = vector3_cross(n.x, n.y, n.z, v1x, v1y, v1z)
  
  local m = 40
  local inc = 2 * math.pi / m
  lg.setPointSize(4)
  
  
  lg.setColor(255, 0, 0, 255)
  self.dead_zone_bbox:draw()
  
  lg.setColor(0, 0, 0, 255)
  lg.print(self.boid_count.." / "..self.boid_limit, x, y)
  --]]
  if self.level then
	  local cx, cy = self.level:get_camera():get_viewport()
	  lg.setColor(255, 255, 255, 255)
	  if self.nbEgg > 0 then
		love.graphics.draw(nid, x-cx, y-cy)
	  else
		love.graphics.draw(emptyNid, x-cx, y-cy)
	  end
  end
  
end

return be
















