local g3d = require "g3d"
local M = {}

-- -- ASSETS -- --
-- We only use the cube for everything now
local floorModel = g3d.newModel("assets/cube.obj", nil, {0, -1, 0}, nil, {50, 1, 50})
local boxModel = g3d.newModel("assets/cube.obj") 

-- -- STATE -- --
local mouseLocked = false
local boxes = {} -- Table to hold random box positions
local playerHeight = 0.5 -- How high the eyes are off the ground

function M.load()
    -- 1. Setup Camera
    g3d.camera.position = {0, playerHeight, 5}
    g3d.camera.target = {0, playerHeight, 0}
    g3d.camera.up = {0, 1, 0}
    
    -- 2. Generate random boxes
    boxes = {}
    for i = 1, 50 do
        table.insert(boxes, {
            x = math.random(-20, 20),
            y = 0, -- Sit on the floor
            z = math.random(-20, 20),
            r = math.random() * math.pi, -- Random rotation
            sy = math.random(1, 3) * 0.5, -- Random height
            color = {math.random(), math.random(), math.random()} -- Random color
        })
    end

    -- 3. Reset Mouse
    mouseLocked = false
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
end

function M.update(dt)
    -- Camera movement only when mouse is locked
    if mouseLocked then
        -- Standard g3d movement (WASD + Space/Shift)
        g3d.camera.firstPersonMovement(dt, 5)
        
        -- STRICT GRAVITY / WALKING CHECK
        -- We force the Y position to remain constant so the user cannot fly.
        g3d.camera.position[2] = playerHeight
    end
end

function M.draw()
    love.graphics.clear(0.5, 0.7, 0.9) -- Sky blue background

    -- 1. Draw The Floor (Green)
    love.graphics.setColor(0.1, 0.6, 0.2)
    floorModel:draw()

    -- 2. Draw The Random Boxes
    for _, box in ipairs(boxes) do
        love.graphics.setColor(box.color)
        -- We update the generic model's translation/rotation/scale for each box
        boxModel:setTransform({box.x, box.y, box.z}, {0, box.r, 0}, {0.5, box.sy, 0.5})
        boxModel:draw()
    end
    
    -- 3. Draw HUD (2D Overlay)
    love.graphics.push("all")
    love.graphics.setDepthMode() -- Disable depth testing for text
    love.graphics.setColor(1, 1, 1)
    
    if not mouseLocked then
        love.graphics.print("Right-Click to capture mouse and move", 10, 10)
    else
        love.graphics.print("WASD to Walk | Mouse to Look", 10, 10)
    end
    
    love.graphics.print("Position: " .. 
        string.format("%.1f, %.1f, %.1f", 
        g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]), 10, 30)
        
    love.graphics.pop()
end

function M.mousepressed(x, y, button)
    if button == 2 then -- Right click toggles mouse capture
        mouseLocked = not mouseLocked
        love.mouse.setRelativeMode(mouseLocked)
        love.mouse.setVisible(not mouseLocked)
    end
end

function M.mousemoved(x, y, dx, dy)
    if mouseLocked then
        g3d.camera.firstPersonLook(dx, dy)
    end
end

function M.keypressed(key)
    -- ESC is handled by main.lua to exit the mode
end

function M.exit()
    mouseLocked = false
    love.mouse.setRelativeMode(false)
    love.mouse.setVisible(true)
end

return M