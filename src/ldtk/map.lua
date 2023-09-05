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

    m.maxWorldDepth = 0
    m.minWorldDepth = 0

    local jsonData = json.decode(love.filesystem.read(mapFile))
    m.relativePath = mapFile:match("(.*[/\\])") or ""
    m:__loadTilesets(jsonData.defs.tilesets)
    m:__loadLevels(jsonData.levels)

    return m
end

function Map:draw(worldDepth)
    for _, v in ipairs(self.levels) do
        if not worldDepth or v.worldDepth == worldDepth then
            v:draw()
        end
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

    error("Can't find tileset "..uid)
end

function Map:__loadTilesets(tilesetData)
    self.tilesets = self.tilesets or {}

    for _, v in ipairs(tilesetData) do
        if v.relPath then
            table.insert(self.tilesets, Tileset(v, self.relativePath))
        end
    end
end

function Map:__loadLevels(levelsData)
    self.levels = self.levels or {}

    for _, v in ipairs(levelsData) do
        local level = Level(v, self)
        table.insert(self.levels, level)

        self.maxWorldDepth = math.max(self.maxWorldDepth or 0, level.worldDepth)
        self.minWorldDepth = math.min(self.minWorldDepth or 0, level.worldDepth)
    end
end

return setmetatable(Map, {
    __call = function(_, ...)
        return Map.new(...)
    end
})
