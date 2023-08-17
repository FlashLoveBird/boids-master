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
local hg = {}
hg.table = 'hg'
hg.debug = true
hg.width = nil
hg.height = nil
hg.points = nil
hg.draw_points = nil
hg.shadow_points = nil

hg.rotation_angle = 0
hg.pitch_angle = 0
hg.roll_angle = 0
hg.scale = 1
hg.intensity = 1
hg.altitude = 0
hg.min_altitude = 0
hg.max_altitude = 200
hg.min_alpha = 0
hg.max_alpha = 1

hg.color1 = 0
hg.color2 = 0
hg.color3 = 0
hg.color4 = 255

hg.emote = nil
hg.emote_question = nil
hg.emote_sleep = nil
hg.emoteType = nil

hg.gradient = require("gradients/named/greenyellow")
hg.grad_offset = nil

hg.is_current = false

hg.wing = 0
hg.wingWay = true
hg.inPause = false
hg.animations = {}

hg.panic = false
hg.run = false
hg.cutWood = false

local hg_mt = { __index = hg }
function hg:new(width, height)
  local hg = setmetatable({}, hg_mt)
  hg.width, hg.height = width, height
  hg:_init_geometry()
  hg:_init_draw_points()
  
  hg:init_graphics();
  return hg
end

function hg:init_graphics()
  self.grad_offset = math.random(0,60)
  self.emote_question = lg.newImage("images/emote/style_4/emote_question.png")
  self.emote_sleep = lg.newImage("images/emote/style_6/emote_sleeps.png")
  self.emote_food = lg.newImage("images/emote/style_4/emote_food.png")
  self.emote_love = lg.newImage("images/emote/style_4/emote_heart.png")
  self.emote_exclamation = lg.newImage("images/emote/style_4/emote_exclamation.png")
  self.emote_faceHappy = lg.newImage("images/emote/style_4/emote_faceHappy.png")
  self.emote_hungry = lg.newImage("images/emote/style_6/emote_hungry.png")
  self.emote_home = lg.newImage("images/emote/style_6/emote_home.png")  
  self.pause = lg.newImage("images/home/bird-sleep.png")
  
  self.aile = lg.newImage("images/home/aile-bird.png")
  
  self.face = lg.newImage("images/home/face-bird.png")
  
  
  self.animation1 = hero:newAnimation(love.graphics.newImage("images/human_images/walk-right.png"), 480, 270, 1/2)
  self.animation2 = hero:newAnimation(love.graphics.newImage("images/human_images/walk-left.png"), 480, 270, 1/2)
  self.animation3 = hero:newAnimation(love.graphics.newImage("images/human_images/walk-down.png"), 480, 270, 1/2)
  self.animation4 = hero:newAnimation(love.graphics.newImage("images/human_images/walk-up.png"), 480, 270, 1/2)
  self.animation5 = hero:newAnimation(love.graphics.newImage("images/human_images/start-run-right.png"), 480, 270, 1/2)
  self.animation6 = hero:newAnimation(love.graphics.newImage("images/human_images/start-run-left.png"), 480, 270, 1/2)
  self.animation7 = hero:newAnimation(love.graphics.newImage("images/human_images/start-run-down.png"), 480, 270, 1/2)
  self.animation8 = hero:newAnimation(love.graphics.newImage("images/human_images/start-run-up.png"), 480, 270, 1/2)
  self.animation9 = hero:newAnimation(love.graphics.newImage("images/human_images/run-right.png"), 480, 270, 1/2)
  self.animation10 = hero:newAnimation(love.graphics.newImage("images/human_images/run-left.png"), 480, 270, 1/2)
  self.animation11 = hero:newAnimation(love.graphics.newImage("images/human_images/run-down.png"), 480, 270, 1/2)
  self.animation12 = hero:newAnimation(love.graphics.newImage("images/human_images/run-up.png"), 480, 270, 1/2)
  self.animation13 = hero:newAnimation(love.graphics.newImage("images/human_images/cut-wood.png"), 480, 270, 0.15)
  table.insert(self.animations, self.animation1)
  table.insert(self.animations, self.animation2)
  table.insert(self.animations, self.animation3)
  table.insert(self.animations, self.animation4)
  table.insert(self.animations, self.animation5)
  table.insert(self.animations, self.animation6)
  table.insert(self.animations, self.animation7)
  table.insert(self.animations, self.animation8)
  table.insert(self.animations, self.animation9)
  table.insert(self.animations, self.animation10)
  table.insert(self.animations, self.animation11)
  table.insert(self.animations, self.animation12)
  table.insert(self.animations, self.animation13)
  
