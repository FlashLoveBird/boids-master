local vector3 = require("vector3")
local profile = require( "profile" )
local Vector = require( "vector" )
local Luafinding = require( "luafinding" )
local ID = 1

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid object - a boid in 3d space
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local nuage = {}
nuage.table = 'nuage'
nuage.debug = true
nuage.flock = nil
nuage.position = nil
nuage.direction = nil
nuage.target = nil
nuage.default_direction = {x = 1, y = 0, z = 0}
nuage.collider = nil
nuage.map = nil


local rand = math.random(-2,2)
nuage.graphic_width = 12 + rand
nuage.graphic_height = 16 + rand
nuage.min_roll_angle = 0
nuage.max_roll_angle = math.pi / 2.4
nuage.min_roll_speed = 1
nuage.max_roll_speed = 10
nuage.min_scale = 0.5
nuage.max_scale = 1.3
nuage.field_of_view = 1.8 * math.pi
nuage.sight_radius = 400
nuage.separation_radius = 0.2 * nuage.sight_radius
nuage.separation_predator_radius = 0.2 * nuage.sight_radius
nuage.boundary_zpad = 200
nuage.boundary_ypad = 200
nuage.boundary_xpad = 200
nuage.boundary_vector_mix_ratio = 0.25           -- mixes normal to reflected projection
nuage.obstacle_vector_mix_ratio = 0.5
nuage.max_obstacle_reflect_angle = math.pi / 4
nuage.max_boundary_reflect_angle = math.pi / 3  -- boundary rule vector is reflected
nuage.life = 0
nuage.tired = 100
nuage.originX = 0
nuage.originY = 0                                  
nuage.originZ = 0
nuage.objectiv = "sleep"
nuage.inHome = false
nuage.inHero = false
debugText = "gfdfg" 
debugText2 = ""  
debugText3 = ""
nuage.foodGrab = 0
nuage.woodGrab = 0
nuage.waterGrab = 0
nuage.count = 0
nuage.hunger = 100
nuage.dead = false
nuage.sex = true
nuage.age = 2
oneSex = true 
firstBoids = 0
nuage.hadKid = false 
nuage.hadKidTime = 0 
nuage.lastTimePush = nil
nuage.nextTimePush = nil 
nuage.waypointTime = 0
nuage.newMap = true
nuage.needHome = true
nuage.treeHome = nil
nuage.treeFound = nil
nuage.foodFound = nil
nuage.woodFound = nil
nuage.caseNewTreeX = 20
nuage.caseNewTreeY = 20 
nuage.emoteTime = 0
nuage.confuseTime = 0
nuage.predatorInViewTime = 0
nuage.emit = nil
nuage.name = ""
nuage.confuse = false
nuage.takeWall = 0
nuage.id = 1
nuage.relationWith = {}
nuage.lover = nil
nuage.myIdTable = nil
nuage.seekTree = nil
nuage.seekingHome = false
nuage.seekingWood = false
nuage.boidType = 7
nuage.predatorInView = false
nuage.searchObjRad = 5
love.frame = 0
nuage.countPath = 1
nuage.step = 0
nuage.animationNuage = nil
nuage.social = nil
                                                                  -- if angle between boundary normal
                                             -- and boid direction is less than this
                                             -- angle.
                                             -- helps boids steer away from boundary

                                             
nuage.neighbours = nil
nuage.neighbours_in_view = nil
nuage.frames_per_neighbour_update = 20
nuage.neighbour_frame_offset = nil
nuage.neighbour_frame_count = 0

nuage.rule_weights = nil
nuage.vector_length = 200
nuage.waypoint = nil
nuage.alignment_vector = nil
nuage.cohesion_vector = nil
nuage.separation_vector = nil
nuage.separation_predator_vector = nil
nuage.boundary_vector = nil
nuage.waypoint_vector = nil
nuage.obstacle_vector = nil

nuage.seeker = nil
nuage.graphic = nil

nuage.is_initialized = false
nuage.temp_vector = nil

nuage.path = nil
nuage.start = Vector( 1, 1 )
nuage.finish = Vector( 50, 50 )
nuage.clickedTile = nil
nuage.mapSize = 100
nuage.inPause = false
nuage.sing_sound = nil
nuage.sing_sound_2 = nil

local bd_mt = { __index = nuage }
function nuage:new(level, nbNuage, parent_flock, animationNuage, x, y, z, dirx, diry, dirz)
  local nuage = setmetatable({}, bd_mt)
  nuage.level = level
  
  nuage.position = {}
  nuage.direction = {}
  nuage.life = 100
  nuage.predatorInView=false
  nuage.newMap = true
  nuage.animationNuage = animationNuage
  nuage.target = {x = 0, y = 0, z = 0}
  nuage.temp_vector = {}
  nuage.neighbours = {}
  nuage.neighbours_in_view = {}
  nuage:_init_map_point(x, y, parent_flock)
  nuage:_init_boid_seeker()
  nuage:_init_boid_graphic()
  nuage:_init_rule_vectors()
  nuage:_init_waypoint()
  
  
  if level and parent_flock and x and y and z then
    nuage:init(level, parent_flock, x, y, z, dirx, diry, dirz)
  end
  return nuage
end

function nuage:_init_waypoint()
  local waypoint = {}
  waypoint.is_active = false
  waypoint.x = 0
  waypoint.y = 0
  waypoint.z = 0
  waypoint.inner_radius = 0
  waypoint.outer_radius = 0
  waypoint._default_inner_radius = 100
  waypoint._default_outer_radius = 200
  waypoint._min_power = 0.5
  waypoint._max_power = 1
  self.waypoint = waypoint
  self.waypointPoint = love.graphics.newImage("images/ui/cible.png")
end

function nuage:_init_rule_vectors()
  self.alignment_vector = {}
  self.cohesion_vector = {}
  self.separation_vector = {}
  self.separation_predator_vector = {}
  self.boundary_vector = {}
  self.waypoint_vector = {}
  self.obstacle_vector = {}
  self:_clear_rule_vectors()
  
  local weights = {}
  weights[self.alignment_vector]  = 0.5
  weights[self.cohesion_vector]   = 0.2
  weights[self.separation_vector] = 3
  weights[self.boundary_vector]   = 3
  weights[self.waypoint_vector]   = 1
  weights[self.obstacle_vector]   = 8
  self.rule_weights = weights
end

function nuage:_clear_rule_vectors()
  vector3.set(self.alignment_vector, 0, 0, 0)
  vector3.set(self.cohesion_vector, 0, 0, 0)
  vector3.set(self.separation_vector, 0, 0, 0)
  vector3.set(self.separation_predator_vector, 0, 0, 0)
  vector3.set(self.boundary_vector, 0, 0, 0)
  vector3.set(self.waypoint_vector, 0, 0, 0)
  vector3.set(self.obstacle_vector, 0, 0, 0)
end

function nuage:_init_boid_seeker()
  self.seeker = nuage_seeker:new(0, 0)
end

function nuage:_init_boid_graphic()
  local variation = math.random(0.1,0.2)
  self.body_graphic = boid_graphic:new(self.graphic_width, self.graphic_height)
end

function nuage:_init_map_point(x, y)
  -- to get a position on the map
  local tmap = self.level:get_level_map().tile_maps[1]
  x, y = x or tmap.bbox.x + TILE_WIDTH, y or tmap.bbox.y + TILE_HEIGHT
  
  self.map_point = map_point:new(self.level, vector2:new(x, y))
end

function nuage:init(level, parent_flock, x, y, z, dirx, diry, dirz)
  if not x or not y then
    print("Error in boid:init() - missing parameter")
    return
  end
  print('parent_flock2')
  print(parent_flock)
  self.flock = parent_flock
  self.boidType=7
  self.originX = x
  self.originY = y
  self.originZ = z
  self.dead = false
  self.confuse = false
  --self.needHome = false
  if math.random(1,2)==1 then self.sex = false
  else self.sex = true
  end
  self.age = 1
  self.nbStepPath = 0
  self.countPath = 1
  
  self.id = ID
  self.name = "Jean-Paul-"..ID
  ID = ID + 1
  self.social = 0
  -- orientation
  vector3.set(self.position, x, y, z)
  if dirx and diry and dirz then
    vector3.set(self.direction, dirx, diry, dirz)
  else
    local dx, dy, dz = random_direction3()
    vector3.set(self.direction, dx, dy, dz)
  end
  -- seeker
  self.flock = parent_flock
  local b = self.flock:get_bbox()
  local dx, dy, dz = random_direction3()
  self.seeker:set_position(self.position.x+dx, self.position.y+dy, self.position.z+dz)
  self.seeker:set_bounds(b.x, b.y, b.width, b.height, 0)
  
  self:set_position(x, y, z)
  
  -- collider
  self.collider = parent_flock:get_collider()
  self.map_point:update_position(vector2:new(self.position.x, self.position.y))
  self.collider:add_object(self.map_point, self)
  
  -- neighbour update
  self.neighbour_frame_offset = math.random(1, self.frames_per_neighbour_update)
  self.neighbour_frame_count = self.neighbour_frame_offset
  
  self:_clear_rule_vectors()
  
  if free == false then
	self.objectiv = "sleep"
	self.inHome = true
	self.is_initialized=false
	self.needHome = false
  else
    self.objectiv = "fly"
	self.inHome = false
	self.is_initialized=true
	self:set_emote('home')
	self:seekHome(10)
	self.needHome = true
  end
  
  
  if self.sex == true then
	  local rand = math.random(1,4)
	  if rand == 1 then
		self.illuFloor = illuFloor1 --love.graphics.newImage("images/home/bird-sleep.png")
	  elseif rand == 2 then
		self.illuFloor = illuFloor2
	  elseif rand == 3 then
		self.illuFloor = illuFloor3
	  elseif rand == 4 then
		self.illuFloor = illuFloor4
      end
  else
	local rand = math.random(1,3)
	  if rand == 1 then
		self.illuFloor = illuFloor5
	  elseif rand == 2 then
		self.illuFloor = illuFloor6
	  elseif rand == 3 then
		self.illuFloor = illuFloor7
	  end
  end
