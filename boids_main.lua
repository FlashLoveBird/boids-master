math.randomseed(os.time())
for i=1,5 do math.random() end

local scrnum = 0

local TLfres = require "tlfres"

function love.keypressed(key, unicode)

  if key == "escape" then
    --love.event.push('quit')
	BOIDS:escape()
  end
  
  if (DEBUG or true) and key == '1' then
    FREEZE = not FREEZE
  end

  BOIDS:keypressed(key)
  
  if key == "p" then
    local screenshot = love.graphics.captureScreenshot(os.time() .. ".png")
  end
  
  if key == "backspace" then
    BOIDS:load_previous_state()
  end
end
function love.keyreleased(key)
  BOIDS:keyreleased(key)
end
function love.mousepressed(x, y, button)
  local mpos = MOUSE_INPUT:get_position()
  BOIDS:mousepressed(mpos.x, mpos.y, button)
  
  if button == "l" and STATES.continue_button.bbox:contains_coordinate(mpos.x, mpos.y) then
    love.keypressed("return")
  end
  
end

function love.wheelmoved(x, y)
    BOIDS:wheelmoved(x, y)
end

function love.mousereleased(x, y, button)
  local mpos = MOUSE_INPUT:get_position()
  BOIDS:mousereleased(mpos.x, mpos.y, button)
  love.audio.play(click)
end

function love.resize(w, h)
  print(("Fenêtre redimensionnéeeeee à la largeur : %d et la hauteur : %d."):format(w, h))
  SCR_WIDTH  = w
  SCR_HEIGHT = h
  BOIDS:resize(w, h)
end

