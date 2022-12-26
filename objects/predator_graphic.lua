local lg = love.graphics
local vector3 = require("vector3")

local LX, LY, LZ = 1, 2, -6
do
  local invlen = 1 / math.sqrt(LX*LX + LY*LY + LZ*LZ)
  LX, LY, LZ = LX * invlen, LY * invlen, LZ * invlen
end

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_graphic object (Rotatable triangle centred at origin)
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local pg = {}
pg.table = 'pg'
pg.debug = true
pg.width = nil
pg.height = nil
pg.points = nil
pg.draw_points = nil
pg.shadow_points = nil

pg.rotation_angle = 0
pg.pitch_angle = 0
pg.roll_angle = 0
pg.scale = 1
pg.intensity = 1
pg.altitude = 0
pg.min_altitude = 0
pg.max_altitude = 200
pg.min_alpha = 0
pg.max_alpha = 1

pg.color1 = 255
pg.color2 = 255
pg.color3 = 255
pg.color4 = 255

pg.emote = nil
pg.emote_question = nil
pg.emote_sleep = nil
pg.emoteType = nil

pg.gradient = require("gradients/named/greenyellow")
pg.grad_offset = nil

pg.is_current = false

local pg_mt = { __index = pg }
function pg:new(width, height)
  local pg = setmetatable({}, pg_mt)
  pg.width, pg.height = width, height
  pg:_init_geometry()
  pg:_init_draw_points()
  
  self.grad_offset = math.random(0,60)
  self.emote_question = love.graphics.newImage("images/emote/style_4/emote_question.png")
  self.emote_sleep = love.graphics.newImage("images/emote/style_6/emote_sleeps.png")
  self.emote_food = love.graphics.newImage("images/emote/style_4/emote_food.png")
  self.emote_love = love.graphics.newImage("images/emote/style_4/emote_heart.png")
  
  return pg
end

function pg:_init_geometry()
  -- triangle centred at origin, nose aligned with +x axis
  local w, h =self.width, self.height
  local p1 = {x = 0.5 * h, y = 0, z = 0}
  local p2 = {x = -0.5 * h, y = 0.5 * w, z = 0}
  local p3 = {x = -0.5 * h, y = -0.5 * w, z = 0}
  self.points = {p1, p2, p3}
  
  -- find centroid and subtract offset to centre at origin
  local cx = (p1.x + p2.x + p3.x) / 3
  local cy = (p1.y + p2.y + p3.y) / 3
  local cz = (p1.z + p2.z + p3.z) / 3
  vector3.add(p1, -cx, -cy, -cz)
  vector3.add(p2, -cx, -cy, -cz)
  vector3.add(p3, -cx, -cy, -cz)
end

function pg:_init_draw_points()
  local dp = {}
  local sp = {}
  local points = self.points
  for i=1,#points do
    dp[i] = {}
    sp[i] = {}
    vector3.clone(points[i], dp[i])
    vector3.clone(points[i], sp[i])
  end
  self.draw_points = dp
  self.shadow_points = sp
end

function pg:set_pitch_angle(angle)
  self.pitch_angle = angle
  self.is_current = false
end

function pg:set_roll_angle(angle)
  self.roll_angle = angle
  self.is_current = false
end

function pg:set_rotation_angle(angle)
  self.rotation_angle = angle
  self.is_current = false
end

function pg:set_scale(scale)
  self.scale = scale
  self.is_current = false
end

function pg:set_altitude(alt)
  self.altitude = alt
  self.is_current = false
end

function pg:set_gradient(grad_table)
  self.gradient = grad_table
end

function pg:set_color4(color)
  self.color4 = color
end

function pg:set_color1(color)
  self.color1 = color
end

function pg:get_emote()
  return self.emoteType
end

function pg:set_emote(emoteType)
  self.emoteType = emoteType
  if emoteType == "sleep" then
	self.emote = self.emote_sleep
  elseif emoteType == "question" then
	self.emote = self.emote_question
  elseif emoteType == "tired" then
	self.emote = self.tired
  elseif emoteType == nil then
	self.emote = nil
  elseif emoteType == "food" then
	self.emote = self.emote_food
  elseif emoteType == "love" then
	self.emote = self.emote_love
  end