end

function hg:newAnimation(image, width, height, duration)
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

function hg:set_sex(sex)
if sex==false then
	local rand = math.random(1,5)
	if rand==1 then
		self.aile = lg.newImage("images/home/aile-bird.png")
	elseif rand==2 then
		self.aile = lg.newImage("images/home/aile-bird.png")
	else
		self.aile = lg.newImage("images/home/aile-bird-2.png")
	end
	local rand = math.random(1,5)
	if rand==1 then
		self.corp = lg.newImage("images/home/corp-bird.png")
	elseif rand==2 then
		self.corp = lg.newImage("images/home/corp-bird.png")
	else
		self.corp = lg.newImage("images/home/corp-bird-2.png")
	end
else
	local rand = math.random(1,5)
	if rand==1 then
		self.aile = lg.newImage("images/home/aile-bird-3.png")
	elseif rand==2 then
		self.aile = lg.newImage("images/home/aile-bird-3.png")
	else
		self.aile = lg.newImage("images/home/aile-bird-3.png")
	end
	local rand = math.random(1,5)
	if rand==1 then
		self.corp = lg.newImage("images/home/corp-bird-3.png")
	elseif rand==2 then
		self.corp = lg.newImage("images/home/corp-bird-3.png")
	else
		self.corp = lg.newImage("images/home/corp-bird-3.png")
	end
end
end

function hg:_init_geometry()

  -- triangle centred at origin, nose aligned with +x axis
  local w, h =self.width, self.height
  local p16 = {x = 0.129166* h, y =-0.113917 * w , z = -0.191371}
local p4 = {x = 0.129233* h, y =0.158481 * w , z = -0.188465}
local p5 = {x = 0.130361* h, y =0.325618 * w , z = 0.052110}
local p15 = {x = 0.140417* h, y =-0.285714 * w , z = 0.045587}
local p30 = {x = -0.153906* h, y =0.023887 * w , z = -0.333846}
local p29 = {x = 0.215325* h, y =0.024461 * w , z = -0.396068}
local p17 = {x = 0.329752* h, y =-0.070150 * w , z = -0.672072}
local p3 = {x = 0.329799* h, y =0.122458 * w , z = -0.670017}
local p25 = {x = -0.345988* h, y =-0.285734 * w , z = 0.058653}
local p6 = {x = -0.350981* h, y =1.409284 * w , z = 0.699292}
local p23 = {x = -0.351033* h, y =0.325595 * w , z = 0.065175}
local p21 = {x = -0.351322* h, y =0.023661 * w , z = -0.308156}
local p22 = {x = -0.351643* h, y =0.097800 * w , z = -0.189112}
local p14 = {x = -0.351664* h, y =-1.383142 * w , z = 0.669497}
local p24 = {x = -0.351680* h, y =-0.053000 * w , z = -0.190721}
local p26 = {x = -0.363660* h, y =0.016734 * w , z = 0.341416}
local p27 = {x = -0.567076* h, y =0.023988 * w , z = -0.333845}
local p20 = {x = 0.36* h, y =0.013373 * w , z = 0.630655}
local p7 = {x = -0.850107* h, y =0.325857 * w , z = 0.052113}
local p8 = {x = -0.850149* h, y =0.158720 * w , z = -0.188462}
local p12 = {x = -0.850216* h, y =-0.113676 * w , z = -0.191369}
local p13 = {x = -0.850257* h, y =-0.285471 * w , z = 0.045590}
local p28 = {x = -0.966186* h, y =0.024750 * w , z = -0.396065}
local p19 = {x = 0.58* h, y =0.013344 * w , z = 0.628390}
local p9 = {x = -1.080588* h, y =0.228689 * w , z = -0.668883}
local p11 = {x = -1.080686* h, y =-0.170428 * w , z = -0.673142}
local p18 = {x = 0.7* h, y =-0.100095 * w , z = 0.729303}
local p2 = {x = 0.7* h, y =0.122117 * w , z = 0.731674}
local p1 = {x = 0.9* h, y =0.014461 * w , z = 0.516338}
local p10 = {x = -1.818270* h, y =0.017264 * w , z = 0.325106}

