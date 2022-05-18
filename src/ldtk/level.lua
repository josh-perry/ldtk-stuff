local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

local TileLayer = require(PATH..".tileLayer")

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

    m:__loadLayers()

    return m
end

function Level:draw()
    for i, v in ipairs(self.layers) do
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
