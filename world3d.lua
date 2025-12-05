local g3d = require "g3d"
local M = {}

-- -- ASSETS -- --
local floorModel = g3d.newModel("assets/cube.obj", nil, {0, -1, 0}, nil, {50, 1, 50})
local boxModel = g3d.newModel("assets/cube.obj") 

-- -- STATE -- --
local mouseLocked = false
local boxes = {}
local playerHeight = 0.5

-- Camera angles for first-person look
local yaw = 0
local pitch = 0

function M.load()
    -- Setup Camera
    g3d.camera.position = {0, playerHeight, 5}
    g3d.camera.target = {0, playerHeight, 0}
    g3d.camera.up = {0, 1, 0}
    
    -- Initialize camera angles
    yaw = math.pi
    pitch = 0
    
    -- Generate random boxes
    boxes = {}
    for i = 1, 50 do
        table.insert(boxes, {
            x = math.random(-20, 20),
            y = 0,
            z = math.random(-20, 20),
            r = math.random() * math.pi,
            sy = math.random(1, 3) * 0.5,
            color = {math.random(), math.random(), math.random()}
        })
    end

    mouseLocked = false
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
end

function M.update(dt)
    if mouseLocked then
        local moveSpeed = 5 * dt
        
        -- Calculate forward and right vectors based on yaw
        local forward = {
            -math.sin(yaw),
            0,
            -math.cos(yaw)
        }
        
        local right = {
            math.cos(yaw),
            0,
            -math.sin(yaw)
        }
        
        -- WASD movement
        if love.keyboard.isDown('w') then
            g3d.camera.position[1] = g3d.camera.position[1] + forward[1] * moveSpeed
            g3d.camera.position[3] = g3d.camera.position[3] + forward[3] * moveSpeed
        end
        if love.keyboard.isDown('s') then
            g3d.camera.position[1] = g3d.camera.position[1] - forward[1] * moveSpeed
            g3d.camera.position[3] = g3d.camera.position[3] - forward[3] * moveSpeed
        end
        if love.keyboard.isDown('a') then
            g3d.camera.position[1] = g3d.camera.position[1] - right[1] * moveSpeed
            g3d.camera.position[3] = g3d.camera.position[3] - right[3] * moveSpeed
        end
        if love.keyboard.isDown('d') then
            g3d.camera.position[1] = g3d.camera.position[1] + right[1] * moveSpeed
            g3d.camera.position[3] = g3d.camera.position[3] + right[3] * moveSpeed
        end
        
        -- Keep player at constant height
        g3d.camera.position[2] = playerHeight
    end
    
    -- Update camera target based on yaw and pitch
    local targetDistance = 10
    g3d.camera.target[1] = g3d.camera.position[1] - math.sin(yaw) * math.cos(pitch) * targetDistance
    g3d.camera.target[2] = g3d.camera.position[2] + math.sin(pitch) * targetDistance
    g3d.camera.target[3] = g3d.camera.position[3] - math.cos(yaw) * math.cos(pitch) * targetDistance
    
    -- Make sure g3d updates its matrices
    g3d.camera.updateProjectionMatrix()
    g3d.camera.updateViewMatrix()
end

function M.draw()
    love.graphics.clear(0.5, 0.7, 0.9)

    -- Draw Floor
    love.graphics.setColor(0.1, 0.6, 0.2)
    floorModel:draw()

    -- Draw Boxes
    for _, box in ipairs(boxes) do
        love.graphics.setColor(box.color)
        boxModel:setTransform({box.x, box.y, box.z}, {0, box.r, 0}, {0.5, box.sy, 0.5})
        boxModel:draw()
    end
    
    -- HUD
    love.graphics.push("all")
    love.graphics.setDepthMode()
    love.graphics.setColor(1, 1, 1)
    
    if not mouseLocked then
        love.graphics.print("Right-Click to capture mouse and move", 10, 10)
    else
        love.graphics.print("WASD to Walk | Mouse to Look | ESC to release", 10, 10)
    end
    
    love.graphics.print(string.format("Position: %.1f, %.1f, %.1f", 
        g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]), 10, 30)
    love.graphics.print(string.format("Yaw: %.2f | Pitch: %.2f", yaw, pitch), 10, 50)
        
    love.graphics.pop()
end

function M.mousepressed(x, y, button)
    if button == 2 then
        mouseLocked = not mouseLocked
        love.mouse.setRelativeMode(mouseLocked)
        love.mouse.setVisible(not mouseLocked)
    end
end

function M.mousemoved(x, y, dx, dy)
    if mouseLocked then
        local sensitivity = 0.003
        
        yaw = yaw + dx * sensitivity
        pitch = pitch - dy * sensitivity
        
        -- Clamp pitch to prevent camera flipping
        pitch = math.max(-math.pi/2 + 0.1, math.min(math.pi/2 - 0.1, pitch))
    end
end

function M.keypressed(key)
    if key == "escape" and mouseLocked then
        mouseLocked = false
        love.mouse.setRelativeMode(false)
        love.mouse.setVisible(true)
    end
end

function M.exit()
    mouseLocked = false
    love.mouse.setRelativeMode(false)
    love.mouse.setVisible(true)
end

return M