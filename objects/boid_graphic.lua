local lg = love.graphics
local vector3 = require("vector3")

local LX, LY, LZ = -1, -1, -6
do
  local invlen = 1 / math.sqrt(LX*LX + LY*LY + LZ*LZ)
  LX, LY, LZ = LX * invlen, LY * invlen, LZ * invlen
end

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- boid_graphic object (Rotatable triangle centred at origin)
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local bg = {}
bg.table = 'bg'
bg.debug = true
bg.width = nil
bg.height = nil
bg.points = nil
bg.draw_points = nil
bg.shadow_points = nil

bg.rotation_angle = 0
bg.pitch_angle = 0
bg.roll_angle = 0
bg.scale = 1
bg.intensity = 1
bg.altitude = 0
bg.min_altitude = 0
bg.max_altitude = 200
bg.min_alpha = 0
bg.max_alpha = 1

bg.color1 = 255
bg.color2 = 255
bg.color3 = 255
bg.color4 = 255

bg.emote = nil
bg.emote_question = nil
bg.emote_sleep = nil
bg.emoteType = nil

bg.gradient = require("gradients/named/greenyellow")
bg.grad_offset = nil

bg.is_current = false

bg.wing = 0
bg.wingWay = true

local bg_mt = { __index = bg }
function bg:new(width, height)
  local bg = setmetatable({}, bg_mt)
  bg.width, bg.height = width, height
  bg:_init_geometry()
  bg:_init_draw_points()
  
  self.grad_offset = math.random(0,60)
  self.emote_question = love.graphics.newImage("images/emote/style_4/emote_question.png")
  self.emote_sleep = love.graphics.newImage("images/emote/style_6/emote_sleeps.png")
  self.emote_food = love.graphics.newImage("images/emote/style_4/emote_food.png")
  self.emote_love = love.graphics.newImage("images/emote/style_4/emote_heart.png")
  self.emote_exclamation = love.graphics.newImage("images/emote/style_4/emote_exclamation.png")
  self.emote_faceHappy = love.graphics.newImage("images/emote/style_4/emote_faceHappy.png")
  self.emote_hungry = love.graphics.newImage("images/emote/style_6/emote_hungry.png")
  self.emote_home = love.graphics.newImage("images/emote/style_6/emote_home.png")
  
  return bg
end

function bg:_init_geometry()
  -- triangle centred at origin, nose aligned with +x axis
  local w, h =self.width, self.height
  local p1 = {x = 0.25 * h, y = 0, z = 0}
  local p2 = {x = -0.25 * h, y = 0.5 * w, z = 0}
  local p3 = {x = -0.25 * h, y = -0.5 * w, z = 0}
  local p4 = {x = -1 * h, y = 1 * w, z = 0}
  local p5 = {x = -1 * h, y = -1 * w, z = 0}
  local p6 = {x = -2 * h, y = 0.5 * w, z = 0}
  local p7 = {x = -2 * h, y = -0.5 * w, z = 0}
  local p8 = {x = -1.5 * h, y = 1.25 * w, z = 0}
  local p9 = {x = -1.5 * h, y = -1.25 * w, z = 0}
  local p10 = {x = -4 * h, y = 3 * w, z = 0}
  local p11 = {x = -4 * h, y = -3 * w, z = 0}
  local p12 = {x = -3 * h, y = 1 * w, z = 0}
  local p13 = {x = -3 * h, y = -1 * w, z = 0}
  local p14 = {x = -3.25 * h, y = 0.5 * w, z = 0}
  local p15 = {x = -3.25 * h, y = -0.5 * w, z = 0}
  local p16 = {x = -5 * h, y = 0.25 * w, z = 0}
  local p17 = {x = -6 * h, y = 0.5 * w, z = 0}
  local p18 = {x = -5 * h, y = 0 * w, z = 0}
  local p19 = {x = -6 * h, y = -0.5 * w, z = 0}
  local p20 = {x = -5 * h, y = -0.25 * w, z = 0}
  self.points = {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20}
  
  -- find centroid and subtract offset to centre at origin
  local cx = (p1.x + p2.x + p3.x + p4.x + p5.x + p6.x + p7.x + p8.x + p9.x + p10.x + p11.x + p12.x + p13.x + p14.x + p15.x + p16.x + p17.x + p18.x + p19.x + p20.x) / 20
  local cy = (p1.y + p2.y + p3.y + p4.y + p5.y + p6.y + p7.y + p8.y + p9.y + p10.y + p11.y + p12.y + p13.y + p14.y + p15.y + p16.y + p17.y + p18.y + p19.y + p20.y) / 20
  local cz = (p1.z + p2.z + p3.z + p4.z + p5.z + p6.z + p7.z + p8.z + p9.z + p10.z + p11.z + p12.z + p13.z + p14.z + p15.z + p16.z + p17.z + p18.z + p19.z + p20.z) / 20
  vector3.add(p1, -cx, -cy, -cz)
  vector3.add(p2, -cx, -cy, -cz)
  vector3.add(p3, -cx, -cy, -cz)
  vector3.add(p4, -cx, -cy, -cz)
  vector3.add(p5, -cx, -cy, -cz)
  vector3.add(p6, -cx, -cy, -cz)
  vector3.add(p7, -cx, -cy, -cz)
  vector3.add(p8, -cx, -cy, -cz)
  vector3.add(p9, -cx, -cy, -cz)
  vector3.add(p10, -cx, -cy, -cz)
  vector3.add(p11, -cx, -cy, -cz)
  vector3.add(p12, -cx, -cy, -cz)
  vector3.add(p13, -cx, -cy, -cz)
  vector3.add(p14, -cx, -cy, -cz)
  vector3.add(p15, -cx, -cy, -cz)
  vector3.add(p16, -cx, -cy, -cz)
  vector3.add(p17, -cx, -cy, -cz)
  vector3.add(p18, -cx, -cy, -cz)
  vector3.add(p19, -cx, -cy, -cz)
  vector3.add(p20, -cx, -cy, -cz)
