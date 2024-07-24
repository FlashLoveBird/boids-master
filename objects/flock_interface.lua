local SELECT_MODE = 0
local ADD_MODE = 1

--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- flock_interface object   - UI for managing flock/boids
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local fi = {}
fi.table = 'fi'
fi.debug = true
fi.level = nil
fi.flock = nil
fi.hero = nil

fi.depth_range = 30

fi.left_click_mode = nil
fi.left_click_x = nil
fi.left_click_y = nil

fi.select_boid_radius = 28
fi.select_boid_bbox = nil
fi.selected_boids = nil
fi.temp_collision_table = nil
fi.is_camera_tracking = false
fi.buttonsSelected = {}
fi.nb_boids_selected = 0
fi.selectBoidsByPanel = false
fi.boidSelectByPanel = nil

local fi_mt = { __index = fi }
function fi:new(level, parent_flock)
  local fi = setmetatable({}, fi_mt)
  fi.level = level
  fi.hero = level:get_player()
  fi.flock = parent_flock
  fi.select_boid_bbox = bbox:new(0, 0, 0, 0)
  fi.selected_boids = {}
  fi.temp_collision_table = {}
  
  bg = love.graphics.newImage("images/Jungle/settings/bg.png")
  tableImg = love.graphics.newImage("images/Jungle/settings/table.png")
  foodIcon = love.graphics.newImage("images/ui/food.png")
  energyIcon = love.graphics.newImage("images/ui/energy.png")
  ageIcon = love.graphics.newImage("images/ui/age.png")
  socialIcon = love.graphics.newImage("images/ui/age.png")
  sexMIcon = love.graphics.newImage("images/ui/sexM.png")
  sexFIcon = love.graphics.newImage("images/ui/sexF.png")
  homeIcon = love.graphics.newImage("images/ui/home.png")
  nohomeIcon = love.graphics.newImage("images/ui/no-home.png")
  loveIcon = love.graphics.newImage("images/ui/love.png")
  barre = love.graphics.newImage("images/ui/barre.png")
  rabbitIcon = love.graphics.newImage("images/ui/rabbitIcon.png")
  turtleIcon = love.graphics.newImage("images/ui/turtleIcon.png")
  sablePleinIcon = love.graphics.newImage("images/ui/sablier-plein.png")
  sableVideIcon = love.graphics.newImage("images/ui/sablier-vide.png") 
  barre2 = love.graphics.newImage("images/ui/barre2.png")
  rondBlanc = love.graphics.newImage("images/ui/rond-blanc.png")
  objectiv = love.graphics.newImage("images/ui/objectiv.png")
  sleepIcon = love.graphics.newImage("images/ui/sleepIcon.png")
  searchIcon = love.graphics.newImage("images/ui/search.png")
  flyIcon = love.graphics.newImage("images/ui/flyIcon.png")

  birdSleepIcon = love.graphics.newImage("images/ui/select_bird.png")  
  
  panelInset_brown = love.graphics.newImage("images/PNG/panelInset_beigeLight.png")
  searchBigIcon = love.graphics.newImage("images/Colored/genericItem_color_111.png")
  heroIcon = love.graphics.newImage("images/Colored/genericItem_color_111.png")
  selectBoid = love.graphics.newImage("images/ui/selectBoid.png")
  
  fi.buttons = {}
  
  local cam = level:get_camera()
  local tableX = 100
  local tableY = 100
  fi.buttons[1] = {text="setHome", x = tableX, y = tableY, toggle = false, 
                      bbox = bbox:new(tableX, tableY, 100, 100)}
  
  return fi
end

function fi:keypressed(key)
	print(key)
	if fi.hero == nil then 
		fi.hero = self.level:get_player()
	end
	if key =="space" and fi.hero.boidsIn==false then
		fi.hero:breathe()
	elseif key =="space" and fi.hero.boidsIn==true then
		--fi.hero:breathe()
		fi.hero:release(self.flock)
		--fi.hero:unbreathe()
	end
end
function fi:keyreleased(key)
if fi.hero == nil then 
	fi.hero = self.level:get_player()
elseif fi.hero ~= nil and key =="space" and fi.hero.boidsIn==false then
	fi.hero:expire(self.flock)
elseif fi.hero ~= nil and key =="space" and fi.hero.boidsIn==true then
	fi.hero:release(self.flock)
