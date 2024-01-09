
--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- tile_chunk object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local tile_chunk = {}
tile_chunk.table = TILE_CHUNK
tile_chunk.debug = true
tile_chunk.parent = nil
tile_chunk.id = nil
tile_chunk.x = nil
tile_chunk.y = nil
tile_chunk.width = nil     -- in # of tiles
tile_chunk.height = nil
tile_chunk.spritesheet = nil     -- contains spritesheet
tile_chunk.quads = nil           -- quads that match spritesheet
tile_chunk.max_sprites = 1000
tile_chunk.num_sprites = 0
tile_chunk.num_refreshes = 0
tile_chunk.sprite_batch = nil
tile_chunk.is_current = false   -- is false if the chunk requires a refresh or
                                -- an update
                                
tile_chunk.tiles = nil
tile_chunk.diagonal_tiles = nil
tile_chunk.type_list = nil			-- list of tile types that make up chunk
                                -- tile types lists indexed by table type value
                                -- tiles indexed by chunk_id
                                -- ex: type_list[T_WALL][tile.chunk_id]
                                -- type_list.count[T_TYPE] contains # of tiles
                                -- of type T_TYPE  
                                
tile_chunk.quad_updates = nil    -- list of tiles requiring update
tile_chunk.update_list = nil
tile_chunk.update_count = 0

tile_chunk.max_chunk_id = 0
tile_chunk.diagonal_count = 0
tile_chunk.chunkGraphic = nil

tile_chunk.graph1 = nil
tile_chunk.graph2 = nil
tile_chunk.graph3 = nil
tile_chunk.graph4 = nil
tile_chunk.graph5 = nil
tile_chunk.graph6 = nil
tile_chunk.graph7 = nil
tile_chunk.graph8 = nil
tile_chunk.graph9 = nil

tile_chunk.animationPollution = nil
tile_chunk.animationPollutionRight = nil
tile_chunk.animationPollutionDown = nil
tile_chunk.animationPollutionLeft = nil
tile_chunk.animationPollutionTop = nil

local tile_chunk_mt = { __index = tile_chunk }
function tile_chunk:new()
	local type_list = {}
	type_list.count = {}
	for i=1,#TILE_TYPES do
		local t_type = TILE_TYPES[i]
		type_list[t_type] = {}
		type_list.count[t_type] = 0
	end
  
    
  

  return setmetatable({ tiles = {},
  	                    diagonal_tiles = {},
                        type_list = type_list,
                        quad_updates = {},
                        update_list = {}}, tile_chunk_mt)
end

function tile_chunk:newAnimation(image, width, height, duration)
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


function tile_chunk:init(grAph, graph1, graph2, graph3, graph4, graph5, graph6, graph7, graph8, graph9, animationPollution, animationPollutionRight, animationPollutionDown, animationPollutionLeft, animationPollutionTop)
	if grAph==1 then
		self.chunkGraphic = graph1
	elseif grAph==2 then
		self.chunkGraphic = graph2
	elseif grAph==3 then
		self.chunkGraphic = graph3
	elseif grAph==4 then
		self.chunkGraphic = graph4
	elseif grAph==5 then
		self.chunkGraphic = graph5
	elseif grAph==6 then
		self.chunkGraphic = graph6
	elseif grAph==7 then
		self.chunkGraphic = graph7
	elseif grAph==8 then
		self.chunkGraphic = graph8
	elseif grAph==9 then
		self.chunkGraphic = graph9
	end
	self.animationPollution = self:newAnimation(animationPollution, 260, 260, 9)
	self.animationPollution.currentTime = 8
	
	self.animationPollutionRight = self:newAnimation(animationPollutionRight, 260, 260, 9)
	self.animationPollutionRight.currentTime = 8
	
	self.animationPollutionDown = self:newAnimation(animationPollutionDown, 260, 260, 9)
	self.animationPollutionDown.currentTime = 8
	
	self.animationPollutionLeft = self:newAnimation(animationPollutionLeft, 260, 260, 9)
	self.animationPollutionLeft.currentTime = 8
	
	self.animationPollutionTop = self:newAnimation(animationPollutionTop, 260, 260, 9)
	self.animationPollutionTop.currentTime = 8
end

-- position of top left corner
function tile_chunk:set_position(x, y)
  self.x, self.y = x, y
end

------------------------------------------------------------------------------
function tile_chunk:set_tiles(tiles)
  self.tiles = tiles
  
  self.height = #tiles
  self.width = #tiles[1]
  local id_val = 1
  
  -- sort tiles into type list
  local type_list = self.type_list
  for j=1,self.height do
  	for i=1,self.width do
  		local tile = tiles[j][i]
  		tile:set_chunk_id(id_val)
  		self.max_chunk_id = id_val
  		id_val = id_val + 1
  		
  		-- add to type list
  		local t_type = tile:get_type()
  		type_list[t_type][tile.chunk_id] = tile
  		type_list.count[t_type] = type_list.count[t_type] + 1
  		
  	end
  end