local p31 = {x = -1.818270* h, y =0.017264 * w , z = 0.325106}


  self.points = {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31}
  
  -- find centroid and subtract offset to centre at origin
  local cx = (p1.x + p2.x + p3.x + p4.x + p5.x + p6.x + p7.x + p8.x + p9.x + p10.x + p11.x + p12.x + p13.x + p14.x + p15.x + p16.x + p17.x + p18.x + p19.x + p20.x + p21.x + p22.x + p23.x + p24.x + p25.x + p26.x + p27.x + p28.x + p29.x + p30.x + p31.x) / 31
  local cy = (p1.y + p2.y + p3.y + p4.y + p5.y + p6.y + p7.y + p8.y + p9.y + p10.y + p11.y + p12.y + p13.y + p14.y + p15.y + p16.y + p17.y + p18.y + p19.y + p20.y + p21.y + p22.y + p23.y + p24.y + p25.y + p26.y + p27.y + p28.y + p29.y + p30.y + p31.y) / 31
  local cz = (p1.z + p2.z + p3.z + p4.z + p5.z + p6.z + p7.z + p8.z + p9.z + p10.z + p11.z + p12.z + p13.z + p14.z + p15.z + p16.z + p17.z + p18.z + p19.z + p20.z + p21.z + p22.z + p23.z + p24.z + p25.z + p26.z + p27.z + p28.z + p29.z + p30.z + p31.z) / 31
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
   vector3.add(p21, -cx, -cy, -cz)
  vector3.add(p22, -cx, -cy, -cz)
  vector3.add(p23, -cx, -cy, -cz)
  vector3.add(p24, -cx, -cy, -cz)
  vector3.add(p25, -cx, -cy, -cz)
  vector3.add(p26, -cx, -cy, -cz)
  vector3.add(p27, -cx, -cy, -cz)
  vector3.add(p28, -cx, -cy, -cz)
  vector3.add(p29, -cx, -cy, -cz)
  vector3.add(p30, -cx, -cy, -cz)
  vector3.add(p31, -cx, -cy, -cz)
  
  p1.z = 0.516338
  p2.z = 0.731674
  p18.z = 0.731674
  p3.z = -0.670017
  p17.z = -0.670017
  p10.z = 0.325106
  
end

function hg:_init_draw_points()
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

function hg:set_panic(panic)
	self.panic = panic
end

function hg:set_run(run)
	self.run = run
end

function hg:set_cutWood(cut)
	self.cutWood = cut
end

function hg:get_cutWood()
	return self.cutWood
end

function hg:set_pitch_angle(angle)
  self.pitch_angle = angle
  self.is_current = false
end

function hg:set_roll_angle(angle)
  self.roll_angle = angle
  self.is_current = false
end

function hg:set_rotation_angle(angle)
  self.rotation_angle = angle
  self.is_current = false
end

function hg:set_scale(scale)
  self.scale = scale
  self.is_current = false
end

function hg:set_altitude(alt)
  self.altitude = alt
  self.is_current = false
end

function hg:set_gradient(grad_table)
  self.gradient = grad_table
end

function hg:set_color4(color)
  self.color4 = color
end

function hg:set_color1(color)
  self.color1 = color
end

function hg:get_emote()
  return self.emoteType
end

function hg:set_emote(emoteType)
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
function hg:_reset_draw_points()
  local dp = self.draw_points
  for i=1,#dp do
    vector3.clone(self.points[i], dp[i])
  end
end

