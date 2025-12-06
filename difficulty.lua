-- difficulty.lua - difficulty switcher with theme support

local module = {}
local theme = require("theme")
local locale = require("locale")

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()

    theme.setColor("text")
    locale.applyFont("title")
    love.graphics.printf(locale.text("difficulty_title"), 0, height/2 - 150, width, "center")

    locale.applyFont("text")

    local bw = 150
    local bh = 60
    local spacing = 50
    local totalWidth = bw*2 + spacing
    local startX = (width - totalWidth)/2
    local startY = height/2 - 100

    module.buttons = {
        {label="difficulty_testing", x=startX, y=startY, difficulty="testing"},
        {label="difficulty_easy", x=startX + bw + spacing, y=startY, difficulty="easy"},
        {label="difficulty_medium", x=startX, y=startY + 100, difficulty="medium"},
        {label="difficulty_hard", x=startX + bw + spacing, y=startY + 100, difficulty="hard"},
    }

    for _, b in ipairs(module.buttons) do
        -- Set button background color based on palette
        if b.difficulty == "testing" then
            love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3])
        elseif b.difficulty == "easy" then
            love.graphics.setColor(p.secondary[1], p.secondary[2], p.secondary[3])
        elseif b.difficulty == "medium" then
            love.graphics.setColor(p.accent[1], p.accent[2], p.accent[3])
        elseif b.difficulty == "hard" then
            -- For hard, use a warning color from palette if available, or a fallback red
            if p.warning then
                love.graphics.setColor(p.warning[1], p.warning[2], p.warning[3])
            else
                love.graphics.setColor(0.8, 0.3, 0.3)  -- Fallback red
            end
        end
        
        -- Draw button background
        love.graphics.rectangle("fill", b.x, b.y, bw, bh, 10, 10)
        
        -- Set text color (will be white in dark mode, black in light mode)
        theme.setColor("text")
        
        -- Draw button text
        love.graphics.printf(locale.text(b.label), b.x, b.y + 20, bw, "center")
    end
    
    theme.setColor("textSecondary")
    locale.applyFont("small")
    love.graphics.printf(locale.text("difficulty_esc_hint"), 0, height - 50, width, "center")
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