end

------------------------------------------------------------------------------
function pg:_reset_draw_points()
  local dp = self.draw_points
  for i=1,#dp do
    vector3.clone(self.points[i], dp[i])
  end
end

function pg:_update_rotation()
  if self.rotation_angle == 0 then return end

  local angle = self.rotation_angle
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  local cosval, sinval = math.cos(angle), math.sin(angle)
  p1.x, p1.y = p1.x*cosval - p1.y*sinval, p1.x*sinval + p1.y*cosval
  p2.x, p2.y = p2.x*cosval - p2.y*sinval, p2.x*sinval + p2.y*cosval
  p3.x, p3.y = p3.x*cosval - p3.y*sinval, p3.x*sinval + p3.y*cosval
end

function pg:_update_pitch()
  if self.pitch_angle == 0 then return end

  local th = self.pitch_angle
  
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  
  local u, v, w = p3.x - p2.x, p3.y - p2.y, 0       -- rotation axis
  local invlen = 1 / math.sqrt(u*u + v*v)
  u, v = u * invlen, v * invlen
  
  local costh = math.cos(th)
  local sinth = math.sin(th)
  local minus_costh = 1 - costh
  
  for i=1,#self.draw_points do 
    local p = self.draw_points[i]
    local x, y, z = p.x, p.y, p.z
    local term = -u*x-v*y-w*z
    local term1, term2, term3 = -u*(term)*minus_costh,
                                -v*(term)*minus_costh,
                                -w*(term)*minus_costh
    
    p.x, p.y, p.z = term1+x*costh+(-w*y+v*z)*sinth,
                    term2+y*costh+(w*x-u*z)*sinth,
                    term3+z*costh+(-v*x+u*y)*sinth
  end
end

function pg:_update_roll()
  if self.roll_angle == 0 then return end
  
  local th = self.roll_angle
  
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  
  local midx, midy, midz = p2.x + 0.5 * (p3.x - p2.x),
                           p2.y + 0.5 * (p3.y - p2.y),
                           p2.z + 0.5 * (p3.z - p2.z)
  
  local u, v, w = p1.x - midx, p1.y - midy, p1.z - midz
  local invlen = 1 / math.sqrt(u*u + v*v + w*w)
  u, v, w = u * invlen, v * invlen, w * invlen
  
  local costh = math.cos(th)
  local sinth = math.sin(th)
  local minus_costh = 1 - costh
  
  for i=2,#self.draw_points do 
    local p = self.draw_points[i]
    local x, y, z = p.x, p.y, p.z
    local term = -u*x-v*y-w*z
    local term1, term2, term3 = -u*(term)*minus_costh,
                                -v*(term)*minus_costh,
                                -w*(term)*minus_costh
    
    p.x, p.y, p.z = term1+x*costh+(-w*y+v*z)*sinth,
                    term2+y*costh+(w*x-u*z)*sinth,
                    term3+z*costh+(-v*x+u*y)*sinth
  end
end

function pg:_update_scale()
  if self.scale == 1 then return end

  local s = self.scale
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  
  p1.x, p1.y, p1.z = p1.x * s, p1.y * s, p1.z * s
  p2.x, p2.y, p2.z = p2.x * s, p2.y * s, p2.z * s
  p3.x, p3.y, p3.z = p3.x * s, p3.y * s, p3.z * s
end