function hg:_update_rotation()
  local wing = self.wing
  local wingWay = self.wingWay
  if self.rotation_angle == 0 then return end

  local angle = self.rotation_angle
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30 , p31  = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30],self.draw_points[31]
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
  p21.x, p21.y = p21.x*cosval - p21.y*sinval, p21.x*sinval + p21.y*cosval
  p22.x, p22.y = p22.x*cosval - p22.y*sinval, p22.x*sinval + p22.y*cosval
   p23.x, p23.y = p23.x*cosval - p23.y*sinval, p23.x*sinval + p23.y*cosval
  p24.x, p24.y = p24.x*cosval - p24.y*sinval, p24.x*sinval + p24.y*cosval
  p25.x, p25.y = p25.x*cosval - p25.y*sinval, p25.x*sinval + p25.y*cosval
  p26.x, p26.y = p26.x*cosval - p26.y*sinval, p26.x*sinval + p26.y*cosval
  p27.x, p27.y = p27.x*cosval - p27.y*sinval, p27.x*sinval + p27.y*cosval
  p28.x, p28.y = p28.x*cosval - p28.y*sinval, p28.x*sinval + p28.y*cosval
  p29.x, p29.y = p29.x*cosval - p29.y*sinval, p29.x*sinval + p29.y*cosval
  p30.x, p30.y = p30.x*cosval - p30.y*sinval, p30.x*sinval + p30.y*cosval
  p31.x, p31.y = p31.x*cosval - p31.y*sinval, p31.x*sinval + p31.y*cosval
  
  if wing<100 and wingWay==true then
	p4.z = p4.z + 5
    p8.z = p8.z + 5
	p5.z =  p5.z + 5
	p7.z = p7.z + 5
	p6.z = p6.z + 15
	p16.z = p16.z + 5
	p12.z = p12.z + 5
	p15.z =  p15.z + 5
	p13.z = p13.z + 5
	p14.z = p14.z + 15
	p31.z = p31.z + 5
	self.wing = self.wing + 20
  elseif wing>=-100 then
	self.wingWay = false
	p4.z = p4.z - 5
    p8.z = p8.z - 5
	p5.z =  p5.z - 5
	p7.z = p7.z - 5
	p6.z = p6.z - 15
	p16.z = p16.z - 5
	p12.z = p12.z - 5
	p15.z =  p15.z - 5
	p13.z = p13.z - 5
	p14.z = p14.z - 15
	p31.z = p31.z - 5
	self.wing = self.wing - 20
  elseif self.wing<-100 then
	self.wingWay = true
  end
end

function hg:_update_pitch()
  if self.pitch_angle == 0 then return end

  local th = self.pitch_angle
  
  local p6, p14 = self.draw_points[6], self.draw_points[14]
  
  local u, v, w = p14.x - p6.x, p14.y - p6.y, 0       -- rotation axis
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

function hg:_update_roll()
  if self.roll_angle == 0 then return end
  
  local th = self.roll_angle
  
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30],self.draw_points[31]
  
  local midx, midy, midz = p6.x + 0.5 * (p14.x - p6.x),
                           p6.y + 0.5 * (p14.y - p6.y),
                           p6.z + 0.5 * (p14.z - p6.z)
  
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

function hg:_update_scale()
  if self.scale == 1 then return end

  local s = self.scale
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30],self.draw_points[31]
  
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
   p21.x, p21.y, p21.z = p21.x * s, p21.y * s, p21.z * s
  p22.x, p22.y, p22.z = p22.x * s, p22.y * s, p22.z * s
  p23.x, p23.y, p23.z = p23.x * s, p23.y * s, p23.z * s
  p24.x, p24.y, p24.z = p24.x * s, p24.y * s, p24.z * s
  p25.x, p25.y, p25.z = p25.x * s, p25.y * s, p25.z * s
  p26.x, p26.y, p26.z = p26.x * s, p26.y * s, p26.z * s
  p27.x, p27.y, p27.z = p27.x * s, p27.y * s, p27.z * s
  p28.x, p28.y, p28.z = p28.x * s, p28.y * s, p28.z * s
  p29.x, p29.y, p29.z = p29.x * s, p29.y * s, p29.z * s
  p30.x, p30.y, p30.z = p30.x * s, p30.y * s, p30.z * s
  p31.x, p31.y, p31.z = p31.x * s, p31.y * s, p31.z * s
end

function hg:_update_shadow()
  local dp1, dp2, dp3 = self.draw_points[1], self.draw_points[2], self.draw_points[3]
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3], self.shadow_points[4], self.shadow_points[5], self.shadow_points[6], self.shadow_points[7], self.shadow_points[8], self.shadow_points[9], self.shadow_points[10], self.shadow_points[11], self.shadow_points[12],self.shadow_points[13], self.shadow_points[14], self.shadow_points[15],self.shadow_points[16], self.shadow_points[17], self.shadow_points[18],self.shadow_points[19],self.shadow_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30]
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

function hg:_update_geometry()
  self:_reset_draw_points()
  self:_update_scale()
  self:_update_rotation()
  self:_update_pitch()
  self:_update_roll()
  self:_update_shadow()
end

function hg:_update_intensity()
	local wing = self.wing
  -- find normal
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15,p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30],self.draw_points[31]
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

