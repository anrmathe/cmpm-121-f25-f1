-- main.lua - Mode Switcher for 2D/3D Sudoku and World 3D with Settings
print("SAVE DIR:", love.filesystem.getSaveDirectory())

-- locale requirement
local theme = require("theme")
local difficulty = require("difficulty")
local mode2d = require("2d")
local mode3d = require("3d")
local world3d = require("world3d")
local winScreen = require("win")
local settings = require("settings")
local locale = require("locale")

local mode = nil
local mode2d = nil
local mode3d = nil
local modeWorld = nil
local settingsModule = nil
local difficultyModule = nil
local chosenMode = nil
local difficulty = nil
local theme = require("theme")

function love.load()
    love.osName = love.system.getOS()
    
    if osName == "Android" or osName == "iOS" then
        -- fullscreens on mobile
        love.window.setMode(0, 0, {fullscreen = true, resizable = false})
    else
        -- window settings for desktop
        love.window.setMode(900, 700, {resizable = true, minwidth = 800, minheight = 600})
    end

    love.window.setTitle(locale.text("window_title"))

    -- language-aware font sets

    local CHINESE_FONT = "assets/fonts/chinese/static/NotoSansSC-Regular.ttf"
    local ARABIC_FONT  = "assets/fonts/arabic/static/NotoNaskhArabic-Regular.ttf"

    fonts = {
        en = {
            huge  = love.graphics.newFont(64),
            title = love.graphics.newFont(30),
            text  = love.graphics.newFont(20),
            small = love.graphics.newFont(14),
        },
        zh = {
            huge  = love.graphics.newFont(CHINESE_FONT, 64),
            title = love.graphics.newFont(CHINESE_FONT, 30),
            text  = love.graphics.newFont(CHINESE_FONT, 20),
            small = love.graphics.newFont(CHINESE_FONT, 14),
        },
        ar = {
            huge  = love.graphics.newFont(ARABIC_FONT, 64),
            title = love.graphics.newFont(ARABIC_FONT, 30),
            text  = love.graphics.newFont(ARABIC_FONT, 20),
            small = love.graphics.newFont(ARABIC_FONT, 14),
        },
    }

    if locale.applyFont then
        locale.applyFont("text")
    end
end