function pg:_update_shadow()
  local dp1, dp2, dp3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3]
  local z = self.altitude
  
  local local_time = MASTER_TIMER:get_time()
  local journeyTime = 0
  
  --[[if local_time>25 and local_time<40 then
	journeyTime = 250-local_time*8
  elseif local_time>41 and local_time<70 then
	journeyTime = -30 - local_time
  elseif local_time>71 and local_time<100 then
	journeyTime = 500
  elseif local_time>1 and local_time<25 then
	journeyTime = 300-local_time*10
  end--]]
  
  if dp1.z + z > 0 then
    local d = -(dp1.z + z) / LZ
    p1.x, p1.y = d * LX + dp1.x+journeyTime, d * LY + dp1.y
  else
    p1.x, p1.y = dp1.x+journeyTime, dp1.y
  end
  
  if dp2.z + z > 0 then
    local d = -(dp2.z + z) / LZ
    p2.x, p2.y = d * LX + dp2.x+journeyTime, d * LY + dp2.y
  else
    p2.x, p2.y = dp2.x+journeyTime, dp2.y
  end
  
  if dp3.z + z > 0 then
    local d = -(dp3.z + z) / LZ
    p3.x, p3.y = d * LX + dp3.x +journeyTime, d * LY + dp3.y
  else
    p3.x, p3.y = dp3.x+journeyTime, dp3.y
  end
  
  local mina, maxa = self.min_alpha, self.max_alpha
  local minalt, maxalt = self.min_altitude, self.max_altitude
  local alt = self.altitude/10
  local prog = 1 - ((alt - minalt) / (maxalt - minalt))
  prog = math.min(prog, 1)
  prog = math.max(prog, 0)
  self.shadow_alpha = mina + prog * (maxa - mina)
  if local_time>71 and local_time<100 then
	self.shadow_alpha = 0
  end
end

function pg:_update_geometry()
  self:_reset_draw_points()
  self:_update_scale()
  self:_update_rotation()
  self:_update_pitch()
  self:_update_roll()
  self:_update_shadow()
end

function pg:_update_intensity()
  -- find normal
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  local v1x, v1y, v1z = p3.x - p1.x, p3.y - p1.y, p3.z - p1.z
  local v2x, v2y, v2z = p2.x - p1.x, p2.y - p1.y, p2.z - p1.z
  
  local nx = v1y*v2z - v1z*v2y
  local ny = v1z*v2x - v1x*v2z
  local nz = v1x*v2y - v1y*v2x
  local invlen = 1 / math.sqrt(nx*nx + ny*ny + nz*nz)
  nx, ny, nz = nx * invlen, ny * invlen, nz * invlen
  local lx, ly, lz = 0, 0, 1
  self.intensity = math.abs(lx*nx + ly*ny + lz*nz)
end

function pg:update(dt)
  if self.is_current then return end
  
  self:_update_geometry()
  self:_update_intensity()
end

------------------------------------------------------------------------------
function pg:draw_shadow(x, y)
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3] 
  lg.setColor(0, 0, 0, self.shadow_alpha)
  lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
end

function pg:draw(x, y)
  local p1, p2, p3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  lg.setColor(100, 0, 0, 255)
  lg.line(p1.x + x, p1.y + y, p2.x + x, p2.y + y)
  lg.line(p2.x + x, p2.y + y, p3.x + x, p3.y + y)
  lg.line(p3.x + x, p3.y + y, p1.x + x, p1.y + y)

  --[[local i = self.intensity
  if self.gradient then
	  local idx = math.floor(1 + i * (#self.gradient - 1)) + self.grad_offset
	  if idx ~= idx then
		idx = 1
	  end
	  if idx < 1 then idx = 1 end
	  if idx > #self.gradient then idx = #self.gradient end
  end
  
  local c = self.gradient[idx]
  lg.setColor(c)
  ]]--
  --lg.setColor(self.color1,self.color2,self.color3,self.color4)
  lg.setColor(255, 255, 255, 255)
  lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
  
  --love.graphics.circle( "fill", p1.x, p1.y, 10 )
  
  lg.setColor(255, 255, 255, 255)
  if self.emoteType~=nil then 
	local cx = (p1.x + p2.x + p3.x) / 3
    local cy = (p1.y + p2.y + p3.y) / 3
    local cz = (p1.z + p2.z + p3.z) / 3
	love.graphics.draw(self.emote, cx+x-16, cy+y-38)
  end

  if not self.debug then return end
  
end

return pg















