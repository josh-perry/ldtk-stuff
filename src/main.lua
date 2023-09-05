local ldtk = require("ldtk")
local map

local scrollX, scrollY = 0, 0

local function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
        x2 < x1 + w1 and
        y1 < y2 + h2 and
        y2 < y1 + h1
end

function love.load()
end

function love.draw()
    love.graphics.push("all")
    love.graphics.translate(math.floor(scrollX), math.floor(scrollY))

    local margin = 100

    local cameraX, cameraY, cameraW, cameraH = -scrollX + margin, -scrollY + margin, love.graphics.getWidth() - margin*2, love.graphics.getHeight() - margin*2

    for _, level in ipairs(map.levels) do
        local x, y, w, h = cameraX, cameraY, cameraW, cameraH
        local x2, y2, w2, h2 = level.worldX, level.worldY, level.width, level.height

        if aabb(x, y, w, h, x2, y2, w2, h2) then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.1)
        end

        level:draw()
        love.graphics.rectangle("line", level.worldX, level.worldY, level.width, level.height)
    end

    love.graphics.setLineWidth(6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", cameraX, cameraY, cameraW, cameraH)
    love.graphics.pop()
end

function love.update(dt)
    map:update(dt)
end

function love.keypressed(key, scancode)
    if scancode == "escape" then
        love.event.quit()
    end
end

function love.mousemoved(x, y, dx, dy)
    if not love.mouse.isDown(1) then
        return
    end

    scrollX = scrollX + dx
    scrollY = scrollY + dy
end