local function drawMenu()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()
    theme.setColor("text")
    
    local textFont = love.graphics.newFont()
    local titleFont = love.graphics.newFont(30)
    love.graphics.setFont(titleFont)
    locale.applyFont("title")
    love.graphics.printf(locale.text("menu_title"), 0, height/2 - 150, width, "center")
    love.graphics.setFont(textFont)
    locale.applyFont("text")
    love.graphics.printf(locale.text("menu_choose_mode"), 0, height/2 - 40, width, "center")

    -- Button Dimensions
    local bw = 150
    local bh = 60
    local by = height/2
    
    -- Calculate centered X positions for 3 buttons
    local spacing = 20
    local totalWidth = (bw * 3) + (spacing * 2)
    local startX = (width - totalWidth) / 2
    
    -- Button 1: 2D
    local bx1 = startX
    theme.setPaletteColor("primary")
    love.graphics.rectangle("fill", bx1, by, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf(locale.text("menu_mode_2d"), bx1, by + 20, bw, "center")

    -- Button 2: 3D
    local bx2 = bx1 + bw + spacing
    theme.setPaletteColor("secondary")
    love.graphics.rectangle("fill", bx2, by, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf(locale.text("menu_mode_3d"), bx2, by + 20, bw, "center")

    -- Button 3: World
    local bx3 = bx2 + bw + spacing
    theme.setPaletteColor("accent")
    love.graphics.rectangle("fill", bx3, by, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf(locale.text("menu_mode_world"), bx3, by + 20, bw, "center")

    -- Settings button
    local settingsY = by + bh + 30
    local settingsW = 200
    local settingsX = width/2 - settingsW/2
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("fill", settingsX, settingsY, settingsW, 50, 10, 10)
    theme.setColor("text")
    locale.applyFont("text")
    love.graphics.printf(locale.text("menu_settings"), settingsX, settingsY + 15, settingsW, "center")

    theme.setColor("textSecondary")
    locale.applyFont("small")
    love.graphics.printf(locale.text("menu_esc_hint"), 0, height - 50, width, "center")
end

function love.draw()
    if mode == nil then
        drawMenu()
    elseif mode == "settings" then
        if settingsModule then settingsModule.draw() end
    elseif mode == "difficulty" then
        if difficultyModule then difficultyModule.draw() end
    elseif mode == "2d" then
        if mode2d then mode2d.draw() end
    elseif mode == "3d" then
        if mode3d then mode3d.draw() end
    elseif mode == "world" then
        if modeWorld then modeWorld.draw() end
    elseif mode == "win" then
        local winScreen = require("win")
        winScreen.draw()
    end
end

function love.update(dt)
    if mode == "2d" and mode2d then
        local result = mode2d.update(dt)
        if result == "win" then
            local Save = require("save")
            Save.delete("2d", mode2d.currentDifficulty)

            mode = "win"
            mode2d = nil
        end
    elseif mode == "3d" and mode3d then
        local result = mode3d.update(dt)
        if result == "win" then
            mode = "win"
            mode3d = nil
        end
    elseif mode == "world" and modeWorld then
        modeWorld.update(dt)
    end
end

function love.mousepressed(x, y, button)
    local width, height = love.graphics.getDimensions()

    if mode == nil then
        -- Button Dimensions logic must match drawMenu
        local bw = 150
        local bh = 60
        local by = height/2
        local spacing = 20
        local totalWidth = (bw * 3) + (spacing * 2)
        local startX = (width - totalWidth) / 2
        
        local bx1 = startX
        local bx2 = bx1 + bw + spacing
        local bx3 = bx2 + bw + spacing

        -- Check 2D Button
        if x >= bx1 and x <= bx1 + bw and y >= by and y <= by + bh then
            chosenMode = "2d"
            mode = "difficulty"
            difficultyModule = require("difficulty")
            return
        end

        -- Check 3D Button
        if x >= bx2 and x <= bx2 + bw and y >= by and y <= by + bh then
            chosenMode = "3d"
            mode = "difficulty"
            difficultyModule = require("difficulty")
            return
        end

        -- Check World Button
        if x >= bx3 and x <= bx3 + bw and y >= by and y <= by + bh then
            mode = "world"
            modeWorld = require("world3d")
            modeWorld.load()
            return
        end

        -- Check Settings Button
        local settingsY = by + bh + 30
        local settingsW = 200
        local settingsX = width/2 - settingsW/2
        if x >= settingsX and x <= settingsX + settingsW and y >= settingsY and y <= settingsY + 50 then
            mode = "settings"
            settingsModule = require("settings")
            return
        end

    elseif mode == "settings" then
        local result = settingsModule.mousepressed(x, y)
        if result == "back" then
            mode = nil
            settingsModule = nil
        end
    elseif mode == "difficulty" then
        difficulty = difficultyModule.mousepressed(x, y)
        if difficulty then
            if chosenMode == "2d" then
                mode = "2d"
                mode2d = require("2d")
                mode2d.load(difficulty)
            else
                mode = "3d"
                mode3d = require("3d")
                mode3d.load(difficulty)
            end
        end
    elseif mode == "2d" and mode2d then
        local result = mode2d.mousepressed(x, y, button)

        if result == "back" then
            -- return to difficulty screen
            mode = "difficulty"
            difficultyModule = require("difficulty")
            mode2d = nil
            return
        end
    elseif mode == "3d" and mode3d then
        mode3d.mousepressed(x, y, button)
    elseif mode == "world" and modeWorld then
        modeWorld.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if mode == "2d" and mode2d then
        mode2d.mousereleased(x, y, button)
    elseif mode == "3d" and mode3d then
        mode3d.mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    if mode == "2d" and mode2d and mode2d.mousemoved then
        mode2d.mousemoved(x, y, dx, dy)
    elseif mode == "3d" and mode3d then
        mode3d.mousemoved(x, y, dx, dy)
    elseif mode == "world" and modeWorld then
        modeWorld.mousemoved(x, y, dx, dy)
    end
end

function love.keypressed(key)
    if key == "escape" then
        if mode ~= nil then
            -- Clean up logic when returning to menu
            if mode == "world" and modeWorld then
                modeWorld.exit()
            end
            
            mode = nil
            chosenMode = nil
            difficulty = nil
            mode2d = nil
            mode3d = nil
            modeWorld = nil
            difficultyModule = nil
            settingsModule = nil
        else
            love.event.quit()
        end
    elseif mode == "2d" and mode2d then
        mode2d.keypressed(key)
    elseif mode == "3d" and mode3d then
        mode3d.keypressed(key)
    elseif mode == "world" and modeWorld then
        modeWorld.keypressed(key)
    end
end