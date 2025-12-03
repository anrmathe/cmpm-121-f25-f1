-- main.lua - Mode Switcher for 2D/3D Sudoku

local mode = nil
local mode2d = nil
local mode3d = nil
local difficultyModule = nil
local chosenMode = nil
local difficulty = nil

function love.load()
    love.window.setTitle("Sudoku - 2D/3D")
    love.window.setMode(900, 700)
end

local function drawMenu()
    love.graphics.clear(0.2, 0.2, 0.3)
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1)
    local textFont = love.graphics.newFont()
    local titleFont = love.graphics.newFont(30)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SUDOKU", 0, height/2 - 150, width, "center")
    love.graphics.setFont(textFont)
    love.graphics.printf("Choose Mode:", 0, height/2 - 40, width, "center")

    local bx = width/2 - 180
    local by = height/2
    local bw = 150
    local bh = 60

    love.graphics.setColor(0.3, 0.5, 0.8)
    love.graphics.rectangle("fill", bx, by, bw, bh, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("2D Mode", bx, by + 20, bw, "center")

    local bx2 = width/2 + 20
    love.graphics.setColor(0.5, 0.3, 0.8)
    love.graphics.rectangle("fill", bx2, by, bw, bh, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("3D Mode", bx2, by + 20, bw, "center")

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ESC in game to return to menu", 0, height - 50, width, "center")
end

function love.draw()
    if mode == nil then
        drawMenu()
    elseif mode == "difficulty" then
        if difficultyModule then difficultyModule.draw() end
    elseif mode == "2d" then
        if mode2d then mode2d.draw() end
    elseif mode == "3d" then
        if mode3d then mode3d.draw() end
    elseif mode == "win" then
        local winScreen = require("win")
        winScreen.draw()
    end
end

function love.update(dt)
    if mode == "2d" and mode2d then
        local result = mode2d.update(dt)
        if result == "win" then
            mode = "win"
            mode2d = nil
            mode3d = nil
            difficultyModule = nil
        end
    elseif mode == "3d" and mode3d then
        local result = mode3d.update(dt)
        if result == "win" then
            mode = "win"
            mode2d = nil
            mode3d = nil
            difficultyModule = nil
        end
    end
end

function love.mousepressed(x, y, button)
    local width, height = love.graphics.getDimensions()

    if mode == nil then
        local bx = width/2 - 180
        local by = height/2
        local bw = 150
        local bh = 60

        if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
            chosenMode = "2d"
            mode = "difficulty"
            difficultyModule = require("difficulty")
            return
        end

        if x >= bx + 250 and x <= bx + 250 + bw and y >= by and y <= by + bh then
            chosenMode = "3d"
            mode = "difficulty"
            difficultyModule = require("difficulty")
            return
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
        mode2d.mousepressed(x, y, button)
    elseif mode == "3d" and mode3d then
        mode3d.mousepressed(x, y, button)
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
    end
end

function love.keypressed(key)
    if key == "escape" then
        if mode ~= nil then
            mode = nil
            chosenMode = nil
            difficulty = nil
            mode2d = nil
            mode3d = nil
            difficultyModule = nil
        else
            love.event.quit()
        end
    elseif mode == "2d" and mode2d then
        mode2d.keypressed(key)
    elseif mode == "3d" and mode3d then
        mode3d.keypressed(key)
    end
end
