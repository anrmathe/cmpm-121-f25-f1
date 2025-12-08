-- win.lua - win screen with theme support

local module = {}
local theme  = require("theme")
local locale = require("locale")

local totalTime = 0  -- time measured here in seconds

local function formatElapsed(seconds)
    local total = math.floor(seconds)
    local hours = math.floor(total / 3600)
    local mins  = math.floor((total % 3600) / 60)
    local secs  = total % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, mins, secs)
    else
        return string.format("%d:%02d", mins, secs)
    end
end


function module.setTime(seconds)
    totalTime = seconds or 0
end

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()

    -- Celebration effect
    theme.setPaletteColor("primary")
    locale.applyFont("huge")
    love.graphics.printf(locale.text("win_title_text"), 0, height/2 - 70, width, "center")

    -- time taken below the title. 
    theme.setColor("text")
    locale.applyFont("text")
    local timeLabel = locale.text("win_time_label", formatElapsed(totalTime))
    love.graphics.printf(timeLabel, 0, height/2, width, "center")

    -- Decorative elements
    theme.setPaletteColor("accent")
    love.graphics.circle("fill", width/2 - 150, height/2 - 100, 20)
    love.graphics.circle("fill", width/2 + 150, height/2 - 100, 20)
    
    theme.setPaletteColor("secondary")
    love.graphics.circle("fill", width/2 - 100, height/2 + 80, 15)
    love.graphics.circle("fill", width/2 + 100, height/2 + 80, 15)

    theme.setColor("textSecondary")
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(locale.text("win_esc_hint"), 0, height - 50, width, "center")
end

return module
