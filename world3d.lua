local g3d = require "g3d"
local M = {}    
local theme = require("theme")
local locale = require("locale")
local config = require("config")

-- -- ASSETS -- --
local floorModel = g3d.newModel("assets/cube.obj", nil, {0, -1, 0}, nil, {50, 1, 50})
local boxModel = g3d.newModel("assets/cube.obj")
local sphereModel = g3d.newModel("assets/sphere.obj")

-- -- STATE -- --
local mouseLocked = false
local boxes = {}
local spheres = {}
local inventory = 0
local inventoryCapacity = 20

-- physics
local playerHeight = 0.5   -- ground height of player
local playerY = playerHeight
local playerVelY = 0
local gravity = -6         
local jumpSpeed = 4.5      

local collectRadius = 2
local playerRadius = 0.5

-- Camera angles
local yaw = 0
local pitch = 0

-- Joystick + camera control state
local joystickX, joystickY = 0, 0        
local joystickTouchId = nil              
local mouseJoystickActive = false        
local lookTouchId = nil                  
local mouseLookDragActive = false        

-- Joystick geometry 
local function getJoystickCenter()
    local w, h = love.graphics.getDimensions()
    local radius = math.min(w, h) * 0.12
    local cx = w - radius - 40    
    local cy = h - radius - 40
    return cx, cy, radius
end

-- Jump button geometry 
local function getJumpButton()
    local w, h = love.graphics.getDimensions()
    local _, _, joystickRadius = getJoystickCenter()
    local halfSize = joystickRadius
    local cx = halfSize + 40
    local cy = h - halfSize - 40
    return cx, cy, halfSize
end

local function updateJoystickFromPosition(x, y)
    local cx, cy, r = getJoystickCenter()
    local dx = x - cx
    local dy = y - cy
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > r and dist > 0 then
        dx = dx * r / dist
        dy = dy * r / dist
    end
    joystickX = dx / r
    joystickY = -dy / r   -- up = forward, down = backward
end

-- jump action
local function tryJump()
    if playerVelY <= 0 and math.abs(playerY - playerHeight) < 0.01 then
        playerVelY = jumpSpeed
    end
end

function M.load()
    playerY = playerHeight
    playerVelY = 0

    g3d.camera.position = {0, playerY, 5}
    g3d.camera.target = {0, playerY, 0}
    g3d.camera.up = {0, 1, 0}
    
    yaw = math.pi
    pitch = 0

    local worldCfg = config.getWorld3D()
    local boxCfg = worldCfg and worldCfg.boxes or {}
    local sphereCfg = worldCfg and worldCfg.spheres or {}
    local invCfg = worldCfg and worldCfg.inventory or {}

    local boxCount   = boxCfg.count or 50
    local boxMinX    = boxCfg.minX or -20
    local boxMaxX    = boxCfg.maxX or  20
    local boxMinZ    = boxCfg.minZ or -20
    local boxMaxZ    = boxCfg.maxZ or  20
    local boxMinH    = boxCfg.minHeight or 0.5
    local boxMaxH    = boxCfg.maxHeight or 1.5

    local sphereCount = sphereCfg.count or 20
    local sphereMinX  = sphereCfg.minX or -20
    local sphereMaxX  = sphereCfg.maxX or  20
    local sphereMinZ  = sphereCfg.minZ or -20
    local sphereMaxZ  = sphereCfg.maxZ or  20

    inventoryCapacity = invCfg.capacity or 20
    
    boxes = {}
    for i = 1, boxCount do
        local sx = 0.5
        local sy = math.random() * (boxMaxH - boxMinH) + boxMinH
        local sz = 0.5
        
        local baseR = math.random(50, 90) / 100
        local baseG = math.random(50, 90) / 100
        local baseB = math.random(50, 90) / 100
        
        table.insert(boxes, {
            x = math.random(boxMinX, boxMaxX),
            y = 0,
            z = math.random(boxMinZ, boxMaxZ),
            r = math.random() * math.pi,
            sx = sx,
            sy = sy,
            sz = sz,
            color = {baseR, baseG, baseB}
        })
    end
    
    spheres = {}
    for i = 1, sphereCount do
        table.insert(spheres, {
            x = math.random(sphereMinX, sphereMaxX),
            y = 1,
            z = math.random(sphereMinZ, sphereMaxZ),
            collected = false,
            bobPhase = math.random() * math.pi * 2,
            glowPhase = math.random() * math.pi * 2
        })
    end
    
    inventory = 0
    mouseLocked = false
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)

    joystickX, joystickY = 0, 0
    joystickTouchId = nil
    mouseJoystickActive = false
    lookTouchId = nil
    mouseLookDragActive = false
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
    if not love.mouse.isDown(1) then
        if mouseJoystickActive then
            mouseJoystickActive = false
            joystickX, joystickY = 0, 0
        end
        if mouseLookDragActive then
            mouseLookDragActive = false
        end
    end

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

    if mouseLocked then
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
    end

    local joystickActive = mouseJoystickActive or (joystickTouchId ~= nil)
    if joystickActive then
        newX = newX + (forward[1] * joystickY + right[1] * joystickX) * moveSpeed
        newZ = newZ + (forward[3] * joystickY + right[3] * joystickX) * moveSpeed
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

    playerVelY = playerVelY + gravity * dt
    playerY = playerY + playerVelY * dt

    if playerY < playerHeight then
        playerY = playerHeight
        playerVelY = 0
    end
    
    g3d.camera.position[2] = playerY

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
            
            if distance < collectRadius and inventory < inventoryCapacity then
                sphere.collected = true
                inventory = inventory + 1
            end
        end
    end
end