end

function bg:_init_draw_points()
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

function bg:set_pitch_angle(angle)
  self.pitch_angle = angle
  self.is_current = false
end

function bg:set_roll_angle(angle)
  self.roll_angle = angle
  self.is_current = false
end

function bg:set_rotation_angle(angle)
  self.rotation_angle = angle
  self.is_current = false
end

function bg:set_scale(scale)
  self.scale = scale
  self.is_current = false
end

function bg:set_altitude(alt)
  self.altitude = alt
  self.is_current = false
end

function bg:set_gradient(grad_table)
  self.gradient = grad_table
end

function bg:set_color4(color)
  self.color4 = color
end

function bg:set_color1(color)
  self.color1 = color
end

function bg:get_emote()
  return self.emoteType
end

function bg:set_emote(emoteType)
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
  elseif emoteType == "exclamation" then
	self.emote = self.emote_exclamation
  elseif emoteType == "faceHappy" then
	self.emote = self.emote_faceHappy
  elseif emoteType == "hungry" then
	self.emote = self.emote_hungry
  elseif emoteType == "home" then
	self.emote = self.emote_home
  end
end

------------------------------------------------------------------------------
function bg:_reset_draw_points()
  local dp = self.draw_points
  for i=1,#dp do
    vector3.clone(self.points[i], dp[i])
  end
end

