local g3d = require "g3d"
local M = {}

-- -- ASSETS -- --
local floorModel = g3d.newModel("assets/cube.obj", nil, {0, -1, 0}, nil, {50, 1, 50})
local boxModel = g3d.newModel("assets/cube.obj")
local sphereModel = g3d.newModel("assets/sphere.obj")

-- -- STATE -- --
local mouseLocked = false
local boxes = {}
local spheres = {} -- Collectible spheres
local inventory = 0 -- Count of collected spheres
local playerHeight = 0.5
local collectRadius = 2 -- Distance player needs to be to collect
local playerRadius = 0.5 -- Collision radius for player

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
    
    -- Generate random boxes (buildings)
    boxes = {}
    for i = 1, 50 do
        local sx = 0.5
        local sy = math.random(1, 3) * 0.5
        local sz = 0.5
        
        table.insert(boxes, {
            x = math.random(-20, 20),
            y = 0,
            z = math.random(-20, 20),
            r = math.random() * math.pi,
            sx = sx,
            sy = sy,
            sz = sz,
            color = {math.random(), math.random(), math.random()}
        })
    end
    
    -- Generate collectible pink spheres
    spheres = {}
    for i = 1, 20 do
        table.insert(spheres, {
            x = math.random(-20, 20),
            y = 1, -- Float above ground
            z = math.random(-20, 20),
            collected = false,
            bobPhase = math.random() * math.pi * 2, -- Random starting bob phase
            glowPhase = math.random() * math.pi * 2 -- Random glow phase
        })
    end
    
    inventory = 0
    mouseLocked = false
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
end

-- Check if player collides with a box (AABB collision)
local function checkBoxCollision(newX, newZ, box)
    -- Box boundaries (assuming boxes are axis-aligned for simplicity)
    local boxHalfWidth = box.sx
    local boxHalfDepth = box.sz
    
    local boxMinX = box.x - boxHalfWidth
    local boxMaxX = box.x + boxHalfWidth
    local boxMinZ = box.z - boxHalfDepth
    local boxMaxZ = box.z + boxHalfDepth
    
    -- Player boundaries
    local playerMinX = newX - playerRadius
    local playerMaxX = newX + playerRadius
    local playerMinZ = newZ - playerRadius
    local playerMaxZ = newZ + playerRadius
    
    -- Check AABB collision
    return playerMaxX > boxMinX and playerMinX < boxMaxX and
           playerMaxZ > boxMinZ and playerMinZ < boxMaxZ
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
        
        -- Store current position
        local oldX = g3d.camera.position[1]
        local oldZ = g3d.camera.position[3]
        local newX = oldX
        local newZ = oldZ
        
        -- WASD movement (calculate new position)
        if love.keyboard.isDown('w') then
            newX = newX + forward[1] * moveSpeed
            newZ = newZ + forward[3] * moveSpeed
        end
        if love.keyboard.isDown('s') then
            newX = newX - forward[1] * moveSpeed
            newZ = newZ - forward[3] * moveSpeed
        end
        if love.keyboard.isDown('a') then
            newX = newX - right[1] * moveSpeed
            newZ = newZ - right[3] * moveSpeed
        end
        if love.keyboard.isDown('d') then
            newX = newX + right[1] * moveSpeed
            newZ = newZ + right[3] * moveSpeed
        end
        
        -- Check collision with all boxes
        local collisionDetected = false
        for _, box in ipairs(boxes) do
            if checkBoxCollision(newX, newZ, box) then
                collisionDetected = true
                break
            end
        end
        
        -- Only update position if no collision
        if not collisionDetected then
            g3d.camera.position[1] = newX
            g3d.camera.position[3] = newZ
        else
            -- Try sliding along walls (separate X and Z movement)
            -- Try X movement only
            if not checkBoxCollision(newX, oldZ, boxes[1]) then
                local canMoveX = true
                for _, box in ipairs(boxes) do
                    if checkBoxCollision(newX, oldZ, box) then
                        canMoveX = false
                        break
                    end
                end
                if canMoveX then
                    g3d.camera.position[1] = newX
                end
            end
            
            -- Try Z movement only
            if not checkBoxCollision(oldX, newZ, boxes[1]) then
                local canMoveZ = true
                for _, box in ipairs(boxes) do
                    if checkBoxCollision(oldX, newZ, box) then
                        canMoveZ = false
                        break
                    end
                end
                if canMoveZ then
                    g3d.camera.position[3] = newZ
                end
            end
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
    
    -- Update spheres (bobbing animation) and check for collection
    for _, sphere in ipairs(spheres) do
        if not sphere.collected then
            -- Bob up and down
            sphere.bobPhase = sphere.bobPhase + dt * 2
            
            -- Pulsing glow effect
            sphere.glowPhase = sphere.glowPhase + dt * 3
            
            -- Check if player is close enough to collect
            local dx = g3d.camera.position[1] - sphere.x
            local dz = g3d.camera.position[3] - sphere.z
            local distance = math.sqrt(dx * dx + dz * dz)
            
            if distance < collectRadius then
                sphere.collected = true
                inventory = inventory + 1
            end
        end
    end
end

function M.draw()
    love.graphics.clear(0.5, 0.7, 0.9)

    -- Draw Floor
    love.graphics.setColor(0.1, 0.6, 0.2)
    floorModel:draw()

    -- Draw Boxes (Buildings)
    for _, box in ipairs(boxes) do
        love.graphics.setColor(box.color)
        boxModel:setTransform({box.x, box.y, box.z}, {0, box.r, 0}, {box.sx, box.sy, box.sz})
        boxModel:draw()
    end
    
    -- Draw Collectible Spheres with glow effect
    for _, sphere in ipairs(spheres) do
        if not sphere.collected then
            -- Calculate bobbing Y position
            local bobY = sphere.y + math.sin(sphere.bobPhase) * 0.15
            
            -- Calculate pulsing glow intensity (0.7 to 1.0)
            local glowIntensity = 0.7 + math.sin(sphere.glowPhase) * 0.3
            
            -- Draw outer glow layer (larger, more transparent)
            love.graphics.setColor(1, 0.3, 0.8, 0.3 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.25, 0.25, 0.25} -- Outer glow size
            )
            sphereModel:draw()
            
            -- Draw middle glow layer
            love.graphics.setColor(1, 0.4, 0.85, 0.6 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.18, 0.18, 0.18}
            )
            sphereModel:draw()
            
            -- Draw core (bright pink, fully opaque)
            love.graphics.setColor(1, 0.5, 0.9, glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.12, 0.12, 0.12} -- Core size (smaller)
            )
            sphereModel:draw()
        end
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
    love.graphics.print(string.format("Inventory: %d / 20 spheres", inventory), 10, 50)
        
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