local ldtk = require("ldtk")
local map

local scrollX, scrollY = 0, 0

function love.load()
    map = ldtk.map("examples/grassy.ldtk")
end

function love.draw()
    love.graphics.translate(math.floor(scrollX), math.floor(scrollY))
    map:draw()
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