function hg:update(dt)
  if self.is_current then return end
  
  self:_update_geometry()
  self:_update_intensity()
  
  local panic = self.panic
  local run = self.run
  
  for i=1, #self.animations do
		self.animations[i].currentTime = self.animations[i].currentTime + dt
		if panic == true and self.animations[i].currentTime >= self.animations[i].duration then
			self.animations[i].currentTime = self.animations[i].currentTime - self.animations[i].duration
			self.run = true
		elseif self.animations[i].currentTime >= self.animations[i].duration then
			self.animations[i].currentTime = self.animations[i].currentTime - self.animations[i].duration
		end
	end
  
  
end

------------------------------------------------------------------------------
function hg:draw_shadow(x, y)
  local p1, p2, p3 = self.shadow_points[1], self.shadow_points[2], self.shadow_points[3] 
  lg.setColor(0, 0, 0, self.shadow_alpha)
  lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
end

function hg:draw(x, y)
  local pause = self.pause 
  local inPause = self.inPause
  local corp = self.corp
  local aile = self.aile
  local face = self.face
  
  local p1, p2, p3,p4, p5, p6,p7, p8, p9,p10, p11, p12,p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31 = self.draw_points[1], self.draw_points[2], self.draw_points[3], self.draw_points[4], self.draw_points[5], self.draw_points[6],self.draw_points[7], self.draw_points[8], self.draw_points[9],self.draw_points[10], self.draw_points[11], self.draw_points[12],self.draw_points[13], self.draw_points[14], self.draw_points[15],self.draw_points[16], self.draw_points[17], self.draw_points[18],self.draw_points[19],self.draw_points[20],self.draw_points[21],self.draw_points[22],self.draw_points[23],self.draw_points[24],self.draw_points[25],self.draw_points[26],self.draw_points[27],self.draw_points[28],self.draw_points[29],self.draw_points[30],self.draw_points[31]
  if inPause then
	lg.setColor(255, 255, 255, 1)
	lg.draw(self.pause, p1.x + x, p1.y + y)
  return end
  
  lg.setColor(0, 0, 0, 1)