end

function nuage:set_position(x, y, z)
  vector3.set(self.position, x, y, z)
  self.seeker:set_position(x, y, z)
  self.position.x = x
  self.position.y = y
  self.position.z = z
  local pos = self.temp_vector
  vector3.set(pos, x, y, nil)
  if pos.x~=nil then
	self.map_point:update_position(pos)
  end
end

function nuage:set_gradient(grad_table)
  self.body_graphic:set_gradient(grad_table)
end

function nuage:get_position()
  return self.position.x, self.position.y, self.position.z
end

function nuage:get_velocity()
  return self.seeker.velocity
end

function nuage:set_emit_parent(emit_parent)
  self.emit = emit_parent
end

function nuage:set_velocity(vel)
  self.seeker.velocity = vel
end

function nuage:get_acceleration()
  return self.seeker.acceleration
end

function nuage:set_acceleration(acc)
  self.seeker.acceleration = acc
end

function nuage:set_newHome(tree,caseNewTreeX,caseNewTreeY)
  self.needHome = false
  self.objectiv = "fly"
  self.woodGrab = 0
  self.waterGrab = 0
  self.seekTree = tree
  self.homeTree = tree
  --self:setHome(true)
  self.originX,self.originY,self.originZ = self.caseNewTreeX*32,self.caseNewTreeY*32,100
  if self.emit then
	self.emit:remove_boid(self)
  end
  self:set_emit_parent(self.seekTree:getEmit())
  --self.emit:add_boid(self)
  self.myIdTable = self.emit:get_boids()
  self.path=nil
end

function nuage:haveKid()
  if self.sex==true then return false end
  if self.sex==false and self.age > 3 and self.hadKid==false and self.lover then print('enfant') return true end
end

function nuage:pushKid()
  self.hadKid = true
end

function nuage:confuseMe()
   self.confuse = true
   self.rule_weights[self.cohesion_vector] = 0
   self.rule_weights[self.separation_vector] = 1
   local acc = self:get_acceleration()
   acc.x = acc.x*1.4
   acc.y = acc.y*1.4
   acc.z = acc.z*1.4
   self:set_acceleration(acc)
   local vel = self:get_velocity()
   vel.x = vel.x*1.4
   vel.y = vel.y*1.4
   vel.z = vel.z*1.4
   self:set_velocity(vel)
end

function nuage:unconfuse()
   self.rule_weights[self.cohesion_vector] = 0.1
   self.rule_weights[self.separation_vector] = 4
end

function nuage:unObstacleMe()
   self.obstacle = true
   self.rule_weights[self.obstacle_vector] = 0
end

function nuage:obstacle()
   self.rule_weights[self.obstacle_vector] = 3000
end

function nuage:set_direction(dx, dy, dz)
  vector3.set(self.direction, dx, dy, dz)
  self.seeker:set_direction(dx, dy, dz)
end

function nuage:set_waypoint(x, y, z, inner_radius, outer_radius)
  if inner_radius and outer_radius and inner_radius <= outer_radius then
  else
    inner_radius = self.waypoint._default_inner_radius
    outer_radius = self.waypoint._default_outer_radius
  end

  z = z or 0.5 * self.flock.bbox.depth
  local w = self.waypoint
  w.x, w.y, w.z = x, y, 1000
  w.inner_radius, w.outer_radius = inner_radius, outer_radius
  w.is_active = true
end

function nuage:clear_waypoint()
  self.waypoint.is_active = false
end

function nuage:destroy()
if self.collider ~= nil then
	self.collider:remove_object(self.map_point)
	self:clear_waypoint()
  end
end

function nuage:is_init()
	if self.is_initialized==true then
		return true
	else 
		return false
	end
end

function nuage:activate()
	self.is_initialized=true
end

function nuage:deactivate()
	self.is_initialized=false
end

function nuage:setHome(bool)
	if bool then
		self.inHome=true
	else 
		self.inHome=false
	end
end

------------------------------------------------------------------------------
function nuage:_update_seeker(dt)
  local t = self.target
  --if not self.path then
	self.seeker:set_target(t.x, t.y, t.z)
  --end
  --self.seeker:update_speed(self.tired)
  self.seeker:update(dt)
end

function nuage:_handle_tile_collision(normal, point, offset, tile)
  local dir = self.direction
  
  local dot = dir.x * normal.x + dir.y * normal.y + dir.z * 0
  local rx = -2 * dot * normal.x + dir.x
  local ry = -2 * dot * normal.y + dir.y
  local rz = -2 * dot * 0 + dir.z
  
  local len = math.sqrt(rx*rx + ry*ry + rz*rz)
  if len == 0 then return end
  local inv = 1 / len
  rx, ry, rz = rx * inv, ry * inv, rz * inv
  
  local jog = 3
  local x, y, z = point.x + jog * normal.x, point.y + jog * normal.y, 1000
  self:set_position(x, y, z)
  
  self:set_direction(rx, ry, rz)  
  --self:destroy()
end

function nuage:_update_map_point(dt)
  local x, y, z = self.seeker:get_position()
  self.map_point:set_position_coordinates(x, y)
  self.map_point:update(dt)
  self.collider:update_object(self.map_point)
  
  local collided, normal, collision_point, 
        collision_offset, collsion_tile = self.map_point:get_collision_data()
  if collided then
    self:_handle_tile_collision(normal, collision_point, collision_offset, collision_tile)
	self.takeWall = 1
  end
end

function nuage:_update_graphic_orientation(dt)
  local graphic = self.body_graphic
  local seeker = self.seeker
  local x, y, z = seeker:get_position()
  graphic:set_rotation_angle(seeker:get_rotation_angle())
  graphic:set_pitch_angle(seeker:get_pitch_angle())
  graphic:set_altitude(z)
  
  local mina, maxa = self.min_roll_angle, self.max_roll_angle
  local mins, maxs = self.min_roll_speed, self.max_roll_speed
  local roll_speed = seeker:get_roll_speed()
  local absv = math.abs(roll_speed)
  local prog =  (absv - mins) / (maxs - mins)
  local roll_angle = lerp(mina, maxa, prog)
  local age = self.age
  if roll_speed < 0 then
    roll_angle = -roll_angle
  end
  graphic:set_roll_angle(roll_angle)
  
  local minz, maxz = 0, self.flock.bbox.depth
  local mins, maxs = self.min_scale, self.max_scale
  z = math.min(maxz, z)
  z = math.max(minz, z)
  local prog = (z - minz) / (maxz - minz)
  local scale = lerp(mins, maxs, prog)
  graphic:set_scale(scale+age/10)
  
  graphic:update(dt)
end

function nuage:_update_boid_orientation(dt)
  local x, y, z = self.seeker:get_position()
  local dx, dy, dz = self.seeker:get_direction()
  vector3.set(self.position, x, y, z)
  vector3.set(self.direction, dx, dy, dz)
end

