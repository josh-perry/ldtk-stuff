local PATH = (...):gsub("%.[^%.]+$", "")
local json = require(PATH..".lib.json")

local Tileset = {}
Tileset.__mt = {
    __index = Tileset
}

function Tileset.new(tilesetData)
    local m = setmetatable({}, Tileset.__mt)

    m.data = tilesetData
    m.image = love.graphics.newImage(m.data.relPath)
    m.uid = m.data.uid
    m.width, m.height = m.image:getDimensions()

    return m
end

function Tileset:__draw()
    love.graphics.draw(self.image)
end

return setmetatable(Tileset, {
    __call = function(_, ...)
        return Tileset.new(...)
    end
})
