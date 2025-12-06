-- settings.lua - Settings menu for theme and palette selection

local module = {}
local theme = require("theme")

module.buttons = {}

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()
    
    -- Title
    theme.setColor("text")
    local titleFont = love.graphics.newFont(30)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SETTINGS", 0, height/2 - 200, width, "center")
    
    local textFont = love.graphics.newFont(20)
    love.graphics.setFont(textFont)
    
    -- Theme Mode Section
    love.graphics.printf("Theme Mode:", 0, height/2 - 120, width, "center")
    
    local bw = 150
    local bh = 50
    local spacing = 20
    local startY = height/2 - 80
    
    -- Light/Dark buttons
    local themeX = width/2 - bw - spacing/2
    
    -- Light button
    if theme.currentMode == "light" then
        love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3], 0.8)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", themeX, startY, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf("Light", themeX, startY + 15, bw, "center")
    
    -- Dark button
    themeX = width/2 + spacing/2
    if theme.currentMode == "dark" then
        love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3], 0.8)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", themeX, startY, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf("Dark", themeX, startY + 15, bw, "center")
    
    -- Color Palette Section
    theme.setColor("text")
    love.graphics.printf("Color Palette:", 0, height/2 + 10, width, "center")
    
    -- Palette buttons (2x2 grid)
    local paletteY = height/2 + 50
    local paletteStartX = width/2 - bw - spacing/2
    
    local palettes = {
        {name = "blue", label = "Blue", x = paletteStartX, y = paletteY},
        {name = "purple", label = "Purple", x = width/2 + spacing/2, y = paletteY},
        {name = "green", label = "Green", x = paletteStartX, y = paletteY + bh + spacing},
        {name = "sunset", label = "Sunset", x = width/2 + spacing/2, y = paletteY + bh + spacing},
    }
    
    module.buttons = {
        light = {x = width/2 - bw - spacing/2, y = height/2 - 80, w = bw, h = bh},
        dark = {x = width/2 + spacing/2, y = height/2 - 80, w = bw, h = bh},
        palettes = palettes
    }
    
    for _, pal in ipairs(palettes) do
        local palColors = theme.palettes[pal.name].primary
        if theme.currentPalette == pal.name then
            love.graphics.setColor(palColors[1], palColors[2], palColors[3], 0.9)
        else
            love.graphics.setColor(palColors[1], palColors[2], palColors[3], 0.5)
        end
        love.graphics.rectangle("fill", pal.x, pal.y, bw, bh, 10, 10)
        theme.setColor("text")
        love.graphics.printf(pal.label, pal.x, pal.y + 15, bw, "center")
    end
    
    -- Back button
    local backY = height - 100
    theme.setPaletteColor("button")
    love.graphics.rectangle("fill", width/2 - 75, backY, 150, 50, 10, 10)
    theme.setColor("text")
    love.graphics.printf("Back to Menu", width/2 - 75, backY + 15, 150, "center")
    
    module.buttons.back = {x = width/2 - 75, y = backY, w = 150, h = 50}
    
    -- Instructions
    theme.setColor("textSecondary")
    local smallFont = love.graphics.newFont(14)
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press ESC to return to menu", 0, height - 30, width, "center")
end

function module.mousepressed(x, y)
    local b = module.buttons
    
    -- Check theme buttons
    if x >= b.light.x and x <= b.light.x + b.light.w and
       y >= b.light.y and y <= b.light.y + b.light.h then
        theme.currentMode = "light"
        return nil
    end
    
    if x >= b.dark.x and x <= b.dark.x + b.dark.w and
       y >= b.dark.y and y <= b.dark.y + b.dark.h then
        theme.currentMode = "dark"
        return nil
    end
    
    -- Check palette buttons
    for _, pal in ipairs(b.palettes) do
        if x >= pal.x and x <= pal.x + 150 and
           y >= pal.y and y <= pal.y + 50 then
            theme.setPalette(pal.name)
            return nil
        end
    end
    
    -- Check back button
    if x >= b.back.x and x <= b.back.x + b.back.w and
       y >= b.back.y and y <= b.back.y + b.back.h then
        return "back"
    end
    
    return nil
end

return module