function nuage:_update_neighbours_in_view()
  local view = self.neighbours_in_view
  local nbs = self.neighbours
  table.clear(view)
  local idx = 1
  local relationWith = self.relationWith
  local lover = self.lover
  local predatorInView = self.predatorInView
  local p1 = self.position
  local dir = self.direction
  local max_angle = 0.5 * self.field_of_view
  local sex = self.sex
  for i=1,#nbs do
    local b = nbs[i]
    if b ~= self and i<10 then
		if b.boidType==1 then
			if relationWith[b.id] and relationWith[b.id]<101 and lover==nil and relationWith[b.lover]==nil and sex==not(b.sex) then
				self.relationWith[b.id] = relationWith[b.id] + math.random(0,0.1)
				if relationWith[b.id] > 50 and relationWith[b.id] < 52 then
					self:set_emote("love")
					self.lover = b
					self:set_waypoint(p1.x,p1.y,1300)
					self:sing(0)
				end
			else 
				self.relationWith[b.id] = 1
			end
			local p2 = b.position
			local dx, dy, dz = p2.x - p1.x, p2.y - p1.y, p2.z - p1.z
			if not (dx == 0 or dy == 0 or dz == 0) then
				local invlen = 1 / math.sqrt(dx*dx + dy*dy + dz*dz)
				dx, dy, dz = invlen * dx, invlen * dy, invlen * dz
				local angle = math.acos(dx*dir.x + dy*dir.y + dz*dir.z)
				if angle < max_angle then
				  view[idx] = b
				  idx = idx + 1
				end
			end
		elseif b.boidType==2 and predatorInView==false then
		   self:set_emote('exclamation')
		   local acc = self:get_acceleration()
		   acc.x = acc.x*1.3
		   acc.y = acc.y*1.3
		   acc.z = acc.z*1.3
		   self:set_acceleration(acc)
		   local vel = self:get_velocity()
		   vel.x = vel.x*1.3
		   vel.y = vel.y*1.3
		   vel.z = vel.z*1.3
		   self:set_velocity(vel)
		   self.predatorInView=true
		elseif b.boidType==5 then
			
		end
	end
  end
  --local acc = self:get_acceleration()
   --acc.x = acc.x*(1+#nbs/100)
   --acc.y = acc.y*(1+#nbs/100)
   --acc.z = acc.z*(1+#nbs/100)
   --self:set_acceleration(acc)
end

function nuage:_update_neighbours()
  self.neighbour_frame_count = self.neighbour_frame_count + 1
  if self.neighbour_frame_count % self.frames_per_neighbour_update ~= 0 then
    return
  end

  local p = self.position
  local nbs = self.neighbours
  table.clear(nbs)
  self.flock:get_boids_in_sphere(p.x, p.y, p.z, self.sight_radius, nbs)
  
  self:_update_neighbours_in_view()
end

function nuage:resetLove(b)
  self.lover = nil
  b.lover = nil
end

function nuage:_update_alignment_rule(dt)
  if #self.neighbours_in_view == 0 then return end
  
  local nbs = self.neighbours_in_view
  local align = self.alignment_vector
  for i=1,#nbs do
    local v = nbs[i].seeker.velocity
    align.x, align.y, align.z = align.x + v.x, align.y + v.y, align.z + v.z
  end
  local inv = 1 / #nbs 
  align.x, align.y, align.z = inv * align.x, inv * align.y,  inv * align.z
  local len = vector3.len(align)
  
  if len == 0 then return end
  
  local invlen = 1 / len
  align.x, align.y, align.z = invlen * align.x, invlen * align.y, invlen * align.z
  
end

function nuage:_update_cohesion_rule(dt)
  if #self.neighbours_in_view == 0 then return end
  
  local nbs = self.neighbours_in_view
  local coh = self.cohesion_vector
  local p1 = self.position
  for i=1,#nbs do
    local p2 = nbs[i].position
    local dx, dy, dz = p2.x - p1.x, p2.y - p1.y, p2.z - p1.z
    coh.x, coh.y, coh.z = coh.x + dx, coh.y + dy, coh.z + dz 
  end
  local inv = 1 / #nbs
  coh.x, coh.y, coh.z = coh.x * inv, coh.y * inv, coh.z * inv
  local len = vector3.len(coh)
  
  if len == 0 then
    return
  end
  
  local invlen = 1 / len
  coh.x, coh.y, coh.z = invlen * coh.x, invlen * coh.y, invlen * coh.z
end

function nuage:_update_separation_rule(dt)
  if #self.neighbours_in_view == 0 then return end
  
  local nbs = self.neighbours_in_view
  local sep = self.separation_vector
  local p1 = self.position
  local rsq = self.separation_radius * self.separation_radius
  local count = 0
  for i=1,#nbs do
    local p2 = nbs[i].position
	local boidType = nbs[i].boidType
	if boidType==1 and self.predatorInView==false then 
		local dx, dy, dz = p2.x - p1.x, p2.y - p1.y, p2.z - p1.z
		local lensqr = dx*dx + dy*dy + dz*dz
		if lensqr < rsq and lensqr > 0 then
		  sep.x, sep.y, sep.z = sep.x - dx, sep.y - dy, sep.z - dz
		  count = count + 1
		end
	elseif boidType==4 then
		print('je croise un truc')
	end
  end
  
  if count == 0 then return end
  
  local inv = 1 / count
  sep.x, sep.y, sep.z = sep.x * inv, sep.y * inv, sep.z * inv
  local len = vector3.len(sep)
  
  if len == 0 then return end
  
  local invlen = 1 / len
  sep.x, sep.y, sep.z = sep.x * invlen, sep.y * invlen, sep.z * invlen
  
end

function nuage:_update_separation_predator_rule(dt)
  if #self.neighbours_in_view == 0 then return end
  
  local nbs = self.neighbours_in_view
  local sep = self.separation_predator_vector
  local p1 = self.position
  local rsq = self.separation_predator_radius * self.separation_predator_radius * 100
  local count = 0
  for i=1,#nbs do
    local p2 = nbs[i].position
	local boidType = nbs[i].boidType
	if boidType==2 then
		self.predatorInView=true
		local dx, dy, dz = p2.x - p1.x, p2.y - p1.y, p2.z - p1.z
		local lensqr = dx*dx + dy*dy + dz*dz
		if lensqr < rsq and lensqr > 0 then
		  sep.x, sep.y, sep.z = sep.x - dx, sep.y - dy, sep.z - dz
		  count = count + 1
		end
	else
		
	end
  end
  
  if count == 0 then return end
  
  local inv = 1 / count
  sep.x, sep.y, sep.z = sep.x * inv, sep.y * inv, sep.z * inv
  local len = vector3.len(sep)
  
  if len == 0 then return end
  
  local invlen = 1 / len
  sep.x, sep.y, sep.z = sep.x * invlen, sep.y * invlen, sep.z * invlen
  
end

function nuage:_update_boundary_rule()
  local p = self.position
  
  local bbox = self.flock:get_bbox()
  local xpad, ypad, zpad = self.boundary_xpad, self.boundary_ypad, self.boundary_zpad
  local bvect = self.boundary_vector
  
  local min_x = bbox.x + xpad
  local max_x = bbox.x + bbox.width - xpad
  local min_y = bbox.y + ypad
  local max_y = bbox.y + bbox.height - ypad
  local min_z = 0 + zpad
  local max_z = bbox.depth - zpad
  local xpower, ypower, zpower = 0, 0, 0
  
  if p.x < min_x then
    xpower = 1 - ((p.x - bbox.x) / xpad)
    bvect.x = (bvect.x + 1) * xpower
  elseif p.x > max_x then
    xpower = (p.x - max_x) / xpad
    bvect.x = (bvect.x - 1) * xpower
  end
  
  if p.y < min_y then
    ypower = 1 - ((p.y - bbox.y) / ypad)
    bvect.y = (bvect.y + 1) * ypower
  elseif p.y > max_y then
    ypower = (p.y - max_y) / ypad
    bvect.y = (bvect.y - 1) * ypower
  end
  
  if p.z < min_z then
    zpower = 1 - ((p.z - 0) / zpad)
    bvect.z = (bvect.z + 1) * zpower
  elseif p.z > max_z then
    zpower = (p.z - max_z) / zpad
    bvect.z = (bvect.z - 1) * zpower
  end
  
  if xpower == 0 and ypower == 0 and zpower == 0 then
    return
  end
  
  local invlen = 1 / vector3.len(bvect)
  bvect.x, bvect.y, bvect.z = bvect.x * invlen, bvect.y * invlen, bvect.z * invlen
  
  -- reflect direction of void using normal bvect
  local dir = self.direction
  local dot = dir.x * bvect.x + dir.y * bvect.y + dir.z * bvect.z
  local angle = math.acos(-dot)
  local eps = 0.0001
  if angle > eps and angle < self.max_boundary_reflect_angle then
    local dot = dir.x * bvect.x + dir.y * bvect.y + dir.z * bvect.z
    local rx = -2 * dot * bvect.x + dir.x
    local ry = -2 * dot * bvect.y + dir.y
    local rz = -2 * dot * bvect.z + dir.z
    
    -- project reflected vector onto plane normal to bvect
    local dot = rx * bvect.x + ry * bvect.y + rz * bvect.z
    local dx = rx - dot * bvect.x
    local dy = ry - dot * bvect.y 
    local dz = rz - dot * bvect.z
    
    local len = math.sqrt(dx*dx + dy*dy + dz*dz)
    if len > 0 then
      local invlen = 1 / len
      dx, dy, dz = dx*invlen, dy*invlen, dz*invlen
      
      -- mix projected reflection vector with normal vector (bvect)
      local r = self.boundary_vector_mix_ratio
      dx = r * bvect.x + (1-r) * dx
      dy = r * bvect.y + (1-r) * dy
      dz = r * bvect.z + (1-r) * dz
      len = math.sqrt(dx*dx + dy*dy + dz*dz)
      if len > 0 then
        local invlen = 1 / len
          bvect.x, bvect.y, bvect.z = invlen * dx, invlen * dy, invlen * dz
      end
    end
  end
  
end

function nuage:_update_waypoint_rule()
  --debugText = tostring(self.waypoint.is_active)
  if not self.waypoint.is_active then return end

  local p = self.position
  local w = self.waypoint
  local wv = self.waypoint_vector
  local objectiv = self.objectiv
  local dx, dy, dz = w.x - p.x, w.y - p.y, w.z - p.z
  local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
  local waypoinTimeLocal = self.waypointTime
  local inHome = self.inHome
  local level = self.level
  local foodGrab = self.foodGrab
  local woodGrab = self.woodGrab
  local waterGrab = self.waterGrab
  local is_initialized = self.is_initialized
  local seeker = self.seeker
  local flock = self.flock
  local searchObjRad = self.searchObjRad
  
  local min, max = w._min_power, w._max_power
  local power = 1
  if dist < w.outer_radius+100 then
	self:clear_waypoint()
    local prog = (dist - w.inner_radius) / (w.outer_radius - w.inner_radius)
    power = min + prog * (max - min)
	if objectiv == "setNewHome" then 
		self.needHome = false
		self.objectiv = "fly"
		self.woodGrab = 0
		self.waterGrab = 0
		--self:setHome(true)
		self.originX,self.originY,self.originZ = self.caseNewTreeX*32,self.caseNewTreeY*32,100
		if self.emit then
			self.emit:remove_boid(self)
		end
		self:set_emit_parent(self.seekTree:getEmit())
		if self.emit then
			--self.emit:add_boid(self)
			self.myIdTable = self.emit:get_boids()
		end
		self.path=nil
		self.free=false
		self.countPath = 1
	elseif objectiv == "constructNewHome" then 
		self.countPath = 1
		self.needHome = false
		self.objectiv = "fly"
		self.woodGrab = 0
		self.waterGrab = 0
		print('Apres cosntruction')
		if self.emit then
			self.emit:remove_boid(self)
		end
		local emit = self.level:addHome(self.caseNewTreeX*32-25,self.caseNewTreeY*32-55,100,0,0,flock,level,0)
		self:set_emit_parent(emit)
		self.myIdTable = 1
		--self:setHome(true)
		self.level.treeMap[self.caseNewTreeX][self.caseNewTreeY]:add(emit)
		self.level.treeMap[self.caseNewTreeX][self.caseNewTreeY]:setNumEmits(1)
		self.originX,self.originY,self.originZ = self.caseNewTreeX*32,self.caseNewTreeY*32,100
		--self.emit:add_boid(self)
		self.free=false
		self.path=nil
		self.free=false
		
		local timeLoc = self.level.master_timer:get_time()
		if timeLoc>41 and timeLoc<101 then
			self:setHome(true)
			self:deactivate()
			self:set_position(self.originX,self.originY,self.originZ)
			self:setObjectiv("sleep")
			self.path=nil
		else
			self:setObjectiv("fly")
		end
		self.emit:try_egg();
		
	elseif objectiv == "seekHome" then 
		--self:seekHome()
	elseif objectiv == "goOnSeekHome" then
		self:seekHome(searchObjRad)
	elseif objectiv == "goOnSeekFood" then 
		self:seekFood(searchObjRad)
	elseif objectiv == "goOnSeekWood" then 
		self:seekWood(searchObjRad)
	elseif objectiv == "goOnHero" then 
		self:goHero()
	elseif objectiv == "goHero" then 
		self.objectiv = "fly"
	elseif objectiv == "goFloor" then 
		self:deactivate()
		self.inHome = false
		self.countPath = 1
		--self.objectiv = "fly"
	elseif objectiv == "goOnHome" then 
		self:goHome()
	elseif objectiv == "goOnSeekTree" then 
		self:seekTreeFroSleep(searchObjRad)
	elseif objectiv == "goOnHomeWith" then
		self:goOnHomeWith()
	elseif objectiv == "goOut" then
		self:setObjectiv("fly")
		self.rule_weights[self.obstacle_vector] = 8
	elseif objectiv == "goConstructHomeWith" then
		self:goConstructHomeWith()
	elseif objectiv=="goHomeWithIn" then
		self.countPath = 1
		self:set_position(self.originX,self.originY,self.originZ)
		seeker:set_velocity({x = 0, y = 0, z = 0})
		self:minusFood(foodGrab)
		self:minusWood(woodGrab)
		self:minusWater(waterGrab)
		if self.emit then
			self.emit:add_food(foodGrab)
			self.emit:add_wood(woodGrab)
			self.emit:add_water(waterGrab)
		end
		local timeLoc = self.level.master_timer:get_time()
		if self.hunger>60 and (timeLoc<70 or timeLoc>100) then
			self:setObjectiv("fly")
		elseif timeLoc<70 or timeLoc>100 then
			self:seekFood(searchObjRad)
		else
			self:setHome(true)
			self:deactivate()
			self:set_position(self.originX,self.originY,self.originZ)
			self:setObjectiv("sleep")
		end
		self:clear_waypoint()
		self.path = nil
	elseif objectiv == "goSleep" then
		local timeLoc = self.level.master_timer:get_time()
		self.countPath = 1
		self:setHome(true)
		self:deactivate()
		self:set_position(self.originX,self.originY,self.originZ)
		self:setObjectiv("sleep")
		self.path=nil
		if self.emit then
			self.emit:add_food(foodGrab)
			self.emit:add_wood(woodGrab)
			self.emit:add_water(waterGrab)
			self:minusFood(foodGrab)
			self:minusWood(woodGrab)
			self:minusWater(waterGrab)
			self.emit:try_egg();
		end
		seeker:set_velocity({x = 0, y = 0, z = 0})
		self.path = nil
	end
	
	--elseif objectiv == "goHome" and inHome==false then
		--self.rule_weights[self.separation_vector] = 0.6
		--self:goHome()		
	--elseif objectiv == "goHomewithFood" and inHome==false then
		--self:setHome(false)
		--self:set_position(self.originX,self.originY,self.originZ)
		--seeker:set_velocity({x = 0, y = 0, z = 0})
		--level:addFood(foodGrab)
		--self:minusFood(foodGrab)
		--self:deactivate()
		--self:setObjectiv("sleep")
	--elseif objectiv == "goHero" then
		--self.rule_weights[self.separation_vector] = 0.6
		--self:goHero()
	--elseif objectiv == "goHome" and inHome==true then
		--self.path = nil
	--self:clear_waypoint()	
  end
  local factor = (1 / dist) * power
  wv.x, wv.y, wv.z = dx * factor * power, dy * factor * power, dz * factor * power
end

function nuage:grabFood(food)
	local foodGrab = self.foodGrab
	local active = self.waypoint.is_active
	if foodGrab < 5 then
		self.foodGrab = foodGrab + math.floor(food/10000)
		self:set_emote('food')
		print("self.foodGrab")
		print(self.foodGrab)
	end
	if self.foodGrab > 3 and self.emit then 
		--self:set_waypoint(self.originX,self.originY,self.originZ)
		self:goOnHomeWith()
		self:setObjectiv("goOnHomeWith")
		--self.body_graphic:set_color1(0)
		self.rule_weights[self.waypoint_vector] = 200
		self.rule_weights[self.obstacle_vector] = 0
	end
end

function nuage:setObjectiv(obj)
	self.objectiv = obj
end

function nuage:getObjectiv()
	return self.objectiv
end

function nuage:minusFood(food)
	self.foodGrab = self.foodGrab - food
end

function nuage:minusWood(wood)
	self.woodGrab = self.woodGrab - wood
end

function nuage:minusWater(water)
	self.waterGrab = self.waterGrab - water
end

function nuage:grabWood(wood)
	local woodGrab = self.woodGrab
	local seekingHome = self.seekingHome
	local seekingWood = self.seekingWood
	self.woodGrab = self.woodGrab + math.floor(wood/10000)
	local active = self.waypoint.is_active
	if self.woodGrab > 10 and self.needHome == true and seekingHome == true and seekingWood == true then
		local x = math.floor(self.caseNewTreeX*32)
		local y =  math.floor(self.caseNewTreeY*32)
		self:clear_waypoint()
		self.path=nil
		self.countPath = 1
		self.originX = math.floor(self.caseNewTreeX*32)
		self.originY = math.floor(self.caseNewTreeY*32)
		self:goConstructHomeWith()
		self:setObjectiv("goConstructHomeWith")
		--self:set_waypoint(x,y,100)
		--self:setObjectiv("goHomeToConstruct")
		self.seekingWood = false
		--self.body_graphic:set_color1(0)
	end
end

function nuage:grabWater()
	local waterGrab = self.waterGrab
	self.waterGrab = self.waterGrab + 1
	if waterGrab > 3 then 
		self:set_waypoint(self.originX,self.originY,self.originZ)
		self:setObjectiv("goHomewith")
		--self.body_graphic:set_color1(0)
	end
end

function nuage:_update_obstacle_rule()
  --if self.waypoint.is_active then return end
  local vect = self.obstacle_vector
  local level_map = self.level:get_level_map()
  local nx, ny, val = level_map:get_field_vector_at_position(self.position)
  vect.x, vect.y, vect.z = nx, ny, 0
  
  if vect.x == 0 and vect.y == 0 then 
    return
  end
  
  -- reflect direction of using normal vect
  local dir = self.direction
  local dot = dir.x * vect.x + dir.y * vect.y + dir.z * vect.z
  local angle = math.acos(-dot)
  local eps = 0.0001
  if angle > eps and angle < self.max_obstacle_reflect_angle then
    local dot = dir.x * vect.x + dir.y * vect.y + dir.z * vect.z
    local rx = -2 * dot * vect.x + dir.x
    local ry = -2 * dot * vect.y + dir.y
    local rz = -2 * dot * vect.z + dir.z
    
    -- project reflected vector onto plane normal to bvect
    local dot = rx * vect.x + ry * vect.y + rz * vect.z
    local dx = rx - dot * vect.x
    local dy = ry - dot * vect.y 
    local dz = rz - dot * vect.z
    
    local len = math.sqrt(dx*dx + dy*dy + dz*dz)
    if len > 0 then
      local invlen = 1 / len
      dx, dy, dz = dx*invlen, dy*invlen, dz*invlen
      
      -- mix projected reflection vector with normal vector (bvect)
      local r = self.obstacle_vector_mix_ratio
      dx = r * vect.x + (1-r) * dx
      dy = r * vect.y + (1-r) * dy
      dz = r * vect.z + (1-r) * dz
      len = math.sqrt(dx*dx + dy*dy + dz*dz)
      if len > 0 then
        local factor = (1 / len) * val/2
        vect.x, vect.y, vect.z = factor * dx, factor * dy, factor * dz
      end
    end
  end
end

function nuage:_update_rules(dt)
  if not self.is_initialized then self:_update_boid_life(dt) return end
  self:_clear_rule_vectors()
  self:_update_alignment_rule(dt)
  self:_update_cohesion_rule(dt)
  self:_update_separation_rule(dt)
  self:_update_separation_predator_rule(dt)
  self:_update_boundary_rule(dt)
  self:_update_waypoint_rule(dt/10)
  self:_update_obstacle_rule(dt)
  --self:draw_debug()
  
 --generates a report every 100 frames
love.frame = love.frame + 1
--if love.frame%50 == 0 then
  --love.report = love.profiler.report(50)
  --love.profiler.reset()
  --love.profiler.stop()
--end
  
end

function nuage:_update_target(dt)
  local weights = self.rule_weights
  local targx, targy, targz = 0, 0, 0
  local mag = self.vector_length
  local n = 0
  for vect,weight in pairs(weights) do
    if not (vect.x == 0 and vect.y == 0 and vect.z == 0) then
      targx = targx + vect.x * mag * weight
      targy = targy + vect.y * mag * weight
      targz = (targz + vect.z * mag * weight)
      n = n + 1
    end
  end
  if n > 0 then 
    local inv = 1 / n
    local p = self.position
    targx, targy, targz = targx * inv, targy * inv, targz * inv
    vector3.set(self.target, targx + p.x, targy + p.y, targz + p.z)
  else
    local p = self.position
    local dir = self.direction
    targx, targy, targz = p.x + mag * dir.x, p.y + mag * dir.y, p.z + mag * dir.z
    vector3.set(self.target, targx, targy, targz)
  end
end

function nuage:_update_boid_life(dt)
	
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
	local emote = self.body_graphic:get_emote()
	local needHome = self.needHome
	local age = self.age
	local confuse = self.confuse
	local predatorInView = self.predatorInView
	local hadKid = self.hadKid
	local hadKidTime = self.hadKidTime
	local pollution = self.level:get_pollution()
	local searchObjRad = self.searchObjRad
	local active = self.waypoint.is_active
	
	self.sight_radius = 200 --- pollution
	
	if math.random(1,50)==1 then
		local tile_map = self.level:get_level_map():get_tile_map()
		local i, j , chunk = tile_map:get_chunk_index(self.position)
		chunk:addPollution(1)
			
		local newPosition = vector2:new(0, 0, 0)
		newPosition.x = chunk.x-200
		newPosition.y = chunk.y
		local i, j , chunkLeft = self.level:get_level_map():get_tile_map():get_chunk_index(newPosition)
		if chunkLeft == false then
		
		else
			chunkLeft:addPollutionRight(1)
		end
		
		newPosition.x = chunk.x+300
		newPosition.y = chunk.y
		local i, j , chunkRight = self.level:get_level_map():get_tile_map():get_chunk_index(newPosition)
		if chunkRight == false then
			
		else
			chunkRight:addPollutionLeft(1)
		end
		
		newPosition.x = chunk.x
		newPosition.y = chunk.y-200
		local i, j , chunkTop = self.level:get_level_map():get_tile_map():get_chunk_index(newPosition)
		if chunkTop == false then
			
		else
			chunkTop:addPollutionDown(1)
		end
		
		newPosition.x = chunk.x
		newPosition.y = chunk.y+300
		local i, j , chunkDown = self.level:get_level_map():get_tile_map():get_chunk_index(newPosition)
		if chunkDown == false then
			
		else
			chunkDown:addPollutionTop(1)
		end
	end
	
end

function nuage:goHome()
local inHome = self.inHome
local active = self.waypoint.is_active
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y = self.position.x, self.position.y
local caseX = math.floor( x / h ) + 1
local caseY = math.floor( y / w ) + 1
local originCaseX = math.floor( self.originX / h ) + 1
local originCaseY = math.floor( self.originY / w ) + 1
local foodGrab = self.foodGrab
local woodGrab = self.woodGrab
local waterGrab = self.waterGrab
local countPath = self.countPath
local nbStepPath = self.nbStepPath
local needHome = self.needHome


if inHome == false and active==false and needHome == false then
	if self.path==nil then
		self:updatePath(Vector(caseX,caseY),Vector(originCaseX,originCaseY))
		if self.path~=nil then
			self.nbStepPath = #self.path
			nbStepPath = #self.path
			if countPath < nbStepPath then
				self:set_emote("sleep")
				--self.rule_weights[self.waypoint_vector] = 1000
				--self.rule_weights[self.obstacle_vector] = 1000
				local posX = math.floor( self.path[countPath].x * h ) + 1
				local posY = math.floor( self.path[countPath].y * w ) + 1
				local z = math.random(200,1500)
				self:set_waypoint(posX, posY,z,50,100)
				--self.seeker:add_force(posX,posY,100)
				self:setObjectiv("goOnHome")
				self.countPath = countPath + 1
			else
				if self.emit then
					if self.hunger < 60 and self.emit:get_food()>0 then
						self.emit:min_food(1)
						self:feed(50)
					end
				end
				self:setObjectiv("goSleep")
				local posX = math.floor( self.path[#self.path].x * h ) + 1
				local posY = math.floor( self.path[#self.path].y * w ) + 1
				self:set_waypoint(posX, posY,500,50,100)
				self.countPath =  1
			end
		else
			--self:set_waypoint(posX, posY,500,50,100)
			self:set_waypoint(self.position.x+math.random(-100,100), self.position.y+math.random(-100,100),500,50,100)
			self:setObjectiv("goOnHome")
		end
	else
		if countPath < nbStepPath then
			--self:set_emote("sleep")
			--self.rule_weights[self.waypoint_vector] = 1000
			--self.rule_weights[self.obstacle_vector] = 1000
			local posX = math.floor( self.path[countPath].x * h ) + 1
			local posY = math.floor( self.path[countPath].y * w ) + 1
			self:set_waypoint(posX, posY,500,50,100)
			--self.seeker:add_force(posX,posY,100)
			self:setObjectiv("goOnHome")
			self.countPath = countPath + 1
		else
			if self.emit then
				if self.hunger < 60 and self.emit:get_food()>0 then
					self.emit:min_food(1)
					self:feed(50)
				end
			end
			self:setObjectiv("goSleep")
			local posX = math.floor( self.path[#self.path].x * h ) + 1
			local posY = math.floor( self.path[#self.path].y * w ) + 1
			self:set_waypoint(posX, posY,500,20,50)
			self.countPath =  1
		end
	end
end
end

function nuage:goOnHomeWith()
local inHome = self.inHome
local active = self.waypoint.is_active
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y = self.position.x, self.position.y
local caseX = math.floor( x / h )
local caseY = math.floor( y / w )
local originCaseX = math.floor( self.originX / h )
local originCaseY = math.floor( self.originY / w )
local foodGrab = self.foodGrab
local woodGrab = self.woodGrab
local waterGrab = self.waterGrab
if inHome == false and active == false then
	self:updatePath(Vector(caseX,caseY),Vector(originCaseX,originCaseY))
	if self.path then
		self:clear_waypoint()
		local step = 1
		if #self.path>8 then
			self.rule_weights[self.waypoint_vector] = 1
			--self:set_emote("sleep")
			step = 9
			if self.takeWall > 0 then 
				step = step - 7
				self.takeWall = 0
			end
			local posX = math.floor( self.path[step].x * h ) + 1
			local posY = math.floor( self.path[step].y * w ) + 1
			local z = math.random(200,1500)
			self:set_waypoint(posX, posY,z,50,100)
			--self.seeker:add_force(posX,posY,100)
			self:setObjectiv("goOnHomeWith")
		elseif #self.path>3 then
			step = 4
			self.rule_weights[self.obstacle_vector] = 3000
			local posX = math.floor( self.path[step].x * h ) + 1
			local posY = math.floor( self.path[step].y * w ) + 1
			local z = math.random(200,1500)
			self:set_waypoint(posX, posY,z,50,100)
			--self.seeker:add_force(posX,posY,100)
			self:setObjectiv("goOnHomeWith")
			self.path = nil
		else
			self:setObjectiv("goHomeWithIn")
			local posX = math.floor( self.path[#self.path].x * h ) + 1
			local posY = math.floor( self.path[#self.path].y * w ) + 1
			local z = math.random(200,1500)
			self:set_waypoint(posX, posY,z,50,100)
		end
	end
end
end

function nuage:goConstructHomeWith()
print('je vais a la maison pour construire')
local inHome = self.inHome
local active = self.waypoint.is_active
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y = self.position.x, self.position.y
local caseX = math.floor( x / h )
local caseY = math.floor( y / w )
local originCaseX = math.floor( self.originX / h )
local originCaseY = math.floor( self.originY / w )
local foodGrab = self.foodGrab
local woodGrab = self.woodGrab
local waterGrab = self.waterGrab
local countPath = self.countPath
local nbStepPath = self.nbStepPath
if inHome == false and active == false then
	
	if self.path==nil then
		self:clear_waypoint()
		self:updatePath(Vector(caseX,caseY),Vector(originCaseX,originCaseY))
		self.nbStepPath = #self.path
		if countPath < nbStepPath then
			local posX = math.floor( self.path[countPath].x * h ) + 1
			local posY = math.floor( self.path[countPath].y * w ) + 1
			self:set_waypoint(posX, posY,500,50,100)
			--self.seeker:add_force(posX,posY,100)
			self:setObjectiv("goConstructHomeWith")
			self.countPath = countPath + 1
		end
	else
		local step = 1
		if countPath < nbStepPath then
			local posX = math.floor( self.path[countPath].x * h ) + 1
			local posY = math.floor( self.path[countPath].y * w ) + 1
			self:set_waypoint(posX, posY,500,50,100)
			--self.seeker:add_force(posX,posY,100)
			self:setObjectiv("goConstructHomeWith")
			self.countPath = countPath + 1
		else
			self:setObjectiv("constructNewHome")
			local posX = math.floor( self.path[#self.path].x * h ) + 1
			local posY = math.floor( self.path[#self.path].y * w ) + 1
			self:set_waypoint(posX, posY,500,50,100)
			self.countPath = 1
			self.path = nil
		end
	end
end
end

function nuage:sing(length)
	--[[local x, y = self.position.x, self.position.y
	local hero = self.level:get_player()
	local pos = hero:get_position()
	local volume = self:distance(pos.x, pos.y, x, y)
	if volume > 500 then
		self.sing_sound:setVolume(0)
		self.sing_sound_2:setVolume(0)
	else
		self.sing_sound:setVolume((500-volume)/500)
		self.sing_sound_2:setVolume((500-volume)/500)
	end
	if length == 0 then
		love.audio.play(self.sing_sound)
	else
		love.audio.play(self.sing_sound_2)
	end--]]
	print('va y chante')
	print(self.boidType)
end

function nuage:distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function nuage:seekHome(radius)
local inHome = self.inHome
local active = self.waypoint.is_active
local selfBody = self.body_graphic
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y, z = self.position.x, self.position.y, self.position.z
local caseX = math.floor( x / h ) 
local caseY = math.floor( y / w )
local startX = caseX
local startY = caseY
local maxX = 0
local maxY= 0

self.seekingHome = true

if caseX-radius>5 then
	startX = caseX-radius
elseif caseX-20>5 then
	startX = caseX-20
else
	startX = caseX-5
end
if caseY-radius>5 then
	startY = caseY-radius
elseif caseY-20>5 then
	startY = caseY-20
else
	startY = caseY-5
end
if caseX+radius<Poly.cols-5 then
	maxX = caseX+radius
elseif caseX+20<Poly.cols-5 then
	maxX = caseX+20
else
	maxX = caseX+5
end
if caseY+radius<Poly.rows-5 then
	maxY = caseY+radius
elseif caseY+20<Poly.rows-5 then
	maxY = caseY+20
else
	maxY = caseY+5
end

local mapTrees = self.level:getTreeMap()
local destinationX = self.caseNewTreeX
local destinationY = self.caseNewTreeY
local tree = self.treeFound
local searchObjRad = self.searchObjRad
local countPath = self.countPath

if self.treeFound==nil then
	for stepX = startX, maxX do
		for stepY = startY, maxY do
			if mapTrees[stepX] and self.treeFound==nil then
				if mapTrees[stepX][stepY] then
					if mapTrees[stepX][stepY] ~= nil then
						if mapTrees[stepX][stepY]:getType() == 1 then
							if mapTrees[stepX][stepY]:getNumEmits()<1 and self.level:get_nb_home()<1 then
								if mapTrees[stepX][stepY]:getState() == true then
									--[[self.seekTree = mapTrees[stepX][stepY]:getTree() -- NON CEST ICI QUIL FAUT RECUP LES COORD DE WOOD VIA TREE
									self:seekWood(searchObjRad)
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									print("XXX ICI")
									print(self.caseNewTreeX)
									self.treeFound="wood"--]]
									self.treeFound = "freeTree"
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									destinationX = math.floor(stepX/32)
									destinationY = math.floor(stepY/32)
									self.seekTree = mapTrees[stepX][stepY]:getTree()
								end
							elseif mapTrees[stepX][stepY]:getNumEmits()>0 then
								if mapTrees[stepX][stepY]:getState() == true and mapTrees[stepX][stepY]:getNumBoids()<20 then
									self.treeFound="Tree"
									tree = self.treeFound
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									destinationX = stepX
									destinationY = stepY
									self.seekTree = mapTrees[stepX][stepY]:getTree()
									print("VVV ICI")
								end
							end
						end
					end
				end
			end
		end
	end
end	

if self.treeFound ==nil and active==false then
	local randX = math.random(-300,300)
	local randY = math.random(-300,300)
	if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
		self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
		self:setObjectiv("goOnSeekHome")
		self.searchObjRad = self.searchObjRad + 10
	else
		local randX = math.random(-10,10)
		local randY = math.random(-10,10)
		self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
		self:setObjectiv("goOnSeekHome")
		self.searchObjRad = self.searchObjRad + 10
	end
end

if inHome == false and (tree=="Tree" or tree=="freeTree") and active==false then
	if self.path==nil then
		self:updatePath(Vector(caseX,caseY),Vector(destinationX,destinationY))
		if self.path then
			self.nbStepPath = #self.path
			--selfBody:set_color1(0)
			self.step = self.nbStepPath
		else
			local randX = math.random(-300,300)
			local randY = math.random(-300,300)
			if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
				self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
				self:setObjectiv("goOnSeekHome")
				self.searchObjRad = self.searchObjRad + 10
				self.treeFound = nil
				return
			else
				local randX = math.random(-10,10)
				local randY = math.random(-10,10)
				self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
				self:setObjectiv("goOnSeekHome")
				self.searchObjRad = self.searchObjRad + 10
				self.treeFound = nil
				return
			end
		end
	end
	self:clear_waypoint()
	if countPath < self.nbStepPath then
		self:setObjectiv("goOnSeekHome")
		local posX = math.floor( self.path[countPath].x * h ) + 1
		local posY = math.floor( self.path[countPath].y * w ) + 1
		self:set_waypoint(posX, posY,500,50,100)
		--self.step = self.step + self.step
		self.countPath = countPath + 1
	else
		self.step = #self.path
		if tree=="freeTree" then
			if self.seekTree then
				self:setObjectiv("setNewHome")
				self.free = false
				self.countPath = 1
				--self.seekTree:setNumEmits(1)
				self.seekingHome = false
				self.treeFound = nil
				self.homeTree = self.seekTree
			else
				self:setObjectiv("seekHome")
			end
		else
			if self.seekTree:getNumBoids()<20 then
				self:setObjectiv("setNewHome")
				self.searchObjRad = 10
				self.free = false
				self.countPath = 1
				self.seekingHome = false
			else
				local randX = math.random(-300,300)
				local randY = math.random(-300,300)
				if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
					self.treeFound = nil
					self:set_waypoint(x+randX, y+randY,z+math.random(50,100),50,100)
					self:setObjectiv("goOnSeekHome")
					self.searchObjRad = self.searchObjRad + 10
				else
					self.treeFound = nil
					local randX = math.random(-10,10)
					local randY = math.random(-10,10)
					self:set_waypoint(x+randX, y+randY,z+math.random(50,100),50,100)
					self:setObjectiv("goOnSeekHome")
					self.searchObjRad = self.searchObjRad + 10
				end
			end
		end
		local posX = math.floor( self.path[self.step].x * h ) + 1
		local posY = math.floor( self.path[self.step].y * w ) + 1
		self:set_waypoint(posX, posY,500,50,100)
	end		
end
end

function nuage:seekTreeFroSleep(radius)
local inHome = self.inHome
local active = self.waypoint.is_active
local selfBody = self.body_graphic
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y, z = self.position.x, self.position.y, self.position.z
local caseX = math.floor( x / h ) 
local caseY = math.floor( y / w )
local startX = caseX
local startY = caseY
local maxX = 0
local maxY= 0
local needHome = self.needHome
local mapTrees = self.level:getTreeMap()
local destinationX = self.caseNewTreeX
local destinationY = self.caseNewTreeY
local tree = self.treeFound
local searchObjRad = self.searchObjRad
local countPath = self.countPath

if needHome==false then
	self:goHome()
	return
end

self.seekingHome = true

if caseX-radius>5 then
	startX = caseX-radius
elseif caseX-20>5 then
	startX = caseX-20
else
	startX = caseX-5
end
if caseY-radius>5 then
	startY = caseY-radius
elseif caseY-20>5 then
	startY = caseY-20
else
	startY = caseY-5
end
if caseX+radius<Poly.cols-5 then
	maxX = caseX+radius
elseif caseX+20<Poly.cols-5 then
	maxX = caseX+20
else
	maxX = caseX+5
end
if caseY+radius<Poly.rows-5 then
	maxY = caseY+radius
elseif caseY+20<Poly.rows-5 then
	maxY = caseY+20
else
	maxY = caseY+5
end

if self.treeFound==nil then
	for stepX = startX, maxX do
		for stepY = startY, maxY do
			if mapTrees[stepX] and self.treeFound==nil then
				if mapTrees[stepX][stepY] then
					if mapTrees[stepX][stepY] ~= nil then
						if mapTrees[stepX][stepY]:getType() == 1 then
							if mapTrees[stepX][stepY]:getNumEmits()<1 and self.level:get_nb_home()<1 then
								if mapTrees[stepX][stepY]:getState() == true then
									--[[self.seekTree = mapTrees[stepX][stepY]:getTree() -- NON CEST ICI QUIL FAUT RECUP LES COORD DE WOOD VIA TREE
									self:seekWood(searchObjRad)
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									print("XXX ICI")
									print(self.caseNewTreeX)
									self.treeFound="wood"--]]
									self.treeFound = "freeTree"
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									destinationX = math.floor(stepX/32)
									destinationY = math.floor(stepY/32)
									self.seekTree = mapTrees[stepX][stepY]:getTree()
								end
							elseif mapTrees[stepX][stepY]:getNumEmits()>0 then
								if mapTrees[stepX][stepY]:getState() == true and mapTrees[stepX][stepY]:getNumBoids()<20 then
									self.treeFound="Tree"
									tree = self.treeFound
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									destinationX = stepX
									destinationY = stepY
									self.seekTree = mapTrees[stepX][stepY]:getTree()
								end
							end
						end
					end
				end
			end
		end
	end
end	

if self.treeFound ==nil and active==false then
	local randX = math.random(-300,300)
	local randY = math.random(-300,300)
	if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
		self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
		self:setObjectiv("goOnSeekTree")
		self.searchObjRad = self.searchObjRad + 10
	else
		local randX = math.random(-10,10)
		local randY = math.random(-10,10)
		self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
		self:setObjectiv("goOnSeekTree")
		self.searchObjRad = self.searchObjRad + 10
	end
end

if inHome == false and (tree=="Tree" or tree=="freeTree") and active==false then
	if self.path==nil then
		self:updatePath(Vector(caseX,caseY),Vector(destinationX,destinationY))
		if self.path then
			self.nbStepPath = #self.path
			--selfBody:set_color1(0)
			self.step = self.nbStepPath
		else
			local randX = math.random(-300,300)
			local randY = math.random(-300,300)
			if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
				self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
				self:setObjectiv("goOnSeekTree")
				self.searchObjRad = self.searchObjRad + 10
				self.treeFound = nil
			else
				local randX = math.random(-10,10)
				local randY = math.random(-10,10)
				self:set_waypoint(x+randX, y+randY,math.random(50,100),50,100)
				self:setObjectiv("goOnSeekTree")
				self.searchObjRad = self.searchObjRad + 10
				self.treeFound = nil
			end
		end
	end
	self:clear_waypoint()
	if countPath < self.nbStepPath then
		self:setObjectiv("goOnSeekTree")
		local posX = math.floor( self.path[countPath].x * h ) + 1
		local posY = math.floor( self.path[countPath].y * w ) + 1
		self:set_waypoint(posX, posY,500,50,100)
		--self.step = self.step + self.step
		self.countPath = countPath + 1
	else
		self.step = #self.path
		if tree=="freeTree" then
			if self.seekTree then
				self:setObjectiv("goSleep")
				self.countPath = 1
				--self.seekTree:setNumEmits(1)
				self.treeFound = nil
			else
				self:setObjectiv("seekHome")
			end
		else
			if self.seekTree:getNumBoids()<20 then
				self:setObjectiv("goSleep")
				self.searchObjRad = 10
				self.countPath = 1
			else
				local randX = math.random(-300,300)
				local randY = math.random(-300,300)
				if x+randX > 500 and x+randX < 12800 and y+randY > 500 and y+randY < 12800 then
					self.treeFound = nil
					self:set_waypoint(x+randX, y+randY,z+math.random(50,100),50,100)
					self:setObjectiv("goOnSeekTree")
					self.searchObjRad = self.searchObjRad + 10
				else
					self.treeFound = nil
					local randX = math.random(-10,10)
					local randY = math.random(-10,10)
					self:set_waypoint(x+randX, y+randY,z+math.random(50,100),50,100)
					self:setObjectiv("goOnSeekTree")
					self.searchObjRad = self.searchObjRad + 10
				end
			end
		end
		local posX = math.floor( self.path[self.step].x * h ) + 1
		local posY = math.floor( self.path[self.step].y * w ) + 1
		self:set_waypoint(posX, posY,500,50,100)
	end		
end
end

function nuage:seekFood(radius)
local active = self.waypoint.is_active
local selfBody = self.body_graphic
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y, z = self.position.x, self.position.y, self.position.z
local caseX = math.floor( x / h ) 
local caseY = math.floor( y / w )
local startX = caseX
local startY = caseY
local maxX = 0
local maxY= 0
local tree = self.treeFound

if caseX-radius>5 then
	startX = caseX-radius
else
	startX = caseX-5
end
if caseY-radius>5 then
	startY = caseY-radius
else
	startY = caseY-5
end
if caseX+radius<Poly.cols-5 then
	maxX = caseX+radius
else
	maxX = caseX+5
end
if caseY+radius<Poly.rows-5 then
	maxY = caseY+radius
else
	maxY = caseY+5
end

local mapTrees = self.level:getTreeMap()
local destinationX = self.caseNewTreeX
local destinationY = self.caseNewTreeY
local searchObjRad = self.searchObjRad
local countPath = self.countPath

if self.treeFound==nil then
	for stepX = startX, maxX do
		for stepY = startY, maxY do
			if mapTrees[stepX] then
				if mapTrees[stepX][stepY] then
					if mapTrees[stepX][stepY] ~= nil then
						if mapTrees[stepX][stepY]:getType() == 3 then
							if mapTrees[stepX][stepY]:getFood() > 0 then
								if mapTrees[stepX][stepY]:getState() == true then
									self.foodFound = 1
									self.caseNewTreeX = stepX
									self.caseNewTreeY = stepY
									destinationX = stepX
									destinationY = stepY
									mapTrees[stepX][stepY]:setNumEmits(1)
									self.treeFound="bush"
									tree = self.treeFound
									self.path=nil
									print("j'ai trouve un bush en")
									print(stepX,stepY)
								end
							end
						end
					end
				end
			end
		end
	end	
end

if active==false then
	local randX = nil
	local randY = nil
	local rand = math.random(1,4)
	if rand==1 then
		randX = math.random(-100,-50)
		randY = math.random(-100,-50)
	elseif rand==2 then
		randX = math.random(50,100)
		randY = math.random(50,100)
	elseif rand==3 then
		randX = math.random(50,50)
		randY = math.random(-50,-100)
	elseif rand==4 then
		randX = math.random(-50,-100)
		randY = math.random(50,100)
	end
	if x+randX > 50 and x+randX < 12800 and y+randY > 50 and y+randY < 12800 then
		self:set_waypoint(x+randX, y+randY,math.random(100,300),20,50)
		self:setObjectiv("goOnSeekFood")
		self.searchObjRad = self.searchObjRad + 5
		self.path=nil
	else
		self:set_waypoint(x+50, y+50,math.random(100,300),20,50)
		self:setObjectiv("goOnSeekFood")
		self.searchObjRad = self.searchObjRad + 5
		self.path=nil
	end
end


if tree=="bush" and active==false then
	if self.path==nil then
		self:updatePath(Vector(caseX,caseY),Vector(destinationX,destinationY))
		if self.path then
			self.nbStepPath = #self.path
		else
		return end
		--selfBody:set_color1(0)
		self.step = self.nbStepPath
	end
	self:clear_waypoint()
	if countPath < self.nbStepPath then
		self:setObjectiv("goOnSeekFood")
		local posX = math.floor( self.path[countPath].x * h ) + 1 -------- A REVOIRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR 
		local posY = math.floor( self.path[countPath].y * w ) + 1
		self:set_waypoint(posX, posY,500,50,100)
		--self.step = self.step + self.step
		self.countPath = countPath + 1
	else
		self.step = #self.path
		self:setObjectiv("fly")
		self.searchObjRad = 10
		--local posX = math.floor( self.path[self.step].x * h ) + 1
		--local posY = math.floor( self.path[self.step].y * w ) + 1
		self:clear_waypoint()
		self.path=nil
		self.treeFound = nil
		self.countPath = 1
		--self:set_waypoint(posX, posY,500,50,100)
	end		
end
end

function nuage:seekWood(radius)
local active = self.waypoint.is_active
local selfBody = self.body_graphic
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y, z = self.position.x, self.position.y, self.position.z
local caseX = math.floor( x / h ) 
local caseY = math.floor( y / w )
local startX = caseX
local startY = caseY
local maxX = 0
local maxY= 0
local tree = self.treeFound



self.seekingWood = true

if caseX-radius>5 then
	startX = caseX-radius
else
	startX = caseX-5
end
if caseY-radius>5 then
	startY = caseY-radius
else
	startY = caseY-5
end
if caseX+radius<Poly.cols-5 then
	maxX = caseX+radius
else
	maxX = caseX+5
end
if caseY+radius<Poly.rows-5 then
	maxY = caseY+radius
else
	maxY = caseY+5
end

local mapTrees = self.level:getTreeMap()
local destinationX = self.caseNewTreeX
local destinationY = self.caseNewTreeY
local searchObjRad = self.searchObjRad
local countPath = self.countPath


if self.woodFound == nil then
	for stepX = startX, maxX do
		for stepY = startY, maxY do
			if mapTrees[stepX] then
				if mapTrees[stepX][stepY] then
					if mapTrees[stepX][stepY] ~= nil then
						if mapTrees[stepX][stepY]:getType() == 2 then --ici faut chercher sur tree puis wood
							self.woodFound = 1
							destinationX = stepX
							destinationY = stepY
							self.path=nil
						end
					end
				end
			end
		end
	end	
end

local woodFound = self.woodFound

if woodFound==1 and active==false then
	if self.path==nil then
		self:updatePath(Vector(caseX,caseY),Vector(destinationX,destinationY))
		if self.path then
			if math.floor(#self.path) > 10 then 
				self.nbStepPath = #self.path--math.floor(#self.path / 10)
			else
				self.nbStepPath = #self.path
			end
		else
		return end
		--selfBody:set_color1(0)
		self.step = self.nbStepPath
	end
	self:clear_waypoint()
	if countPath < self.nbStepPath then
		self:setObjectiv("goOnSeekWood")
		local posX = math.floor( self.path[countPath].x * h ) + 1 -------- A REVOIRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR 
		local posY = math.floor( self.path[countPath].y * w ) + 1
		self:set_waypoint(posX, posY,150,10,20)
		--self.step = self.step + self.step
		self.countPath = countPath + 1
	elseif active==false then
		self.step = #self.path
		self:clear_waypoint()
		self.path=nil
		--self:set_waypoint(posX, posY,500,50,100)
		self.searchObjRad = 10
		--self:seekHome(10)
		self.treeFound = nil
		self.countPath = 1
		self:setObjectiv("fly")
		self.woodFound = nil
	end		
end

if active==false and woodFound==nil then
	local randX = math.random(-100,100)
	local randY = math.random(-100,100)

	if x+randX > 50 and x+randX < 12800 and y+randY > 50 and y+randY < 12800 then
		self:set_waypoint(x+randX, y+randY,150+randX,20,50)
		self:setObjectiv("goOnSeekWood")
		self.searchObjRad = self.searchObjRad + 5
	else
		self:set_waypoint(x+50, y+50,150+randX,20,50)
		self:setObjectiv("goOnSeekWood")
		self.searchObjRad = self.searchObjRad + 5
	end
end


end

function nuage:goHero()
local inHero = self.inHero
local active = self.waypoint.is_active
local selfBody = self.body_graphic
local hero = self.level:get_player()
local heroPosX = hero:get_posX()
local heroPosY = hero:get_posY()
local level_map = self.level:get_level_map()
local Poly = level_map.polygonizer
local w, h = Poly.cell_width, Poly.cell_height
local x, y = self.position.x, self.position.y
local caseX = math.floor( x / h ) + 1
local caseY = math.floor( y / w ) + 1
local heroCaseX = math.floor( heroPosX / h ) + 1
local heroCaseY = math.floor( heroPosY / w ) + 1
local countPath = self.countPath

self:set_waypoint(heroPosX, heroPosY,300,50,100)
self:setObjectiv("goOnHero")

--[[if inHero == false and active == false then
	--selfBody:set_color1(0)
	if self.path then
		if math.floor(#self.path) > 10 then 
			self.nbStepPath = #self.path--math.floor(#self.path / 10)
		else
			self.nbStepPath = #self.path
		end
		self:clear_waypoint()
		if countPath < self.nbStepPath then
			local posX = math.floor( self.path[countPath].x * h ) + 1
			local posY = math.floor( self.path[countPath].y * w ) + 1
			self:set_waypoint(posX, posY,300,50,100)
			self:setObjectiv("goOnHero")
			self.countPath = countPath + 1
		else
			local posX = math.floor( self.path[countPath].x * h ) + 1
			local posY = math.floor( self.path[countPath].y * w ) + 1
			self:set_waypoint(posX, posY,300,50,100)
			self:setObjectiv("goOnHero")
			self.countPath = 1
		end
	else
		self:updatePath(Vector(caseX,caseY),Vector(heroCaseX,heroCaseY))
		self:clear_waypoint()
		local step = 1
		if #self.path>2 then
			step = 3 -- math.ceil(#self.path/(#self.path))
			local posX = math.floor( self.path[step].x * h ) + 1
			local posY = math.floor( self.path[step].y * w ) + 1
			self:set_waypoint(posX, posY,300,50,100)
			self:setObjectiv("goOnHero")
		else
			step = 1
			local posX = math.floor( self.path[step].x * h ) + 1
			local posY = math.floor( self.path[step].y * w ) + 1
			self:set_waypoint(posX, posY,300,50,100)
			self:setObjectiv("goOnHero")
		end
	end
end--]]
end

function nuage:setFlock(flock)
	
end

function nuage:feed(nb)
local myHunger = self.hunger
	if myHunger < 100 then
		if myHunger + nb > 100 then
			self.hunger = 100
			self.body_graphic:set_color4(255)
			--self.age = self.age + 1
			return true
		else
			self.hunger = myHunger + nb
			self.body_graphic:set_color4(255)
			--self.age = self.age + 1
			return true
		end
	else
		return false
	end
end

function nuage:set_emote(emoteType)
	self.body_graphic:set_emote(emoteType)
	self.emoteTime = 0
end

function nuage:set_needHome(bool)
	self.needHome = bool
end

function nuage:update(dt)
    if not self.is_initialized then self:_update_boid_life(dt) return end
    self:_update_neighbours(dt/20)
	self:_update_rules(dt)
    self:_update_target(dt)
    self:_update_seeker(dt)
    self:_update_map_point(dt)
    self:_update_graphic_orientation(dt/10)
    self:_update_boid_orientation(dt/10)
	self:_update_boid_life(dt/30)	
	
	local animationNuage = self.animationNuage
	if animationNuage.currentTime + dt < animationNuage.duration then
		animationNuage.currentTime = animationNuage.currentTime + dt
	end
	
end

function nuage:updatePath(start,finish)
	local level_map = self.level:get_level_map()
	local map = level_map:getWallMap()
	self.path = Luafinding( start, finish, map ):GetPath()
end

function nuage:draw_shadow()
  if not self.is_initialized then return end
  local x, y, z = self:get_position()
  self.body_graphic:draw_shadow(x, y)
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


------------------------------------------------------------------------------
function nuage:_draw_debug_rule_vector(vector, label)
  local v = vector
  local x1, y1 = self.position.x, self.position.y
  if not (v.x == 0 and v.y == 0 and v.z == 0) then
    local len = 500 --self.sight_radius
    local x2, y2 = x1 + v.x * len, y1 + v.y * len
    lg.setColor(0, 0, 255, 50)
    lg.setLineWidth(3)
    lg.line(x1, y1, x2, y2)
    lg.print(label, x2, y2)
  end
  
end

function nuage:mousepressed(mx, my, button)
	local x, y = self.x , self.y
	if mx/32>x-5 and mx/32<x+5 and my/32>y-5 and my/32<y+5 then
		self.drawInfo = true
		self.level:set_select(self)
	end
end

function nuage:draw_debug()
  
end

function nuage:draw()
  --[[if not self.is_initialized then
	local inHome = self.inHome
	if inHome == false then
		local x, y, z = self:get_position()
		lg.setColor(255, 255, 255, 1)
		lg.draw(self.illuFloor, x-25, y-25)
	end
  return end
  debugText = self.rule_weights[self.separation_vector]
  local x, y, z = self:get_position()
  
  self.body_graphic:draw(x, y)
  
  --self.animation:draw(x, y)
  
  lg.setColor(0, 100, 255, 255)
  --print(love.report or "Please wait...")
  
  --lg.print(debugText, self.position.x, self.position.y)
 -- lg.print(debugText2, 100, 1100)
  --lg.print(debugText3, 100, 1200)
  
  
  lg.setLineWidth(1)
  lg.setColor(0, 0, 0, 10)
  for i=1,#self.neighbours do
    local b = self.neighbours[i]
    lg.line(x, y, b.position.x, b.position.y)
  end
  ]]--
  
  --[[if self.path then
        love.graphics.setColor( 0, 0.8, 0 )
        for _, v in ipairs( self.path ) do
            love.graphics.rectangle( "fill", ( v.x - 1 ) * 32, ( v.y - 1 ) * 32, 32, 32 )
        end
        love.graphics.setColor( 0, 0, 0 )
  end]]--
  --local cx, cy = self.level:get_camera():get_viewport()
  local x, y, z = self:get_position()
  lg.setColor(255, 255, 255, 1)
  local animationNuage = self.animationNuage
  local spriteNum = math.floor(animationNuage.currentTime / animationNuage.duration * #animationNuage.quads) + 1
  lg.draw(animationNuage.spriteSheet, animationNuage.quads[spriteNum], x-212, y-186)
  
end

return nuage



