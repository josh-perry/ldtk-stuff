local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

local AutoLayer = {}
AutoLayer.__mt = {
    __index = AutoLayer
}

local quads = {}

function AutoLayer.new(layerData, map)
    local m = setmetatable({}, AutoLayer.__mt)

    m.data = layerData
    m.map = map
    m.tilesetUid = layerData.__tilesetDefUid
    m.gridSize = layerData.__gridSize
    m.autoLayerTiles = layerData.autoLayerTiles

    m.tileset = m.map:getTilesetByUid(m.tilesetUid)
    m.tilesX = m.data.__cWid + 1
    m.tilesY = m.data.__cHei + 1

    m.visible = m.data.visible

    m:__loadGridTiles()

    return m
end

function AutoLayer:draw(offsetX, offsetY)
    if not self.visible then
        return
    end

    for x = 1, self.tilesX + 1 do
        for y = 1, self.tilesY + 1 do
            if self.tiles[x] and self.tiles[x][y] then
                local quad = self:__getQuad(self.tiles[x][y])
                love.graphics.draw(self.tileset.image, quad, ((x-1)*self.gridSize)+offsetX, ((y-1)*self.gridSize)+offsetY)
            end
        end
    end
end

function AutoLayer:__loadGridTiles()
    self.tiles = self.tiles or {}

    for x = 1, self.tilesX + 1 do
        self.tiles[x] = {}

        for y = 1, self.tilesY + 1 do
            self.tiles[x][y] = nil
        end
    end

    for i, v in ipairs(self.autoLayerTiles) do
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

function AutoLayer:__getQuad(quadPosition)
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

return setmetatable(AutoLayer, {
    __call = function(_, ...)
        return AutoLayer.new(...)
    end
})
