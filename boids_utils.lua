require("table_utils")
local utils = {}

utils.load_graphics_settings = function()
  local function initialize_graphics_settings()

    -- find largest window size through modes
    -- and cap dimensions to 1920x1080
    local modes = love.window.getFullscreenModes()
    table.sort(modes, function(a, b) 
                        return a.width*a.height > b.width*b.height
                      end)
    local fs_width, fs_height = modes[1].width, modes[1].height
    fs_width, fs_height = math.min(fs_width, 1920), math.min(fs_height, 1080)
    
    -- set default size to fullscreen size padded so that window is
    -- not too large
    local width_pad = 0--1000
    local height_pad = 0--1000
    local width = fs_width - width_pad
    local height = fs_height - height_pad
                      
    local default_settings = require("config/default_graphics_settings")
    default_settings.window_width = width
    default_settings.window_height = height
    table.write(default_settings, "graphics_settings.lua")
  end
  
  local function settings_modified(settings)
    if settings.fullscreen ~= love.window.getFullscreen() then
      return true
    end
    if settings.window_width ~= love.graphics.getWidth() then
      return true
    end
    if settings.window_height ~= love.graphics.getHeight() then
      return true
    end
    return false
  end
  
  local function update_graphics_settings(settings)
    local width, height, flags = love.window.getMode()
    width = settings.window_width
    height = settings.window_height
	print("width")
	print(width)
    flags.fullscreen = settings.fullscreen
    
    love.window.setMode(width, height, flags)
  end
  
  -- check if graphics settings exist
  if not love.filesystem.getInfo("graphics_settings.lua") then
    initialize_graphics_settings()
  end
  
  -- load settings
  local ok, chunk, settings
  ok, chunk = pcall( love.filesystem.load, "graphics_settings.lua")
  if not ok then
    print('The following error happend: ' .. tostring(chunk))
    return
  else
    ok, settings = pcall(chunk)
  
    if not ok then -- will be false if there is an error
      print('The following error happened: ' .. tostring(result))
      return
    end
  end
  
  if settings_modified(settings) then
    update_graphics_settings(settings)
  end
  
  return settings
end

return utils