function love.load(args)
  -- GLOBALS -------------------------------------------------------------------
  lg = love.graphics
  lw = love.window
  lf = love.filesystem
  lk = love.keyboard
  li = love.image
  
  ARGS = args
  DEBUG = true
  FREEZE = false
  SCR_WIDTH  = args[1]
  SCR_HEIGHT = args[2]
  FULLSCREEN = args[3]
  MOUSE_INPUT = nil
  TILE_WIDTH = 16
  TILE_HEIGHT = 16
  CELL_WIDTH = 64                       -- collider cell width
  CELL_HEIGHT = 64
  MAX_IMAGE_WIDTH = 2048                  -- in pixels
  MAX_IMAGE_HEIGHT = 2048
  ACTIVE_AREA_WIDTH = 12800--6400 -- 32*8*25 
  ACTIVE_AREA_HEIGHT= 12800--6400
  RED, GREEN, BLUE, ALPHA = 1, 2, 3, 4
  MUSIC = 1
  LANGUE = "FR"
  nbBush = 0
  nbNids = 0
  nbNidsPred = 0
  
  -- global assets
  require("boids_utils")
  require("boids_math")
  require("table_utils")
  local object_loader = require("object_loader")
  object_loader.load_objects()
  FONTS = require("font_loader")
  MASTER_TIMER = master_timer:new()
  MOUSE_INPUT = mouse_input:new()
  MOUSE_INPUT:init()

  -- construct state machine
  local states = require('state_loader')
  STATES = states
  BOIDS = state_manager:new()
  --[[BOIDS:add_state(states.main_screen_load_state, "main_screen_load_state")
  BOIDS:add_state(states.main_screen_state, "main_screen_state")
  BOIDS:add_state(states.overview_screen_state, "overview_screen_state")
  
  BOIDS:add_state(states.flockmates_screen_state, "flockmates_screen_state")
  BOIDS:add_state(states.flockmates_demo_load_state, "flockmates_demo_load_state")
  BOIDS:add_state(states.flockmates_demo_state, "flockmates_demo_state")
  
  BOIDS:add_state(states.query_screen_state, "query_screen_state")
  BOIDS:add_state(states.query_demo_load_state, "query_demo_load_state")
  BOIDS:add_state(states.query_demo_state, "query_demo_state")
  
  BOIDS:add_state(states.rules_screen_state, "rules_screen_state")
  BOIDS:add_state(states.rule_alignment_screen_state, "rule_alignment_screen_state")
  BOIDS:add_state(states.rule_cohesion_screen_state, "rule_cohesion_screen_state")
  BOIDS:add_state(states.rule_separation_screen_state, "rule_separation_screen_state")
  BOIDS:add_state(states.rules_demo_load_state, "rules_demo_load_state")
  BOIDS:add_state(states.rules_demo_state, "rules_demo_state")
  
  BOIDS:add_state(states.obstacle_screen_state, "obstacle_screen_state")
  BOIDS:add_state(states.obstacle_demo_load_state, "obstacle_demo_load_state")
  BOIDS:add_state(states.obstacle_demo_state, "obstacle_demo_state")
  --]]
  BOIDS:add_state(states.food_screen_state, "food_screen_state")
  BOIDS:add_state(states.food_menu_state, "food_menu_state")
  BOIDS:add_state(states.food_demo_param_state, "food_demo_param_state")
  BOIDS:add_state(states.food_demo_credits_state, "food_demo_credits_state")
  BOIDS:add_state(states.food_config_state, "food_config_state")
  BOIDS:add_state(states.food_demo_load_state, "food_demo_load_state")
  BOIDS:add_state(states.food_demo_state, "food_demo_state")
  
  --[[
  BOIDS:add_state(states.emitter_screen_state, "emitter_screen_state")
  BOIDS:add_state(states.emitter_demo_load_state, "emitter_demo_load_state")
  BOIDS:add_state(states.emitter_demo_state, "emitter_demo_state")
  
  BOIDS:add_state(states.graph_screen_state, "graph_screen_state")
  BOIDS:add_state(states.graph_demo_load_state, "graph_demo_load_state")
  BOIDS:add_state(states.graph_demo_state, "graph_demo_state")
  
  BOIDS:add_state(states.animation_screen_state, "animation_screen_state")
  BOIDS:add_state(states.animation_demo_load_state, "animation_demo_load_state")
  BOIDS:add_state(states.animation_demo_state, "animation_demo_state")
  
  BOIDS:add_state(states.exit_screen_state, "exit_screen_state")
  --]]
  BOIDS:load_state("food_screen_state")
  
  love.mouse.setVisible(false)
  
  click = love.audio.newSource("sound/click1.ogg", "static")
  
  --lw.setFullscreen(true, "desktop")
  
  --[[lg.setFont(FONTS.bebas_smallest)
  local text = "Press [ enter ] to continue"
  local tw, th = FONTS.bebas_smallest:getWidth(text), FONTS.bebas_smallest:getHeight(text)
  local pad = 5
  local x, y = SCR_WIDTH - tw - pad, SCR_HEIGHT - th - pad
  lg.setColor(255, 255, 255, 100)
  lg.print(text, x, y)
  STATES.continue_button = {font = FONTS.bebas_smallest,
                     text = text,
                     bbox = bbox:new(x, y, tw+2*pad, th+2*pad),
                     color = {255, 255, 255, 255}}--]]
					 
  --love.window.setFullscreen(true)
  --love.resize(lg.getDimensions())
  
end

function love.update(dt)
  if FREEZE then
    return
  end
  
  --if love.keyboard.isDown('z') then dt = dt / 16 end
  --if love.keyboard.isDown('x') then dt = dt * 3 end
  
  dt = math.min(dt, 1/20)

  MASTER_TIMER:update(dt)
  MOUSE_INPUT:update(dt)
  BOIDS:update(dt)
  
  local b = STATES.continue_button
  local mx, my = MOUSE_INPUT:get_position():get_vals()
  --[[if b.bbox:contains_coordinate(mx, my) then
    b.color[4] = 255
  else
    b.color[4] = 100
  end--]]
  
  if lk.isDown('`') then -- tilde
    DEBUG = true
  else
    DEBUG = false
  end
end

function love.draw()
  --TLfres.beginRendering(1920, 1080)
  --lg.setPointStyle("rough")

  BOIDS:draw()
  MOUSE_INPUT:draw()
  
  lg.setFont(FONTS.rubik)
  --if DEBUG then
    lg.setColor(255, 0, 0, 255)
    lg.print("FPS "..love.timer.getFPS(), 0, 0)
  --end
  
  --[[local b = STATES.continue_button
  lg.setFont(b.font)
  lg.setColor(b.color)
  lg.print(b.text, b.bbox.x, b.bbox.y)--]]
  --TLfres.endRendering()
  --print(TLfres.getScale(800, 600))
end












