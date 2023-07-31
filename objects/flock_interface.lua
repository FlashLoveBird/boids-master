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

fi.nb_boids_selected = 0

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
  sexMIcon = love.graphics.newImage("images/ui/sexM.png")
  sexFIcon = love.graphics.newImage("images/ui/sexF.png")
  homeIcon = love.graphics.newImage("images/ui/home.png")
  loveIcon = love.graphics.newImage("images/ui/love.png")
  barre = love.graphics.newImage("images/ui/barre.png")
  
  panelInset_brown = love.graphics.newImage("images/PNG/panelInset_beigeLight.png")
  searchIcon = love.graphics.newImage("images/Colored/genericItem_color_111.png")
  heroIcon = love.graphics.newImage("images/Colored/genericItem_color_111.png")
  
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
	fi.hero:breathe()
	--fi.hero:unbreathe()
elseif key =="lshift" and fi.hero.boidsIn==true then
	fi.hero:release(self.flock)
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
    
	self.left_click_mode = SELECT_MODE
    self.left_click_x, self.left_click_y = x, y
	
	-- dont add boid if boids are selected
    --[[local n = 0
    for _,v in pairs(self.selected_boids) do n = n + 1 end
    
    if n == 0 then
      self.left_click_mode = ADD_MODE
      self.left_click_x, self.left_click_y = x, y
    end--]]
  -- Select boids
  elseif button == 1 then
    self.left_click_mode = SELECT_MODE
    self.left_click_x, self.left_click_y = x, y
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
  
  if button == 1 and self.selectItem == 1 then
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
  end
  
end
function fi:mousereleased(x, y, button)
  local x, y = self.level:get_mouse():get_coordinates()
  local cx, cy = self.level:get_camera():get_viewport()
  local x, y = x + cx, y + cy
  self.nb_boids_selected = 0

  -- add boid on release
  if button == 1 and self.left_click_mode == ADD_MODE then
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
        if selected[boid] then
          selected[boid] = nil
        else
          selected[boid] = boid
		  boid:sing(1)
		  self.nb_boids_selected = self.nb_boids_selected + 1
        end
      end
    else
      local bbox = self.select_boid_bbox
      self.flock:get_boids_in_bbox(bbox, storage)
      for i=1,#storage do
        selected[storage[i]] = storage[i]
		storage[i]:sing(1)
		self.nb_boids_selected = self.nb_boids_selected + 1
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

function fi:_set_waypoint_for_selected_boids(x, y)
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
    b:set_waypoint(x, y, z)
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
  lg.circle("line", x1, y1, r)
  lg.circle("line", x2, y2, r)
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
  
  lg.setColor(0, 100, 255, 255)
  lg.setLineWidth(1)
  bbox:draw()
  lg.setColor(0, 0, 255, 20)
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
    lg.setColor(0, 100, 255, 255)
    lg.circle("line", x, y, r)
    lg.setColor(0, 100, 255, 100)
    lg.circle("line", x, y, r - 3)
  end
  
  
end

function fi:_draw_selected_boids()
  
  lg.setLineWidth(1)
  local cam = self.level:get_camera()
  local camWi, camHe = cam:get_size()
  for _,b in pairs(self.selected_boids) do
	if self.nb_boids_selected == 1 then
		local x, y = math.floor(b.position.x), math.floor(b.position.y)
		local r = self.select_boid_radius
		local tableX = cam.pos.x+camWi-320
		local tableY = cam.pos.y+180
		local hunger = math.floor(b.hunger)
		local tired = math.floor(b.tired)
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+100)
		love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+120)
		
		love.graphics.draw(barre, tableX, tableY-10)
		love.graphics.draw(barre, tableX, tableY+40)
		love.graphics.draw(barre, tableX, tableY+80)
		
		love.graphics.draw(energyIcon, tableX, tableY+50)
		love.graphics.draw(foodIcon, tableX, tableY)
		love.graphics.draw(ageIcon, tableX, tableY+90)
		--love.graphics.draw(sexIcon, tableX+120, tableY)
		
		if b.needHome == true then
			love.graphics.draw(homeIcon, tableX+150, tableY+100)
		end
		
		lg.setColor(0, 0, 0, 255)
		--lg.circle("line", x, y, r)
		lg.print(b.name, tableX+70, tableY-30)
		lg.print(hunger, tableX+50, tableY+10)
		lg.print(tired, tableX+50, tableY+60)
		lg.print(b.age, tableX+50, tableY+110)
		lg.setColor(255, 255, 255, 255)
		if b.sex == true then
			--lg.print("Mâle", tableX+170, tableY+10)
			love.graphics.draw(sexMIcon, tableX+170, tableY)
		else
			love.graphics.draw(sexFIcon, tableX+170, tableY)
		end
		lg.print("Objectif :", tableX+120, tableY+50)
		lg.print(b.objectiv, tableX+120, tableY+70)
		
		--love.graphics.draw(homeIcon, tableX+170, tableY+100)
		
		if b.hadKid == true then
			lg.print("A ete enceinte", tableX+50, tableY+140)
		end
		
		lg.setColor(255, 255, 255, 255)
		love.graphics.draw(bg, cam.pos.x+camWi-400, cam.pos.y+400)
		love.graphics.draw(tableImg, cam.pos.x+camWi-350, cam.pos.y+420)
		local tableY = cam.pos.y+460
		
		lg.setColor(0, 0, 0, 255)
		--lg.circle("line", x, y, r)
		if b.lover then
			love.graphics.draw(loveIcon, tableX, tableY+20)
			--lg.print("En couple avec :", tableX, tableY)
			lg.print(b.lover.name, tableX, tableY+20)
		else
			lg.print("Pas de relation", tableX, tableY)
		end
		lg.print("is_initialized ?", tableX, tableY+60)
		lg.print(tostring(b.is_initialized), tableX, tableY+80)
		
		lg.print("is_inHome ?", tableX, tableY+100)
		lg.print(tostring(b.inHome), tableX, tableY+120)
		
		
		--lg.print(tostring(b.needHome), cam.pos.x+1500, cam.pos.y+620)
		
		
		lg.print(b.foodGrab, x+100, y+50)
		lg.print(b.woodGrab, x+100, y+30)
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
  
  local cam = self.level:get_camera()
  local tableX = cam.pos.x+100
  local tableY = cam.pos.y+100
  for i=1,#self.buttons do
    local b = self.buttons[i]
    if b.toggle then
	  lg.setColor(50, 100, 255, 255)
      --lg.rectangle("fill", tableX, tableY, 100,100)
    else
	  lg.setColor(100, 20, 100, 255)
      --lg.rectangle("fill", tableX, tableY, 100,100)
    end
  end
  
end

return fi









