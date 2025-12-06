-- win.lua - win screen with theme support

local module = {}
local theme = require("theme")

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()

    -- Celebration effect
    theme.setPaletteColor("primary")
    local winFont = love.graphics.newFont(64)
    love.graphics.setFont(winFont)
    love.graphics.printf("YOU WIN!", 0, height/2 - 50, width, "center")

    -- Draw some decorative elements
    theme.setPaletteColor("accent")
    love.graphics.circle("fill", width/2 - 150, height/2 - 100, 20)
    love.graphics.circle("fill", width/2 + 150, height/2 - 100, 20)
    
    theme.setPaletteColor("secondary")
    love.graphics.circle("fill", width/2 - 100, height/2 + 80, 15)
    love.graphics.circle("fill", width/2 + 100, height/2 + 80, 15)

    theme.setColor("textSecondary")
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Press ESC to return to menu", 0, height - 50, width, "center")
end

return module