elseif fi.hero ~= nil and key =="f" then
	fi.hero:wakeUp(self.flock)
elseif fi.hero ~= nil and key =="r" then
	fi.hero:fear(self.flock)
end
end
function fi:mousepressed(x, y, button)
  local x, y = self.level:get_mouse():get_coordinates()
  local cx, cy = self.level:get_camera():get_viewport()
  local x, y = x + cx, y + cy
  local buttons = self.buttons
  local mpos = self.level:get_mouse():get_position()
  for i=1,#buttons do
    local b = buttons[i]
    if b.bbox:contains_coordinate(mpos.x, mpos.y) then
      self:toggle_button(b)
	  if b.toggle == true then
		b.toggle = false
	  end
      return
    end
  end  
  --print(x, y)

  -- Add boids
  if button == 1 then	
	if self.buttonsSelected then
		if #self.buttonsSelected > 0 then
		  for i=1,#self.buttonsSelected do
			local buttonSelected = self.buttonsSelected[i]
			if #self.buttonsSelected > 0 then
				if buttonSelected.bbox:contains_coordinate(x,  y) then
				local count = 1
				  for _,b in pairs(self.selected_boids) do
					if b.name == buttonSelected.text then
						self.boidSelectByPanel = b
						self.buttonsSelected = {}
						self.selectBoidsByPanel = true
					end
				  count = count + 1
				  end
				else
					self.selectBoidsByPanel = false
				end
			end
		  end
		else
			self.left_click_mode = SELECT_MODE
			self.left_click_x, self.left_click_y = x, y
			self.selectBoidsByPanel = false
		end		
	end
	--self.left_click_mode = SELECT_MODE
    --self.left_click_x, self.left_click_y = x, y
	
	-- dont add boid if boids are selected
    --[[local n = 0
    for _,v in pairs(self.selected_boids) do n = n + 1 end
    
    if n == 0 then
      self.left_click_mode = ADD_MODE
      self.left_click_x, self.left_click_y = x, y
    end--]]
  -- Select boids
  end
  
  -- Clear selected boids
  if button == 1 and not lk.isDown("lctrl") then
    table.clear_hash(self.selected_boids)
  end
  --end
  
  -- set waypoint for selected boids
  if button == 2 then
    self:_set_waypoint_for_selected_boids(x, y)
  end
  
  if self.buttonsSelected then
	if #self.buttonsSelected > 0 then
		self.selectBoidsByPanel = false
		self.buttonsSelected = {}
	end
  end
  
  --[[if button == 1 and self.selectItem == 1 then
	local treeMap = self.level:getTreeMap()
	local x = math.floor(x/32)
	local y = math.floor(y/32)
	  for mx = x-5, x+5 do
		for my = y-5, y+5 do
			if treeMap[mx][my]~=nil then
				for _,b in pairs(self.selected_boids) do
					local tree = treeMap[mx][my]:getTree()
					b:set_newHome(tree, mx, my)
				end
			end
		end
	  end
  end--]]
  
end
function fi:mousereleased(x, y, button)
  local x, y = self.level:get_mouse():get_coordinates()
  local cx, cy = self.level:get_camera():get_viewport()
  local x, y = x + cx, y + cy
  
  
  if self.selectBoidsByPanel==false then
	self.nb_boids_selected = 0
  end
	
  -- add boid on release
  if button == 1 and self.left_click_mode == ADD_MODE and self.selectBoidsByPanel==false then
    if not self.left_click_x or not self.left_click_y then return end
    
    local dx, dy, dz
    if x == self.left_click_x and y == self.left_click_y then
      dx, dy, dz = random_direction3()
    else
      dx, dy, dz = x - self.left_click_x, y - self.left_click_y, 0
      local invlen = 1 / math.sqrt(dx*dx + dy*dy + dz*dz)
      dx, dy, dz = dx * invlen, dy * invlen, dz * invlen
    end
    
    self:add_boid(self.left_click_x, self.left_click_y, nil, dx, dy, dz)
    self.left_click_mode = false
    self.left_click_x, self.left_click_y = nil, nil
    
  -- select boid(s) on release
  elseif button == 1 and self.left_click_mode == SELECT_MODE then
    if not self.left_click_x or not self.left_click_y then return end
    
    self:_update_select_bboid_preview_bbox()
    local bbox = self.select_boid_bbox
    local dx, dy = bbox.width, bbox.height
    local bbox_size = math.sqrt(dx * dx, dy * dy)
    local storage = self.temp_collision_table
    local selected = self.selected_boids
    table.clear(storage)
    if (x == self.left_click_x and y == self.left_click_y) or bbox_size < self.select_boid_radius then
      local r = self.select_boid_radius
      --self.flock:get_boids_in_radius(x, y, r, storage)
      local boid = storage[1]
      if boid then
		 if boid.boidType~=10 and boid.boidType~=7 then
			if selected[boid] then
			  selected[boid] = nil
			else
			  selected[boid] = boid
			  boid:sing(1)
			  self.nb_boids_selected = self.nb_boids_selected + 1
			end
		 end
      end
    else
      local bbox = self.select_boid_bbox
      self.flock:get_boids_in_bbox(bbox, storage)
      for i=1,#storage do
		if storage[i].boidType~=10 and storage[i].boidType~=7 then
			selected[storage[i]] = storage[i]
			storage[i]:sing(1)
			self.nb_boids_selected = self.nb_boids_selected + 1
		end
	  end
    end    
    --self.left_click_mode = false
    self.left_click_x, self.left_click_y = nil, nil
  end
  
