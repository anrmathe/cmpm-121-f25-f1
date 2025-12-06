local g3d = require "g3d"
local M = {}    
local theme = require("theme")
local locale = require("locale")

-- -- ASSETS -- --
local floorModel = g3d.newModel("assets/cube.obj", nil, {0, -1, 0}, nil, {50, 1, 50})
local boxModel = g3d.newModel("assets/cube.obj")
local sphereModel = g3d.newModel("assets/sphere.obj")

-- -- STATE -- --
local mouseLocked = false
local boxes = {}
local spheres = {}
local inventory = 0
local playerHeight = 0.5
local collectRadius = 2
local playerRadius = 0.5

-- Camera angles
local yaw = 0
local pitch = 0

function M.load()
    -- Setup Camera
    g3d.camera.position = {0, playerHeight, 5}
    g3d.camera.target = {0, playerHeight, 0}
    g3d.camera.up = {0, 1, 0}
    
    yaw = math.pi
    pitch = 0
    
    -- Generate buildings with nice colors
    boxes = {}
    for i = 1, 50 do
        local sx = 0.5
        local sy = math.random(1, 3) * 0.5
        local sz = 0.5
        
        -- Generate nice varied colors
        local baseR = math.random(50, 90) / 100
        local baseG = math.random(50, 90) / 100
        local baseB = math.random(50, 90) / 100
        
        table.insert(boxes, {
            x = math.random(-20, 20),
            y = 0,
            z = math.random(-20, 20),
            r = math.random() * math.pi,
            sx = sx,
            sy = sy,
            sz = sz,
            color = {baseR, baseG, baseB}
        })
    end
    
    -- Generate spheres
    spheres = {}
    for i = 1, 20 do
        table.insert(spheres, {
            x = math.random(-20, 20),
            y = 1,
            z = math.random(-20, 20),
            collected = false,
            bobPhase = math.random() * math.pi * 2,
            glowPhase = math.random() * math.pi * 2
        })
    end
    
    inventory = 0
    mouseLocked = false
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
end

local function checkBoxCollision(newX, newZ, box)
    local boxHalfWidth = box.sx
    local boxHalfDepth = box.sz
    
    local boxMinX = box.x - boxHalfWidth
    local boxMaxX = box.x + boxHalfWidth
    local boxMinZ = box.z - boxHalfDepth
    local boxMaxZ = box.z + boxHalfDepth
    
    local playerMinX = newX - playerRadius
    local playerMaxX = newX + playerRadius
    local playerMinZ = newZ - playerRadius
    local playerMaxZ = newZ + playerRadius
    
    return playerMaxX > boxMinX and playerMinX < boxMaxX and
           playerMaxZ > boxMinZ and playerMinZ < boxMaxZ
end

function M.update(dt)
    if mouseLocked then
        local moveSpeed = 5 * dt
        
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
        
        local oldX = g3d.camera.position[1]
        local oldZ = g3d.camera.position[3]
        local newX = oldX
        local newZ = oldZ
        
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
        
        local collisionDetected = false
        for _, box in ipairs(boxes) do
            if checkBoxCollision(newX, newZ, box) then
                collisionDetected = true
                break
            end
        end
        
        if not collisionDetected then
            g3d.camera.position[1] = newX
            g3d.camera.position[3] = newZ
        else
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
        
        g3d.camera.position[2] = playerHeight
    end
    
    local targetDistance = 10
    g3d.camera.target[1] = g3d.camera.position[1] - math.sin(yaw) * math.cos(pitch) * targetDistance
    g3d.camera.target[2] = g3d.camera.position[2] + math.sin(pitch) * targetDistance
    g3d.camera.target[3] = g3d.camera.position[3] - math.cos(yaw) * math.cos(pitch) * targetDistance
    
    g3d.camera.updateProjectionMatrix()
    g3d.camera.updateViewMatrix()
    
    for _, sphere in ipairs(spheres) do
        if not sphere.collected then
            sphere.bobPhase = sphere.bobPhase + dt * 2
            sphere.glowPhase = sphere.glowPhase + dt * 3
            
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
    -- Nice sky blue
    love.graphics.clear(0.53, 0.71, 0.95)
    
    -- Draw Floor (vibrant grass)
    love.graphics.setColor(0.25, 0.75, 0.30)
    floorModel:draw()

    -- Draw Buildings - simple approach
    for _, box in ipairs(boxes) do
        -- Just draw the building with its color
        love.graphics.setColor(box.color)
        boxModel:setTransform({box.x, box.y, box.z}, {0, box.r, 0}, {box.sx, box.sy, box.sz})
        boxModel:draw()
        
        -- Draw shadow (dark patch on ground)
        love.graphics.setColor(0.08, 0.3, 0.12, 0.6)
        boxModel:setTransform(
            {box.x + 0.3, -0.98, box.z + 0.3},
            {0, 0, 0},
            {box.sx * 1.2, 0.01, box.sz * 1.2}
        )
        boxModel:draw()
    end
    
    -- Draw Glowing Spheres
    for _, sphere in ipairs(spheres) do
        if not sphere.collected then
            local bobY = sphere.y + math.sin(sphere.bobPhase) * 0.15
            local glowIntensity = 0.7 + math.sin(sphere.glowPhase) * 0.3
            
            -- Outer glow
            love.graphics.setColor(1, 0.3, 0.8, 0.2 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.35, 0.35, 0.35}
            )
            sphereModel:draw()
            
            -- Middle glow
            love.graphics.setColor(1, 0.5, 0.9, 0.5 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.22, 0.22, 0.22}
            )
            sphereModel:draw()
            
            -- Core
            love.graphics.setColor(1, 0.7, 1, glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.15, 0.15, 0.15}
            )
            sphereModel:draw()
        end
    end
    
    -- HUD
    love.graphics.push("all")
    love.graphics.setDepthMode()
    
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 5, 5, 310, 65, 5, 5)
    
    love.graphics.setColor(1, 1, 1)
    locale.applyFont("small")
    
    if not mouseLocked then
        love.graphics.print(locale.text("world_hint_mouse"), 10, 10)
    else
        love.graphics.print(locale.text("world_hint_locked"), 10, 10)
    end
    
    love.graphics.print(string.format(locale.text("world_position"), 
        g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]), 10, 30)
    love.graphics.print(string.format(locale.text("world_inventory"), inventory), 10, 50)
        
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