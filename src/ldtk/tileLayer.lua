local PATH = (...):gsub("%.[^%.]+$", "")

local tileProperties = require(PATH..".tileProperties")

local TileLayer = {}
TileLayer.__mt = {
    __index = TileLayer
}

local quads = {}

function TileLayer.new(layerData, map)
    local m = setmetatable({}, TileLayer.__mt)

    m.data = layerData
    m.map = map
    m.tilesetUid = layerData.__tilesetDefUid
    m.gridSize = layerData.__gridSize

    m.type = layerData.__type

    if m.type == "Tiles" then
        m.tileContainer = layerData.gridTiles
    elseif m.type == "AutoLayer" then
        m.tileContainer = layerData.autoLayerTiles
    elseif m.type == "IntGrid" then
        m.tileContainer = layerData.autoLayerTiles
    else
        error("Can't find tile container")
    end

    m.tileset = m.map:getTilesetByUid(m.tilesetUid)
    m.tilesX = m.data.__cWid + 1
    m.tilesY = m.data.__cHei + 1

    m.visible = m.data.visible

    m:__loadGridTiles()

    return m
end

function TileLayer:draw(layerOffsetX, layerOffsetY)
    if not self.visible then
        return
    end

    for tileX = 1, self.tilesX + 1 do
        for tileY = 1, self.tilesY + 1 do
            if self.tiles[tileX] and self.tiles[tileX][tileY] then
                love.graphics.setColor(1, 1, 1)

                local tile = self.tiles[tileX][tileY]
                local quad = self:__getQuad(tile)

                local flipXOffset = 0
                local flipYOffset = 0
                local scaleX, scaleY = 1, 1

                local properties = self.tileProperties[tile]

                if properties then
                    local flipBits = tileProperties.flipBits

                    if properties.f == flipBits.flipX then
                        flipXOffset = self.gridSize
                        scaleX = -1
                    elseif properties.f == flipBits.flipY then
                        flipYOffset = self.gridSize
                        scaleY = -1
                    elseif properties.f == flipBits.flipXY then
                        flipXOffset = self.gridSize
                        flipYOffset = self.gridSize
                        scaleX, scaleY = -1, -1
                    end

                    if properties.a then
                        love.graphics.setColor(1, 1, 1, properties.a)
                    end
                end

                local x = ((tileX-1)*self.gridSize)+layerOffsetX
                local y = ((tileY-1)*self.gridSize)+layerOffsetY

                love.graphics.draw(self.tileset.image, quad, x, y, 0, scaleX, scaleY, flipXOffset, flipYOffset)
            end
        end
    end
end

function TileLayer:__loadGridTiles()
    self.tiles = self.tiles or {}

    for x = 0, self.tilesX do
        self.tiles[x] = {}

        for y = 0, self.tilesY do
            self.tiles[x][y] = nil
        end
    end

    if not self.tileContainer then
        return
    end

    self.tileProperties = {}

    for i, v in ipairs(self.tileContainer) do
        -- TODO: load the quad better
        local tile = {
            srcX = v.src[1],
            srcY = v.src[2]
        }

        local tileX = math.floor((v.px[1] / self.gridSize)) + 1
        local tileY = math.floor((v.px[2] / self.gridSize)) + 1

        self.tiles[tileX][tileY] = tile

        -- if we have any properties differing from the default, store them
        if v.a ~= 1 or v.f ~= tileProperties.flipBits.noFlip then
            self.tileProperties[tile] = {
                a = v.a,
                f = v.f
            }
        end
    end
end

function TileLayer:__getQuad(quadPosition)
    local x, y = quadPosition.srcX, quadPosition.srcY

    if not quads[x] then
        quads[x] = {}
    end

    if quads[x][y] then
        return quads[x][y]
    end

    quads[x][y] = love.graphics.newQuad(x, y, self.gridSize, self.gridSize, self.tileset.width, self.tileset.height)
    return quads[x][y]
end

return setmetatable(TileLayer, {
    __call = function(_, ...)
        return TileLayer.new(...)
    end
})
