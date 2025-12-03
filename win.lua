-- win.lua - win screen once 2d puzzle is complete/correct

local module = {}

function module.draw()
    love.graphics.clear(0.2, 0.2, 0.3)
    local width, height = love.graphics.getDimensions()

    local winFont = love.graphics.newFont(64)
    love.graphics.setFont(winFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("YOU WIN!", 0, height/2 - 50, width, "center")

    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ESC to return to menu", 0, height - 50, width, "center")
end
return module
