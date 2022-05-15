local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

local Tileset = require(PATH..".tileset")
local Level = require(PATH..".level")

local Map = {}
Map.__mt = {
    __index = Map
}

function Map.new(mapFile)
    local m = setmetatable({}, Map.__mt)

    if not love.filesystem.getInfo(mapFile) then
        error("No map file: '"..mapFile.."' found!")
    end

    local jsonData = json.decode(love.filesystem.read(mapFile))
    m:__loadTilesets(jsonData.defs.tilesets)
    m:__loadLevels(jsonData.levels)

    return m
end

function Map:draw()
    for _, v in ipairs(self.levels) do
        v:draw()
    end
end

function Map:update(dt)
end

function Map:getTilesetByUid(uid)
    for _, v in ipairs(self.tilesets) do
        if v.uid == uid then
            return v
        end
    end
end

function Map:__loadTilesets(tilesetData)
    self.tilesets = self.tilesets or {}

    for _, v in ipairs(tilesetData) do
        table.insert(self.tilesets, Tileset(v))
    end
end

function Map:__loadLevels(levelsData)
    self.levels = self.levels or {}

    for _, v in ipairs(levelsData) do
        table.insert(self.levels, Level(v, self))
    end
end

return setmetatable(Map, {
    __call = function(_, ...)
        return Map.new(...)
    end
})