end

function tile_chunk:set_diagonal_tiles(diag_tiles)
	self.diagonal_tiles = diag_tiles
	local id_val = self.max_chunk_id + 1
	local type_list = self.type_list
	
	for i=1,#diag_tiles do
		local tile = diag_tiles[i]
		tile:set_chunk_id(id_val)
		self.max_chunk_id = id_val
		id_val = id_val + 1
		
		-- add to type list
		local t_type = tile:get_type()
		type_list[t_type][tile.chunk_id] = tile
		type_list.count[t_type] = type_list.count[t_type] + 1
	end
	
	self.diagonal_count = #diag_tiles
end

function tile_chunk:update_type_list(tile, old_type, new_type)
	local t_list = self.type_list  

  -- remove
  t_list[old_type][tile.chunk_id] = nil
  t_list.count[old_type] = t_list.count[old_type] - 1
  
  -- add
  t_list[new_type][tile.chunk_id] = tile
  t_list.count[new_type] = t_list.count[new_type] + 1
  self.quad_updates[#self.quad_updates+1] = tile
end

function tile_chunk:update_quad(tile)
	self.quad_updates[#self.quad_updates+1] = tile
end

-- adds a tile to update list
-- tile:update(dt) will be called until tile:halt_update() is called
function tile_chunk:add_tile_to_update_list(tile)
	self.update_list[tile] = tile
	self.update_list[#self.update_list + 1] = tile
end

function tile_chunk:set_id(id)
	self.id = id
end

-- parent is tile_map object
function tile_chunk:set_parent(parent)
  self.parent = parent
end

-- sets image used as a spritesheet, and its cooresponding quads
function tile_chunk:set_spritesheet(img, quads)
  self.spritesheet = img
  self.quads = quads
end

------------------------------------------------------------------------------
function tile_chunk:init_sprite_batch()
  self.sprite_batch = love.graphics.newSpriteBatch(self.spritesheet, self.max_sprites)
end

------------------------------------------------------------------------------
function tile_chunk:refresh_batch()
  local batch = self.sprite_batch
  batch:clear()
  local num_sprites = 0
  
  local tiles = self.tiles
  for j=1,self.height do
    for i=1,self.width do
      local tile = tiles[j][i]
      batch:add(tile.quad, tile.batch_x, tile.batch_y)
      num_sprites = num_sprites + 1
    end
  end
  
  local diag_tiles = self.diagonal_tiles
  local hw = 0.5 * TILE_WIDTH
  local hh = 0.5 * TILE_WIDTH
  for i=1,#diag_tiles do
  	local tile = diag_tiles[i]
  	batch:add(tile.quad, tile.batch_x + hw, tile.batch_y + hh, 
  	           tile.rotation, 1, 1, hw, hh)
  	num_sprites = num_sprites + 1
  end
  
  self.num_sprites = num_sprites
  self.is_current = true
  self.num_refreshes = self.num_refreshes + 1
end

------------------------------------------------------------------------------
function tile_chunk:update(dt)
  
  -- update tiles in the update list
  local update_list = self.update_list
  local count = 0
  for _,tile in pairs(update_list) do
  	if tile.is_updating then
  		tile:update(dt)
  	else
  		update_list[tile] = nil
  	end
  	count = count + 1
  end
  self.update_count = count
  
  -- update quads on sprite batch
  if self.is_current and #self.quad_updates > 0 then
  	local u_list = self.quad_updates
  	local batch = self.sprite_batch
  	local hw = 0.5 * TILE_WIDTH
    local hh = 0.5 * TILE_WIDTH
  	
  	for i=1,#u_list do
  		local tile = u_list[i]
  		if not tile.is_diagonal then
        batch:add(tile.quad, tile.batch_x, tile.batch_y)
      else
        batch:add(tile.quad, tile.batch_x + hw, tile.batch_y + hh, 
                  tile.rotation, 1, 1, hw, hh)
      end
      self.num_sprites = self.num_sprites + 1
  		
  		if tile.diagonal then
  			local diag_tile = tile.diagonal
  			batch:add(diag_tile.quad, tile.batch_x + hw, tile.batch_y + hh, 
  	                  diag_tile.rotation, 1, 1, hw, hh)
  	        self.num_sprites = self.num_sprites + 1
  		end
  		
  		if self.num_sprites > self.max_sprites then
  			self.is_current = false
  			break
  		end
  	end
  	table.clear(self.quad_updates)
  end
  
  if not self.is_current then
    self:refresh_batch()
  end
end

function tile_chunk:getPollution()
	return self.animationPollution.currentTime
end

function tile_chunk:addPollution(pollution)
	local i = self.animationPollution.currentTime - pollution
	if i > -1 and i < 9 then
		self.animationPollution.currentTime = self.animationPollution.currentTime - pollution
	end
end

function tile_chunk:addPollutionRight(pollution)
	local i = self.animationPollutionRight.currentTime - pollution
	if i > -1 and i < 9 then
		self.animationPollutionRight.currentTime = self.animationPollutionRight.currentTime - pollution
	end
end

function tile_chunk:addPollutionDown(pollution)
	local i = self.animationPollutionDown.currentTime - pollution
	if i > -1 and i < 9 then
		self.animationPollutionDown.currentTime = self.animationPollutionDown.currentTime - pollution
	end
end

function tile_chunk:addPollutionTop(pollution)
	local i = self.animationPollutionTop.currentTime - pollution
	if i > -1 and i < 9 then
		self.animationPollutionTop.currentTime = self.animationPollutionTop.currentTime - pollution
	end
end

function tile_chunk:addPollutionLeft(pollution)
	local i = self.animationPollutionLeft.currentTime - pollution
	if i > -1 and i < 9 then
		self.animationPollutionLeft.currentTime = self.animationPollutionLeft.currentTime - pollution
	end
end

------------------------------------------------------------------------------
function tile_chunk:draw() 
	lg.setColor(255, 255, 255, 255)
    lg.draw(self.sprite_batch, self.x, self.y)
  
  if self.debug then
    --self:draw_debug()
  end
  lg.setColor(255, 255, 255, 255)
  local x, y = self.x, self.y
  local chunkGraphic = self.chunkGraphic
  local animationPollution = self.animationPollution
  local animationPollutionRight = self.animationPollutionRight
  local animationPollutionDown = self.animationPollutionDown
  local animationPollutionTop = self.animationPollutionTop
  local animationPollutionLeft = self.animationPollutionLeft
  --lg.draw(chunkGraphic, x, y) 
  lg.draw(chunkGraphic, x, y)
  --lg.draw(animationPollution, x, y)
  if self.animationPollution.currentTime > -1 then
	local spriteNum = math.floor(animationPollution.currentTime / animationPollution.duration * #animationPollution.quads) + 1
	lg.draw(animationPollution.spriteSheet, animationPollution.quads[spriteNum], x, y)
  end
  if self.animationPollutionRight.currentTime < 9 then
	local spriteNum = math.floor(animationPollutionRight.currentTime / animationPollutionRight.duration * #animationPollutionRight.quads) + 1
	lg.draw(animationPollutionRight.spriteSheet, animationPollutionRight.quads[spriteNum], x, y)
  end
  if self.animationPollutionDown.currentTime < 9 then
	local spriteNum = math.floor(animationPollutionDown.currentTime / animationPollutionDown.duration * #animationPollutionDown.quads) + 1
	lg.draw(animationPollutionDown.spriteSheet, animationPollutionDown.quads[spriteNum], x, y)
  end
  if self.animationPollutionTop.currentTime < 9 then
	local spriteNum = math.floor(animationPollutionTop.currentTime / animationPollutionTop.duration * #animationPollutionTop.quads) + 1
	lg.draw(animationPollutionTop.spriteSheet, animationPollutionTop.quads[spriteNum], x, y)
  end
  if self.animationPollutionLeft.currentTime < 9 then
	local spriteNum = math.floor(animationPollutionLeft.currentTime / animationPollutionLeft.duration * #animationPollutionLeft.quads) + 1
	lg.draw(animationPollutionLeft.spriteSheet, animationPollutionLeft.quads[spriteNum], x, y)
  end
end

function tile_chunk:draw_debug()
	lg.setColor(0, 0, 0, 255)
	lg.setLineWidth(1)
	local x, y = self.x, self.y
	local width, height = self.width * TILE_WIDTH, self.height * TILE_HEIGHT
	lg.rectangle("line", x, y, width, height)
	
	local walk_count = self.type_list.count[T_WALK]
	local wall_count = self.type_list.count[T_WALL]
	local flash_count = self.type_list.count[T_FLASH]
	local total = self.width * self.height
	local updating = self.update_count
	local str = "#TILES: "..total.."\n#SPRITES: "..self.num_sprites..
	            "\nWALK: "..walk_count.."\nWALL: "..wall_count..
	            "\nFLASH: "..flash_count..
	            "\n\n#UPDATING: "..updating..
	            "\n#REFRESHES: "..self.num_refreshes..
	            "\nx: "..self.x.." y: "..self.y
	lg.print(str, x + 10, y + 10)
	
	-- draw updating tiles
	local ulist = self.update_list
	lg.setColor(0,255,0,255)
	lg.setPointSize(3)
	local hw, hh = 0.5 * TILE_WIDTH, 0.5 * TILE_HEIGHT
	for _,tile in pairs(ulist) do
		lg.point(tile.x + hw, tile.y + hh)
	end

end


return tile_chunk



















