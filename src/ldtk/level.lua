local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

local TileLayer = require(PATH..".tileLayer")
local EntityLayer = require(PATH..".entityLayer")

local Level = {}
Level.__mt = {
    __index = Level
}

function Level.new(levelData, map)
    local m = setmetatable({}, Level.__mt)

    m.data = levelData
    m.map = map

    m.worldX = levelData.worldX
    m.worldY = levelData.worldY

    m.width = m.data.pxWid
    m.height = m.data.pxHei

    m.worldDepth = m.data.worldDepth or 0
    m.identifier = m.data.identifier

    m:__loadLayers()

    return m
end

function Level:draw()
    for i = #self.layers, 1, -1 do
        local v = self.layers[i]
        v:draw(self.worldX, self.worldY)
    end
end

function Level:__loadLayers()
    self.layers = self.layers or {}

    for i, v in ipairs(self.data.layerInstances) do
        if v.__type == "Tiles" then
            table.insert(self.layers, TileLayer(v, self.map))
        elseif v.__type == "AutoLayer" then
            table.insert(self.layers, TileLayer(v, self.map))
        elseif v.__type == "IntGrid" then
            table.insert(self.layers, TileLayer(v, self.map))
        elseif v.__type == "Entities" then
            table.insert(self.layers, EntityLayer(v, self.map))
        else
            print("Unsupported layer type '"..v.__type.."'!")
        end
    end
end

return setmetatable(Level, {
    __call = function(_, ...)
        return Level.new(...)
    end
})
