local ldtk = require("ldtk")
local map

function love.load()
    map = ldtk.map("test.ldtk")
end

function love.draw()
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