--[[lg.line(p1.x + x, p1 .y + y, p2.x + x, p2.y + y)
lg.line(p2.x + x, p2 .y + y, p3.x + x, p3.y + y)
lg.line(p3.x + x, p3 .y + y, p4.x + x, p4.y + y)
lg.line(p4.x + x, p4 .y + y, p5.x + x, p5.y + y)
lg.line(p5.x + x, p5 .y + y, p6.x + x, p6.y + y)
lg.line(p6.x + x, p6 .y + y, p7.x + x, p7.y + y)
lg.line(p7.x + x, p7 .y + y, p8.x + x, p8.y + y)
lg.line(p8.x + x, p8 .y + y, p9.x + x, p9.y + y)
lg.line(p9.x + x, p9 .y + y, p10.x + x, p10.y + y)
lg.line(p10.x + x, p10 .y + y, p11.x + x, p11.y + y)
lg.line(p11.x + x, p11 .y + y, p12.x + x, p12.y + y)
lg.line(p12.x + x, p12 .y + y, p13.x + x, p13.y + y)
lg.line(p13.x + x, p13 .y + y, p14.x + x, p14.y + y)
lg.line(p14.x + x, p14 .y + y, p15.x + x, p15.y + y)
lg.line(p15.x + x, p15 .y + y, p16.x + x, p16.y + y)
lg.line(p16.x + x, p16 .y + y, p17.x + x, p17.y + y)
lg.line(p17.x + x, p17 .y + y, p18.x + x, p18.y + y)
lg.line(p18.x + x, p18 .y + y, p19.x + x, p19.y + y)
lg.line(p18.x + x, p18 .y + y, p1.x + x, p1.y + y)
--lg.line(p19.x + x, p19 .y + y, p20.x + x, p20.y + y)
--lg.line(p20.x + x, p20 .y + y, p21.x + x, p21.y + y)
--lg.line(p21.x + x, p21 .y + y, p22.x + x, p22.y + y)--]]
  
  lg.setColor(255, 255, 255, 1)
  
  local dx1 = p5.x - p13.x
  local dy1 = p5.y - p13.y
  local dx2 = p1.x - p10.x
  local dy2 = p1.y - p10.y
  
  local dx1a = p1.x - p10.x
  local dy1a = p1.y - p10.y
  local dx2a = p6.x - p14.x
  local dy2a = p6.y - p14.y
  
  local vertex1 = {p8.x+x,p8.y+y}
  local vertex2 = {p10.x+x,p10.y+y}
  local vertex3 = {p12.x+x,p12.y+y}
  local vertex4 = {p12.x+x,p12.y+y}
  
  local scaleX = math.sqrt ( dx2 * dx2 + dy2 * dy2 ) / 76
  local scaleY = math.sqrt ( dx1 * dx1 + dy1 * dy1 ) / 31
  local scaleXA = math.sqrt ( dx2a * dx2a + dy2a * dy2a )
  local scaleYA = math.sqrt ( dx1a * dx1a + dy1a * dy1a)
  local a = math.atan2(p10.y, p10.x) - math.atan2(p8.y, p8.x)
  --local rotation =  (a + math.pi)%(math.pi*2) - math.pi
  local rotation =  math.atan2(p1.y, p1.x) --- math.atan2(p8.y, p8.x)
  
  
  
  local i = 1
  local panic = self.panic
  local run = self.run
  local cutWood = self.cutWood
  if dx1a > 0 and dy1a < 30 and dy1a > -30 then
	--print('droite')
	if panic == true and run == true then
		i = 9
	elseif panic == true and run == false then
		i = 5
	else
		i = 1
	end
  elseif dx1a < 0 and dy1a < 30 and dy1a > -30 then
	--print('gauche')
	if panic == true and run == true then
		i = 10
	elseif panic == true and run == false then
		i = 6
	else
		i = 2
	end
  elseif dy1a > 30 then
	--print('bas')
	if panic == true and run == true then
		i = 11
	elseif panic == true and run == false then
		i = 7
	else
		i = 3
	end
  else
	--print('haut')
	if panic == true and run == true then
		i = 12
	elseif panic == true and run == false then
		i = 8
	else
		i = 4
	end
  end
  
  if cutWood==true then
	i = 13
  end
  
  love.graphics.push()
  love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
  local spriteNum = math.floor( self.animations[i].currentTime /  self.animations[i].duration * #self.animations[i].quads) + 1
  love.graphics.draw(self.animations[i].spriteSheet,  self.animations[i].quads[spriteNum], (p1.x+x-135)*2, (p1.y+y-70)*2)
  love.graphics.pop()

  local i = self.intensity
  local idx = math.floor(1 + i * (#self.gradient - 1)) + self.grad_offset
  if idx ~= idx then
    idx = 1
  end
  if idx < 1 then idx = 1 end
  if idx > #self.gradient then idx = #self.gradient end
  
  local c = self.gradient[idx]
  lg.setColor(c)
  --lg.setColor(self.color1,self.color2,self.color3,self.color4)
  --lg.polygon("fill", p1.x + x, p1.y + y, p2.x + x, p2.y + y, p3.x + x, p3.y + y)
  lg.setColor(0, 0, 0, 1)
  
  --lg.polygon("fill", p4.x + x, p4.y + y, p5.x + x, p5.y + y, p6.x + x, p6.y + y, p7.x + x, p7.y + y, p8.x + x, p8.y + y, p9.x + x, p9.y + y, p10.x + x, p10.y + y, p11.x + x, p11.y + y, p12.x + x, p12.y + y, p13.x + x, p13.y + y, p14.x + x, p14.y + y, p15.x + x, p15.y + y, p16.x + x, p16.y + y, p17.x + x, p17.y + y, p18.x + x, p18.y + y)
  --lg.setColor(255, 255, 255, 1)
  if self.emoteType~=nil then 
	local cx = (p1.x + p2.x + p3.x) / 3
    local cy = (p1.y + p2.y + p3.y) / 3
    local cz = (p1.z + p2.z + p3.z) / 3
	lg.draw(self.emote, cx+x-16, cy+y-38)
  end
  
  --lg.draw(aile, p10.x + x, p10.y + y, rotation, scaleX, scaleY, 50, 100)
  --lg.draw(face, p10.x + x, p10.y + y, rotation, scaleX, scaleY, 0, 20)
  --lg.draw(corp, p10.x + x, p10.y + y, rotation, scaleX, scaleY, 0, 20)
  --lg.draw(aile, p31.x + x, p31.y + y, rotation, scaleX, scaleY, 0, 20)
  
  --lg.print("p1", p1.x + x, p1.y + y)
  --lg.print("p10", p10.x + x, p10.y + y)
  --lg.print("p6", p6.x + x, p6.y + y)
  --lg.print("p14", p14.x + x, p14.y + y)
  
  if not self.debug then return end
  
end

return hg















