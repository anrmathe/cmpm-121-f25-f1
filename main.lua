-- main.lua - Mode Switcher for 2D/3D Sudoku

local mode = nil  -- nil means menu, "2d" or "3d" for game modes
local mode2d = nil
local mode3d = nil

function love.load()
    love.window.setTitle("Sudoku - 2D/3D")
    love.window.setMode(900, 700)
end

function love.draw()
    if mode == nil then
        -- Draw menu
        love.graphics.clear(0.2, 0.2, 0.3)
        
        local width, height = love.graphics.getDimensions()
        
        -- Title
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SUDOKU", 0, height/2 - 150, width, "center")
        love.graphics.printf("Choose Mode:", 0, height/2 - 80, width, "center")
        
        -- 2D Button
        local button2DX = width/2 - 200
        local button2DY = height/2
        local buttonWidth = 150
        local buttonHeight = 60
        
        love.graphics.setColor(0.3, 0.5, 0.8)
        love.graphics.rectangle("fill", button2DX, button2DY, buttonWidth, buttonHeight, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("2D Mode", button2DX, button2DY + 20, buttonWidth, "center")
        
        -- 3D Button
        local button3DX = width/2 + 50
        local button3DY = height/2
        
        love.graphics.setColor(0.5, 0.3, 0.8)
        love.graphics.rectangle("fill", button3DX, button3DY, buttonWidth, buttonHeight, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("3D Mode", button3DX, button3DY + 20, buttonWidth, "center")
        
        -- Instructions
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("Press ESC in game to return to menu", 0, height - 50, width, "center")
    elseif mode == "2d" then
        if mode2d then
            mode2d.draw()
        end
    elseif mode == "3d" then
        if mode3d then
            mode3d.draw()
        end
    end
end

function love.update(dt)
    if mode == "2d" and mode2d then
        mode2d.update(dt)
    elseif mode == "3d" and mode3d then
        mode3d.update(dt)
    end
end

function love.mousepressed(x, y, button)
    if mode == nil then
        local width, height = love.graphics.getDimensions()
        
        -- Check 2D button
        local button2DX = width/2 - 200
        local button2DY = height/2
        local buttonWidth = 150
        local buttonHeight = 60
        
        if x >= button2DX and x <= button2DX + buttonWidth and
           y >= button2DY and y <= button2DY + buttonHeight then
            mode = "2d"
            mode2d = require("2d")
            mode2d.load()
        end
        
        -- Check 3D button
        local button3DX = width/2 + 50
        local button3DY = height/2
        
        if x >= button3DX and x <= button3DX + buttonWidth and
           y >= button3DY and y <= button3DY + buttonHeight then
            mode = "3d"
            mode3d = require("3d")
            mode3d.load()
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
            mode2d = nil
            mode3d = nil
        else
            love.event.quit()
        end
    elseif mode == "2d" and mode2d then
        mode2d.keypressed(key)
    elseif mode == "3d" and mode3d then
        mode3d.keypressed(key)
    end
end