function M.draw()
    love.graphics.clear(0.53, 0.71, 0.95)
    
    love.graphics.setColor(0.25, 0.75, 0.30)
    floorModel:draw()

    for _, box in ipairs(boxes) do
        love.graphics.setColor(box.color)
        boxModel:setTransform({box.x, box.y, box.z}, {0, box.r, 0}, {box.sx, box.sy, box.sz})
        boxModel:draw()
        
        love.graphics.setColor(0.08, 0.3, 0.12, 0.6)
        boxModel:setTransform(
            {box.x + 0.3, -0.98, box.z + 0.3},
            {0, 0, 0},
            {box.sx * 1.2, 0.01, box.sz * 1.2}
        )
        boxModel:draw()
    end
    
    for _, sphere in ipairs(spheres) do
        if not sphere.collected then
            local bobY = sphere.y + math.sin(sphere.bobPhase) * 0.15
            local glowIntensity = 0.7 + math.sin(sphere.glowPhase) * 0.3
            
            love.graphics.setColor(1, 0.3, 0.8, 0.2 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.35, 0.35, 0.35}
            )
            sphereModel:draw()
            
            love.graphics.setColor(1, 0.5, 0.9, 0.5 * glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.22, 0.22, 0.22}
            )
            sphereModel:draw()
            
            love.graphics.setColor(1, 0.7, 1, glowIntensity)
            sphereModel:setTransform(
                {sphere.x, bobY, sphere.z}, 
                {0, sphere.bobPhase, 0},
                {0.15, 0.15, 0.15}
            )
            sphereModel:draw()
        end
    end
    
    love.graphics.push("all")
    love.graphics.setDepthMode()
    
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 5, 5, 420, 95, 5, 5)
    
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
    love.graphics.print("LMB drag joystick: move | LMB drag elsewhere: look | Space / Jump button: jump", 10, 70)

    -- Draw joystick 
    local cx, cy, r = getJoystickCenter()
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.circle("fill", cx, cy, r)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("line", cx, cy, r)

    local thumbX = cx + joystickX * r
    local thumbY = cy - joystickY * r
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", thumbX, thumbY, r * 0.4)

    -- Draw jump button 
    local jx, jy, jHalf = getJumpButton()
    local jSize = jHalf * 2

    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", jx - jHalf, jy - jHalf, jSize, jSize, jHalf * 0.4, jHalf * 0.4)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", jx - jHalf, jy - jHalf, jSize, jSize, jHalf * 0.4, jHalf * 0.4)

    local font = love.graphics.getFont()
    local text = "Jump"
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.print(text, jx - font:getWidth(text)/2, jy - font:getHeight()/2)
        
    love.graphics.pop()
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- check jump first
        local jx, jy, jHalf = getJumpButton()
        if x >= jx - jHalf and x <= jx + jHalf and
           y >= jy - jHalf and y <= jy + jHalf then
            tryJump()
            return
        end

        -- then joystick vs look
        local cx, cy, r = getJoystickCenter()
        local dx = x - cx
        local dy = y - cy
        local dist2 = dx*dx + dy*dy

        if dist2 <= r*r then
            mouseJoystickActive = true
            updateJoystickFromPosition(x, y)
            mouseLookDragActive = false
        else
            mouseLookDragActive = true
            mouseJoystickActive = false
        end
    elseif button == 2 then
        mouseLocked = not mouseLocked
        love.mouse.setRelativeMode(mouseLocked)
        love.mouse.setVisible(not mouseLocked)
    end
end

function M.mousereleased(x, y, button)
    if button == 1 then
        mouseJoystickActive = false
        mouseLookDragActive = false
        joystickX, joystickY = 0, 0
    end
end

function M.mousemoved(x, y, dx, dy)
    local sensitivity = 0.003

    if mouseLocked then
        yaw = yaw + dx * sensitivity
        pitch = pitch - dy * sensitivity
    else
        if mouseLookDragActive then
            yaw = yaw + dx * sensitivity
            pitch = pitch - dy * sensitivity
        end
        if mouseJoystickActive then
            updateJoystickFromPosition(x, y)
        end
    end

    pitch = math.max(-math.pi/2 + 0.1, math.min(math.pi/2 - 0.1, pitch))
end

function M.keypressed(key)
    if key == "space" then
        tryJump()
    end

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

-- Touch input
function M.touchpressed(id, x, y, dx, dy, pressure)
    -- jump 
    local jx, jy, jHalf = getJumpButton()
    if x >= jx - jHalf and x <= jx + jHalf and
       y >= jy - jHalf and y <= jy + jHalf then
        tryJump()
        return
    end

    -- joystick / look
    local cx, cy, r = getJoystickCenter()
    local tdx = x - cx
    local tdy = y - cy
    local dist2 = tdx*tdx + tdy*tdy

    if joystickTouchId == nil and dist2 <= r*r then
        joystickTouchId = id
        updateJoystickFromPosition(x, y)
    elseif lookTouchId == nil then
        lookTouchId = id
    end
end

function M.touchmoved(id, x, y, dx, dy, pressure)
    if id == joystickTouchId then
        updateJoystickFromPosition(x, y)
    elseif id == lookTouchId then
        local sensitivity = 0.003
        yaw = yaw + dx * sensitivity
        pitch = pitch - dy * sensitivity
        pitch = math.max(-math.pi/2 + 0.1, math.min(math.pi/2 - 0.1, pitch))
    end
end

function M.touchreleased(id, x, y, dx, dy, pressure)
    if id == joystickTouchId then
        joystickTouchId = nil
        joystickX, joystickY = 0, 0
    elseif id == lookTouchId then
        lookTouchId = nil
    end
end

return M