end

function fi:add_boid(x, y, z, dx, dy, dz)
  local depth = self.flock:get_bbox().depth
  local z = z or 0.5 * depth + (-1 + 2*math.random()) * self.depth_range
  z = math.min(depth, z)
  z = math.max(0, z)
  
  if self.flock:contains_point(x, y, z) then
    local boid = self.flock:add_boid(x, y, z)
    boid:set_direction(dx, dy, dz)
  end
end

function fi:get_time()
  return math.floor(self.level.master_timer:get_time())
end

function fi:set_camera_tracking_on()
  self.is_camera_tracking = true
end

function fi:set_camera_tracking_off()
  self.is_camera_tracking = false
end

function fi:createBattle(boids, human)
	human:doWaitForBattle(true)
	human:deactivate()
	for _,b in pairs(boids) do
		b:prepareBattle(human)
	end
end

function fi:_set_waypoint_for_selected_boids(x, y)
  
  local boids = self.flock:get_active_boids()
  for i=1, #boids do
	if boids[i].boidType==5 and #self.selected_boids>5 then
		
	end
  end
  
  if self.selectBoidsByPanel == false then
	  -- calculate z as average z of selected boids
	  local z = 0
	  local count = 0
	  for _,b in pairs(self.selected_boids) do
		z = z + b.position.z
		count = count + 1
	  end
	  if count == 0 then return end
	  z = z / count
	  for _,b in pairs(self.selected_boids) do
		if b.boidType==2 then
			b:set_waypoint(x,y, z , 25, 50)
		end
		if count > 0 then
			--local boids = self.selected_boids
			for _,boids in pairs(self.selected_boids) do
				if boids.boidType==5 and boids.battle==false and #self.selected_boids>5 then
					local mx, my , mz = boids:get_position()
					if mx>x-100 and mx<x+100 and my>y-100 and my<y+100 then
						self:createBattle(self.selected_boids, boids)
					break
					end
				end
			end
		end
	  end
  else
	local b = self.boidSelectByPanel
	-- calculate z as average z of selected boids
	  local z = 0
	  local count = 0
	  z = z + b.position.z
	  count = count + 1
	  if count == 0 then return end
	  z = z / count
      if b.boidType==2 then
	 	 b:set_waypoint(x, y, z , 25, 50)
		end
  end
end

function fi:toggle_button(b)
  --local boids = fi.flock.active_boids
  local vx,vy = self.level:get_camera():get_size()
  --for i=1,#boids do
	myText = b.text
    --local boid = boids[i]
    if     b.toggle == false then
			
      if b.text == "setHome" then
        self.selectItem = 1
      end
    elseif b.toggle == true then
      if     b.text == "setHome" then
        self.selectItem = 1
      end
    end
 -- end
  b.toggle = not b.toggle
  print(self.selectItem)
end

function fi:newAnimation(image, width, height, duration)
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

