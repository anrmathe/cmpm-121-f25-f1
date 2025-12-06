-- difficulty.lua - difficulty switcher with theme support

local module = {}
local theme = require("theme")

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()

    theme.setColor("text")
    local titleFont = love.graphics.newFont(30)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SELECT DIFFICULTY", 0, height/2 - 150, width, "center")

    local textFont = love.graphics.newFont(20)
    love.graphics.setFont(textFont)

    local bw = 150
    local bh = 60
    local spacing = 50
    local totalWidth = bw*2 + spacing
    local startX = (width - totalWidth)/2
    local startY = height/2 - 100

    module.buttons = {
        {label="Testing", x=startX, y=startY, difficulty="testing"},
        {label="Easy", x=startX + bw + spacing, y=startY, difficulty="easy"},
        {label="Medium", x=startX, y=startY + 100, difficulty="medium"},
        {label="Hard", x=startX + bw + spacing, y=startY + 100, difficulty="hard"},
    }

    for _, b in ipairs(module.buttons) do
        if b.label == "Testing" then
            theme.setPaletteColor("primary")
        elseif b.label == "Easy" then
            love.graphics.setColor(0.3, 0.8, 0.4)
        elseif b.label == "Medium" then
            love.graphics.setColor(0.8, 0.7, 0.3)
        elseif b.label == "Hard" then
            love.graphics.setColor(0.8, 0.3, 0.3)
        end
        love.graphics.rectangle("fill", b.x, b.y, bw, bh, 10, 10)
        theme.setColor("text")
        love.graphics.printf(b.label, b.x, b.y + 20, bw, "center")
    end
    
    theme.setColor("textSecondary")
    local smallFont = love.graphics.newFont(14)
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press ESC in game to return to menu", 0, height - 50, width, "center")
end

function module.mousepressed(x, y)
    local bw = 150
    local bh = 60

    for _, b in ipairs(module.buttons) do
        if x >= b.x and x <= b.x + bw and y >= b.y and y <= b.y + bh then
            return b.difficulty
        end
    end
    return nil
end

return module