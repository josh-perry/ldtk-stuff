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
    m.gridTiles = layerData.gridTiles

    m.tileset = m.map:getTilesetByUid(m.tilesetUid)
    m.tilesX = m.data.__cWid + 1
    m.tilesY = m.data.__cHei + 1

    m:__loadGridTiles()

    return m
end

function TileLayer:draw()
    for x = 1, self.tilesX + 1 do
        for y = 1, self.tilesY + 1 do
            if self.tiles[x] and self.tiles[x][y] then
                local quad = self:__getQuad(self.tiles[x][y])
                love.graphics.draw(self.tileset.image, quad, x*self.gridSize, y*self.gridSize)
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

    for i, v in ipairs(self.gridTiles) do
        -- TODO: load the quad better
        local tile = {
            srcX = v.src[1],
            srcY = v.src[2]
        }

        local tileX = v.px[1] / self.gridSize
        local tileY = v.px[2] / self.gridSize

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