------------------------------------------------------------------------------
function fi:_update_selected_boids(dt)
  if not self.left_click_mode == select then return end
  
  if self.is_camera_tracking then
    local track_x, track_y = 0, 0
    local count = 0
    for _,b in pairs(self.selected_boids) do
      track_x, track_y = track_x + b.position.x, track_y + b.position.y
      count = count + 1
    end
    if count == 0 then return end
    track_x = track_x / count
    track_y = track_y / count
  
    local target = vector2:new(track_x, track_y)
    local cam = self.level:get_camera()
    cam:set_target(target, true)
  end
  
  
end

function fi:update(dt)
  if love.mouse.isDown(2) and love.keyboard.isDown(2) then
    local x, y = self.level:get_mouse():get_coordinates()
    local cx, cy = self.level:get_camera():get_viewport()
    local x, y = x + cx, y + cy
    local dx, dy, dz = random_direction3()
    self:add_boid(x, y, nil, dx, dy, dz)
  end
  
  self:_update_selected_boids(dt) 
  
end

------------------------------------------------------------------------------
function fi:_draw_add_boid_preview()
  if self.left_click_mode ~= ADD_MODE then return end
  if not self.left_click_x or not self.left_click_y then return end
  
  local x, y = self.level:get_mouse():get_coordinates()
  local cx, cy = self.level:get_camera():get_viewport()
  local x2, y2 = x + cx, y + cy
  local x1, y1 = self.left_click_x, self.left_click_y 
  local dx, dy = x2 - x1, y2 - y1
  local len = math.sqrt(dx*dx + dy*dy)
  if len > 0 then
    dx, dy = dx / len, dy / len
    local len = 30
    local xm, ym = x1 + len * dx, y1 + len * dy
    lg.setColor(0, 0, 255, 150)
    lg.setLineWidth(2)
    lg.line(x1, y1, xm, ym)
    
  end
  
  lg.setColor(255, 0, 0, 255)
  local r = 3
  --lg.circle("line", x1, y1, r)
  --lg.circle("line", x2, y2, r)
  lg.setLineWidth(1)
  lg.setColor(255, 0, 0, 100)
  lg.line(x1, y1, x2, y2)
end

function fi:_update_select_bboid_preview_bbox()
  if self.left_click_mode ~= SELECT_MODE then return end
  if not self.left_click_x or not self.left_click_y then return end
  
  local x1, y1 = self.left_click_x, self.left_click_y
  local x, y = self.level:get_mouse():get_coordinates()
  local cx, cy = self.level:get_camera():get_viewport()
  local x2, y2 = x + cx, y + cy
  local width, height = math.abs(x2 - x1), math.abs(y2 - y1) 
  
  local bx = math.min(x1, x2)
  local by = math.min(y1, y2)
  local bbox = self.select_boid_bbox
  bbox.x, bbox.y, bbox.width, bbox.height = bx, by, width, height
end

function fi:_draw_select_boid_preview()
  if self.left_click_mode ~= SELECT_MODE then return end
  if not self.left_click_x or not self.left_click_y then return end
  
  self:_update_select_bboid_preview_bbox()
  local bbox = self.select_boid_bbox
  
  lg.setColor(255, 255, 255, 255)
  lg.setLineWidth(1)
  bbox:draw()
  --lg.setColor(0, 0, 255, 20)
  bbox:draw("line")
  
  local storage = self.temp_collision_table
  table.clear(storage)
  self.flock:get_boids_in_bbox(self.select_boid_bbox, storage)
  
  lg.setLineWidth(1)
  lg.setLineStyle("smooth")
  for i=1,#storage do
    local b = storage[i]
    local x, y = b.position.x, b.position.y
    local r = self.select_boid_radius
    --lg.setColor(0, 100, 255, 255)
    --lg.circle("line", x, y, r)
    --lg.setColor(0, 100, 255, 100)
    --lg.circle("line", x, y, r - 3)
	if b.boidType~=10 then
		love.graphics.draw(selectBoid, x-25, y-25)
	end
  end 
  
  
end

