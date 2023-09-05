-- local PATH = (...):gsub("%.[^%.]+$", "")

local EntityLayer = {}
EntityLayer.__mt = {
    __index = EntityLayer
}

function EntityLayer.new(layerData, map)
    local m = setmetatable({}, EntityLayer.__mt)

    m.data = layerData
    m.map = map
    m.entities = {}

    for _, entity in ipairs(m.data.entityInstances) do
        local entityInstance = {
            x = entity.px[1],
            y = entity.px[2],
            w = entity.width,
            h = entity.height
        }

        table.insert(m.entities, entityInstance)
    end

    return m
end

function EntityLayer:draw(layerOffsetX, layerOffsetY)
    for _, instance in ipairs(self.entities) do
        local x, y = instance.x + layerOffsetX, instance.y + layerOffsetY

        love.graphics.rectangle("fill", x, y, instance.w, instance.h)
    end
end

return setmetatable(EntityLayer, {
    __call = function(_, ...)
        return EntityLayer.new(...)
    end
})