function bg:_update_rotation()
  local wing = self.wing
  local wingWay = self.wingWay
  if self.rotation_angle == 0 then return end

  local angle = self.rotation_angle
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20]
  local cosval, sinval = math.cos(angle), math.sin(angle)
  p1.x, p1.y = p1.x*cosval - p1.y*sinval, p1.x*sinval + p1.y*cosval
  p2.x, p2.y = p2.x*cosval - p2.y*sinval, p2.x*sinval + p2.y*cosval
  p3.x, p3.y = p3.x*cosval - p3.y*sinval, p3.x*sinval + p3.y*cosval
   p4.x, p4.y = p4.x*cosval - p4.y*sinval, p4.x*sinval + p4.y*cosval
  p5.x, p5.y = p5.x*cosval - p5.y*sinval, p5.x*sinval + p5.y*cosval
  p6.x, p6.y = p6.x*cosval - p6.y*sinval, p6.x*sinval + p6.y*cosval
   p7.x, p7.y = p7.x*cosval - p7.y*sinval, p7.x*sinval + p7.y*cosval
  p8.x, p8.y = p8.x*cosval - p8.y*sinval, p8.x*sinval + p8.y*cosval
  p9.x, p9.y = p9.x*cosval - p9.y*sinval, p9.x*sinval + p9.y*cosval
   p10.x, p10.y = p10.x*cosval - p10.y*sinval, p10.x*sinval + p10.y*cosval
  p11.x, p11.y = p11.x*cosval - p11.y*sinval, p11.x*sinval + p11.y*cosval
  p12.x, p12.y = p12.x*cosval - p12.y*sinval, p12.x*sinval + p12.y*cosval
   p13.x, p13.y = p13.x*cosval - p13.y*sinval, p13.x*sinval + p13.y*cosval
  p14.x, p14.y = p14.x*cosval - p14.y*sinval, p14.x*sinval + p14.y*cosval
  p15.x, p15.y = p15.x*cosval - p15.y*sinval, p15.x*sinval + p15.y*cosval
  p16.x, p16.y = p16.x*cosval - p16.y*sinval, p16.x*sinval + p16.y*cosval
  p17.x, p17.y = p17.x*cosval - p17.y*sinval, p17.x*sinval + p17.y*cosval
  p18.x, p18.y = p18.x*cosval - p18.y*sinval, p18.x*sinval + p18.y*cosval
  p19.x, p19.y = p19.x*cosval - p19.y*sinval, p19.x*sinval + p19.y*cosval
  p20.x, p20.y = p20.x*cosval - p20.y*sinval, p20.x*sinval + p20.y*cosval
  
  
  if wing<100 and wingWay==true then
	p8.z = p8.z + 7
    p9.z = p9.z + 7
	p12.z =  p12.z + 7
	p13.z = p13.z + 7
	p10.z = p10.z + 13
	p11.z = p11.z + 13
	self.wing = self.wing + 20
  elseif wing>=-100 then
	self.wingWay = false
	p8.z = p8.z - 7
	p9.z = p9.z - 7
	p12.z =  p12.z - 7
	p13.z = p13.z - 7
	p10.z = p10.z - 13
	p11.z = p11.z - 13
	self.wing = self.wing - 20
  elseif self.wing<-100 then
	self.wingWay = true
  end
end

function bg:_update_pitch()
  if self.pitch_angle == 0 then return end

  local th = self.pitch_angle
  
  local p16, p20 = self.draw_points[16], self.draw_points[20]
  
  local u, v, w = p20.x - p16.x, p20.y - p16.y, 0       -- rotation axis
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

function bg:_update_roll()
  if self.roll_angle == 0 then return end
  
  local th = self.roll_angle
  
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20]
  
  local midx, midy, midz = p2.x + 0.5 * (p20.x - p16.x),
                           p2.y + 0.5 * (p20.y - p16.y),
                           p2.z + 0.5 * (p20.z - p16.z)
  
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

function bg:_update_scale()
  if self.scale == 1 then return end

  local s = self.scale
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20]
  
  p1.x, p1.y, p1.z = p1.x * s, p1.y * s, p1.z * s
  p2.x, p2.y, p2.z = p2.x * s, p2.y * s, p2.z * s
  p3.x, p3.y, p3.z = p3.x * s, p3.y * s, p3.z * s
  p4.x, p4.y, p4.z = p4.x * s, p4.y * s, p4.z * s
  p5.x, p5.y, p5.z = p5.x * s, p5.y * s, p5.z * s
  p6.x, p6.y, p6.z = p6.x * s, p6.y * s, p6.z * s
  p7.x, p7.y, p7.z = p7.x * s, p7.y * s, p7.z * s
  p8.x, p8.y, p8.z = p8.x * s, p8.y * s, p8.z * s
  p9.x, p9.y, p9.z = p9.x * s, p9.y * s, p9.z * s
  p10.x, p10.y, p10.z = p10.x * s, p10.y * s, p10.z * s
  p11.x, p11.y, p11.z = p11.x * s, p11.y * s, p11.z * s
  p12.x, p12.y, p12.z = p12.x * s, p12.y * s, p12.z * s
  p13.x, p13.y, p13.z = p13.x * s, p13.y * s, p13.z * s
  p14.x, p14.y, p14.z = p14.x * s, p14.y * s, p14.z * s
  p15.x, p15.y, p15.z = p15.x * s, p15.y * s, p15.z * s
  p16.x, p16.y, p16.z = p16.x * s, p16.y * s, p16.z * s
  p17.x, p17.y, p17.z = p17.x * s, p17.y * s, p17.z * s
  p18.x, p18.y, p18.z = p18.x * s, p18.y * s, p18.z * s
  p19.x, p19.y, p19.z = p19.x * s, p19.y * s, p19.z * s
  p20.x, p20.y, p20.z = p20.x * s, p20.y * s, p20.z * s
end