function fi:_draw_selected_boids()
  
  lg.setLineWidth(1)
  local cam = self.level:get_camera()
  local camWi, camHe = cam:get_size()
  lg.setFont(FONTS.rubikMin)
  local count = 1
  
  for _,b in pairs(self.selected_boids) do
	if self.nb_boids_selected == 1 then
		local x, y = math.floor(b.position.x), math.floor(b.position.y)
		local r = self.select_boid_radius
		local tableX = cam.pos.x+camWi-320
		local tableY = cam.pos.y+280
		local hunger = math.floor(b.hunger)
		local tired = math.floor(b.tired)
		local social = math.floor(b.social)
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+200)
		love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+220)
		lg.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", tableX+10,tableY+10, hunger,25)
		love.graphics.rectangle("fill", tableX+10,tableY+60, tired,25)
		love.graphics.rectangle("fill", tableX+10,tableY+100, social,25)
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(barre, tableX, tableY-10)
		love.graphics.draw(barre, tableX, tableY+40)
		love.graphics.draw(barre, tableX, tableY+80)
		
		love.graphics.draw(energyIcon, tableX-10, tableY+50)
		love.graphics.draw(foodIcon, tableX, tableY)
		love.graphics.draw(socialIcon, tableX-10, tableY+90)
		--love.graphics.draw(sexIcon, tableX+120, tableY)
		
		if b.needHome == true then
			love.graphics.draw(nohomeIcon, tableX+135, tableY+40)
		else
			love.graphics.draw(homeIcon, tableX+135, tableY+40)
		end
		
		lg.setColor(0, 0, 0, 255)
		--lg.circle("line", x, y, r)
		lg.print(b.name, tableX, tableY-30)
		--lg.print(hunger, tableX+50, tableY+10)
		--lg.print(tired, tableX+50, tableY+60)
		--lg.print(b.age, tableX+50, tableY+110)
		lg.setColor(255, 255, 255, 255)
		if b.sex == true then
			--lg.print("Mâle", tableX+170, tableY+10)
			love.graphics.draw(sexMIcon, tableX+220, tableY-30)
		else
			love.graphics.draw(sexFIcon, tableX+220, tableY-30)
		end
		--lg.setColor(0, 0, 0, 255)
		--lg.print("Objectif :", tableX+120, tableY+50)
		--lg.print(b.objectiv, tableX+120, tableY+70)
		
		love.graphics.draw(objectiv, tableX+130, tableY+10)
		if b.objectiv=="sleep" or b.objectiv=="goFloor" then
			love.graphics.draw(sleepIcon, tableX+215, tableY+15)
		elseif b.objectiv=="fly" then
			love.graphics.draw(flyIcon, tableX+215, tableY+15)
		else
			love.graphics.draw(searchIcon, tableX+200, tableY+15)
			love.graphics.push()   -- stores the coordinate system
		    love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
			if b.objectiv=="goOnSeekHome" or b.objectiv=="seekHome" then
				love.graphics.draw(homeIcon, tableX*2+470, tableY*2+15)
			elseif b.objectiv=="goOnSeekFood" or b.objectiv=="seekFood" then
				love.graphics.draw(foodIcon, tableX*2+470, tableY*2+25)
			elseif b.objectiv=="goOnSeekWood" or b.objectiv=="seekWood" then
				love.graphics.draw(woodIcon, tableX*2+470, tableY*2+15)
			end
		    love.graphics.pop()   -- return to stored coordinated
		end
		
		--love.graphics.draw(homeIcon, tableX+170, tableY+100)
		
		if b.hadKid == true then
			lg.print("A ete enceinte", tableX+50, tableY+140)
		end
		
		if b.lover then
				love.graphics.draw(loveIcon, tableX+140, tableY+100)
				--lg.print("En couple avec :", tableX, tableY)
				lg.setColor(0, 0, 0, 255)
				lg.setFont(FONTS.rubikMini)
				lg.print(b.lover.name, tableX+190, tableY+115)
		else
				--lg.print("Pas de relation", tableX, tableY)
		end
		lg.setFont(FONTS.rubikMin)
		if b.boidType == 52 then
			lg.setColor(255, 255, 255, 255)
			love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+500)
			love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+520)
			local tableY = cam.pos.y+560
			
			lg.setColor(0, 0, 0, 255)
			--lg.circle("line", x, y, r)
			--lg.print("is_initialized ?", tableX, tableY+60)
			--lg.print(tostring(b.is_initialized), tableX, tableY+80)
			
			--lg.print("is_inHome ?", tableX, tableY+100)
			--lg.print(tostring(b.inHome), tableX, tableY+120)
			lg.setColor(255, 255, 255, 255)
			--love.graphics.rectangle("fill", tableX+10,tableY+10, hunger,25)
			--love.graphics.draw(barre, tableX, tableY+10)
			love.graphics.draw(barre2, tableX+30, tableY+30)
			love.graphics.draw(rondBlanc, tableX+150, tableY+25)
			love.graphics.draw(turtleIcon, tableX-10, tableY)
			love.graphics.draw(rabbitIcon, tableX+180, tableY-10)
			
			love.graphics.draw(barre2, tableX+30, tableY+110)
			love.graphics.draw(rondBlanc, tableX+150, tableY+105)
			love.graphics.draw(sablePleinIcon, tableX, tableY+80)
			love.graphics.draw(sableVideIcon, tableX+200, tableY+80)
			
			--lg.print(tostring(b.needHome), cam.pos.x+1500, cam.pos.y+620)
			
			lg.setColor(0, 0, 0, 255)
			lg.print(b.foodGrab, x+100, y+50)
			lg.print(b.woodGrab, x+100, y+30)
		end	
	elseif count<12 then
		lg.setColor(255, 255, 255, 255)
		local x, y = math.floor(b.position.x), math.floor(b.position.y)
		love.graphics.draw(birdSleepIcon, cam.pos.x+270+count*140, cam.pos.y+camHe-170)
		lg.setColor(0, 0, 0, 255)
		lg.print(b.name, cam.pos.x+300+count*140, cam.pos.y+camHe-70)
		self.buttonsSelected[count] = {text=b.name, x = cam.pos.x+270+count*140, y = cam.pos.y+camHe-170, toggle = false, bbox = bbox:new(cam.pos.x+270+count*140, cam.pos.y+camHe-170, 150, 150)}
		count = count + 1
	end
	
    if self.debug then
      b:draw_debug()
    end
  end
