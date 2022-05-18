local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

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

    if m.type == "TileLayer" then
        m.tileContainer = layerData.gridTiles
    elseif m.type == "AutoLayer" then
        m.tileContainer = layerData.autoLayerTiles
    elseif m.type == "IntGrid" then
        m.tileContainer = layerData.autoLayerTiles
    else
        --error("Can't find tile container")
    end

    m.tileset = m.map:getTilesetByUid(m.tilesetUid)
    m.tilesX = m.data.__cWid + 1
    m.tilesY = m.data.__cHei + 1

    m:__loadGridTiles()

    return m
end

function TileLayer:draw(offsetX, offsetY)
    for x = 1, self.tilesX + 1 do
        for y = 1, self.tilesY + 1 do
            if self.tiles[x] and self.tiles[x][y] then
                local quad = self:__getQuad(self.tiles[x][y])
                love.graphics.draw(self.tileset.image, quad, (x*self.gridSize)+offsetX, (y*self.gridSize)+offsetY)
            end
        end
    end
end

function TileLayer:__loadGridTiles()
    self.tiles = self.tiles or {}

    for x = 1, self.tilesX + 1 do
        self.tiles[x] = {}

        for y = 1, self.tilesY + 1 do
            self.tiles[x][y] = nil
        end
    end

    if not self.tileContainer then
        return
    end

    for i, v in ipairs(self.tileContainer) do
        -- TODO: load the quad better
        local tile = {
            srcX = v.src[1],
            srcY = v.src[2]
        }

        local tileX = math.floor((v.px[1] / self.gridSize)) + 1
        local tileY = math.floor((v.px[2] / self.gridSize)) + 1

        self.tiles[tileX][tileY] = tile
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