function bg:_update_shadow()
  local dp1, dp2, dp3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3], self.shadow_points[4], self.shadow_points[5], self.shadow_points[6], self.shadow_points[7], self.shadow_points[8], self.shadow_points[9], self.shadow_points[10], self.shadow_points[11], self.shadow_points[12],self.shadow_points[13], self.shadow_points[14], self.shadow_points[15],self.shadow_points[16], self.shadow_points[17], self.shadow_points[18],self.shadow_points[19],self.shadow_points[20]
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

function bg:_update_geometry()
  self:_reset_draw_points()
  self:_update_scale()
  self:_update_rotation()
  self:_update_pitch()
  self:_update_roll()
  self:_update_shadow()
end

function bg:_update_intensity()
	local wing = self.wing
  -- find normal
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20]
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

function bg:update(dt)
  if self.is_current then return end
  
  self:_update_geometry()
  self:_update_intensity()
end

------------------------------------------------------------------------------
function bg:draw_shadow(x, y)
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3] 
  lg.setColor(0, 0, 0, self.shadow_alpha)
  lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
end

function bg:draw(x, y)
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15, p16, p17, p18, p19, p20 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20]
  lg.setColor(0, 0, 0, 255)
  lg.line(p1.x + x, p1.y + y, p2.x + x, p2.y + y)
  lg.line(p2.x + x, p2.y + y, p3.x + x, p3.y + y)
  lg.line(p3.x + x, p3.y + y, p1.x + x, p1.y + y)
  lg.line(p3.x + x, p3.y + y, p5.x + x, p5.y + y)
  lg.line(p2.x + x, p2.y + y, p4.x + x, p4.y + y)
  lg.line(p4.x + x, p4.y + y, p6.x + x, p6.y + y)
  lg.line(p5.x + x, p5.y + y, p7.x + x, p7.y + y)
  lg.line(p6.x + x, p6.y + y, p8.x + x, p8.y + y)
  lg.line(p7.x + x, p7.y + y, p9.x + x, p9.y + y)
  lg.line(p9.x + x, p9.y + y, p11.x + x, p11.y + y)
  lg.line(p8.x + x, p8.y + y, p10.x + x, p10.y + y)
  lg.line(p11.x + x, p11.y + y, p13.x + x, p13.y + y)
  lg.line(p10.x + x, p10.y + y, p12.x + x, p12.y + y)
  lg.line(p12.x + x, p12.y + y, p14.x + x, p14.y + y)
  lg.line(p13.x + x, p13.y + y, p15.x + x, p15.y + y)
  lg.line(p14.x + x, p14.y + y, p16.x + x, p16.y + y)
  lg.line(p16.x + x, p16.y + y, p17.x + x, p17.y + y)
  lg.line(p17.x + x, p17.y + y, p18.x + x, p18.y + y)
  lg.line(p18.x + x, p18.y + y, p19.x + x, p19.y + y)
  lg.line(p19.x + x, p19.y + y, p20.x + x, p20.y + y)
  lg.line(p20.x + x, p20.y + y, p15.x + x, p15.y + y)

  local i = self.intensity
  local idx = math.floor(1 + i * (#self.gradient - 1)) + self.grad_offset
  if idx ~= idx then
    idx = 1
  end
  if idx < 1 then idx = 1 end
  if idx > #self.gradient then idx = #self.gradient end
  
  local c = self.gradient[idx]
  lg.setColor(c)
  lg.setColor(self.color1,self.color2,self.color3,self.color4)
  lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
  
  lg.polygon("fill", p2.x + x, p2.y + y, p3.x + x, p3.y + y, p5.x + x, p5.y + y, p7.x + x, p7.y + y, p9.x + x, p9.y + y, p11.x + x, p11.y + y, p13.x + x, p13.y + y, p15.x + x, p15.y + y, p20.x + x, p20.y + y, p19.x + x, p19.y + y, p18.x + x, p18.y + y, p17.x + x, p17.y + y, p16.x + x, p16.y + y, p14.x + x, p14.y + y, p12.x + x, p12.y + y, p10.x + x, p10.y + y, p8.x + x, p8.y + y, p4.x + x, p4.y + y, p2.x + x, p2.y + y)
  
  lg.setColor(255, 255, 255, 255)
  if self.emoteType~=nil then 
	local cx = (p1.x + p2.x + p3.x) / 3
    local cy = (p1.y + p2.y + p3.y) / 3
    local cz = (p1.z + p2.z + p3.z) / 3
	love.graphics.draw(self.emote, cx+x-16, cy+y-38)
  end

  if not self.debug then return end
  
end

return bg