end

function fi:draw()
  
  local local_time = self.level.master_timer:get_time()
  local fogAlpha = 0
  
  if local_time>70 and local_time<200 then
	fogAlpha = local_time*2/100 - 1.4
  elseif local_time>-10 and local_time<30 then
    fogAlpha = 0.6 - local_time*2/100
  end
  
  --self:_draw_add_boid_preview()
  self:_draw_select_boid_preview()
  self:_draw_selected_boids()
  
  
  local cx, cy = self.level:get_camera():get_viewport()
  local vx,vy = self.level:get_camera():get_size()
  lg.setColor(0, 0, 0, 0.5)
  --love.graphics.rectangle("fill", cx,cy, vx,vy)
  lg.setColor(255, 255, 255, 1)
  --love.graphics.draw(panelInset_brown, cx+vx-150, cy+vy-150)
  --love.graphics.draw(searchIcon, cx+vx-130, cy+vy-140)
  
  --love.graphics.draw(panelInset_brown, cx+vx-250, cy+vy-150)
  --love.graphics.draw(heroIcon, cx+vx-230, cy+vy-140)
  
  if self.buttonsSelected then
	  for i=1,#self.buttonsSelected do 
		local button = self.buttonsSelected[i]
		--button.bbox:draw()
	  end
  end
  
  if self.selectBoidsByPanel == true then
	local b = self.boidSelectByPanel
	local cam = self.level:get_camera()
	local camWi, camHe = cam:get_size()
	lg.setFont(FONTS.rubikMin)
	local x, y = math.floor(b.position.x), math.floor(b.position.y)
		local r = self.select_boid_radius
		local tableX = cam.pos.x+camWi-320
		local tableY = cam.pos.y+280
		local hunger = math.floor(b.hunger)
		local tired = math.floor(b.tired)
		local social = math.floor(b.social)
		b:draw_debug()
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+200)
		love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+220)
		lg.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", tableX+10,tableY+10, hunger,25)
		love.graphics.rectangle("fill", tableX+10,tableY+60, tired,25)
		love.graphics.rectangle("fill", tableX+10,tableY+100, social,25)
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(barre, tableX, tableY-10)
		love.graphics.draw(barre, tableX, tableY+40)
		love.graphics.draw(barre, tableX, tableY+80)
		
		love.graphics.draw(energyIcon, tableX-10, tableY+50)
		love.graphics.draw(foodIcon, tableX, tableY)
		love.graphics.draw(socialIcon, tableX-10, tableY+90)
		--love.graphics.draw(sexIcon, tableX+120, tableY)
		
		if b.needHome == true then
			love.graphics.draw(nohomeIcon, tableX+135, tableY+40)
		else
			love.graphics.draw(homeIcon, tableX+135, tableY+40)
		end
		
		lg.setColor(0, 0, 0, 255)
		--lg.circle("line", x, y, r)
		lg.print(b.name, tableX, tableY-30)
		--lg.print(hunger, tableX+50, tableY+10)
		--lg.print(tired, tableX+50, tableY+60)
		--lg.print(b.age, tableX+50, tableY+110)
		lg.setColor(255, 255, 255, 255)
		if b.sex == true then
			--lg.print("Mâle", tableX+170, tableY+10)
			love.graphics.draw(sexMIcon, tableX+220, tableY-30)
		else
			love.graphics.draw(sexFIcon, tableX+220, tableY-30)
		end
		--lg.setColor(0, 0, 0, 255)
		--lg.print("Objectif :", tableX+120, tableY+50)
		--lg.print(b.objectiv, tableX+120, tableY+70)
		
		love.graphics.draw(objectiv, tableX+130, tableY+10)
		if b.objectiv=="sleep" or b.objectiv=="goFloor" then
			love.graphics.draw(sleepIcon, tableX+215, tableY+15)
		elseif b.objectiv=="fly" then
			love.graphics.draw(flyIcon, tableX+215, tableY+15)
		else
			love.graphics.draw(searchIcon, tableX+200, tableY+15)
			love.graphics.push()   -- stores the coordinate system
		    love.graphics.scale(0.5, 0.5)   -- reduce everything by 50% in both X and Y coordinates
			if b.objectiv=="goOnSeekHome" or b.objectiv=="seekHome" then
				love.graphics.draw(homeIcon, tableX*2+470, tableY*2+15)
			elseif b.objectiv=="goOnSeekFood" or b.objectiv=="seekFood" then
				love.graphics.draw(foodIcon, tableX*2+470, tableY*2+25)
			elseif b.objectiv=="goOnSeekWood" or b.objectiv=="seekWood" then
				love.graphics.draw(woodIcon, tableX*2+470, tableY*2+15)
			end
		    love.graphics.pop()   -- return to stored coordinated
		end
		
		--love.graphics.draw(homeIcon, tableX+170, tableY+100)
		
		if b.hadKid == true then
			lg.print("A ete enceinte", tableX+50, tableY+140)
		end
		if b.lover then
			love.graphics.draw(loveIcon, tableX+140, tableY+100)
			--lg.print("En couple avec :", tableX, tableY)
			lg.setColor(0, 0, 0, 255)
			lg.setFont(FONTS.rubikMini)
			lg.print(b.lover.name, tableX+190, tableY+115)
		else
			--lg.print("Pas de relation", tableX, tableY)
		end
		lg.setFont(FONTS.rubikMin)
		if b.boidType == 52 then
			lg.setColor(255, 255, 255, 255)
			love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+500)
			love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+520)
			local tableY = cam.pos.y+560
			
			lg.setColor(0, 0, 0, 255)
			--lg.circle("line", x, y, r)
			--lg.print("is_initialized ?", tableX, tableY+60)
			--lg.print(tostring(b.is_initialized), tableX, tableY+80)
			
			--lg.print("is_inHome ?", tableX, tableY+100)
			--lg.print(tostring(b.inHome), tableX, tableY+120)
			lg.setColor(255, 255, 255, 255)
			--love.graphics.rectangle("fill", tableX+10,tableY+10, hunger,25)
			--love.graphics.draw(barre, tableX, tableY+10)
			love.graphics.draw(barre2, tableX+30, tableY+30)
			love.graphics.draw(rondBlanc, tableX+150, tableY+25)
			love.graphics.draw(turtleIcon, tableX-10, tableY)
			love.graphics.draw(rabbitIcon, tableX+180, tableY-10)
			
			love.graphics.draw(barre2, tableX+30, tableY+110)
			love.graphics.draw(rondBlanc, tableX+150, tableY+105)
			love.graphics.draw(sablePleinIcon, tableX, tableY+80)
			love.graphics.draw(sableVideIcon, tableX+200, tableY+80)
			
			--lg.print(tostring(b.needHome), cam.pos.x+1500, cam.pos.y+620)
			
			
			lg.setColor(0, 0, 0, 255)
			lg.print(b.foodGrab, x+100, y+50)
			lg.print(b.woodGrab, x+100, y+30)
		end
  end
  
end

return fi









