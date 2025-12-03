-- modified from groverbuger for g3d
-- september 2021
-- MIT license

local g3d = require "g3d"

-- Load textures
local benchBaseColor = love.graphics.newImage("assets/textures/bench_basecolor.png")
local benchNormal = love.graphics.newImage("assets/textures/bench_normal.png")
local benchRoughness = love.graphics.newImage("assets/textures/bench_roughness.png")

-- Create a custom shader that uses multiple textures
local multiTextureShader = love.graphics.newShader([[
    uniform Image normalMap;
    uniform Image roughnessMap;
    
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
        vec4 baseColor = Texel(texture, tc);
        vec3 normal = Texel(normalMap, tc).rgb;
        float roughness = Texel(roughnessMap, tc).r;
        
        // Basic lighting calculation using normal and roughness
        return baseColor * color;
    }
]])

-- Create green ground using cube
local ground = g3d.newModel("assets/cube.obj", nil, {0, -0.5, 0}, {0, 0, 0}, {50, 0.1, 50})

-- Add leaves on top of ground
local leaves = g3d.newModel("assets/leaves.obj", "assets/textures/phong2_baseColor.png", {-5, 0, -5}, {0, 0, 0}, 1)
local leaves2 = g3d.newModel("assets/leaves.obj", "assets/textures/phong2_baseColor.png", {5, 0, -8}, {0, math.pi/3, 0}, 1)
local leaves3 = g3d.newModel("assets/leaves.obj", "assets/textures/phong2_baseColor.png", {-3, 0, 3}, {0, math.pi/2, 0}, 1)

-- Keep the original earth sphere
local earth = g3d.newModel("assets/sphere.obj", "assets/textures/earth.png", {4, 1, 0})

-- Create trial structure
local trial = g3d.newModel("assets/trial.obj", nil, {0, 0, -15}, {0, 0, 0}, 3)

-- Create upright bench
local bench = g3d.newModel("assets/bench.obj", benchBaseColor, {-8, 0, -10}, {0, 0, 0}, 1)

-- Create spheres scattered around
local spheres = {}
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {-5, 0.5, -8}, {0, 0, 0}, 0.5))
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {5, 0.5, -8}, {0, 0, 0}, 0.5))
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {-3, 0.5, -5}, {0, 0, 0}, 0.4))
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {3, 0.7, -12}, {0, 0, 0}, 0.7))
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {8, 0.5, -5}, {0, 0, 0}, 0.5))
table.insert(spheres, g3d.newModel("assets/sphere.obj", "assets/textures/moon.png", {-10, 0.6, -15}, {0, 0, 0}, 0.6))

-- Optional: Add a skybox/background
local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)

local timer = 0
local alertMessage = ""
local alertTimer = 0
local selectedObject = nil
local mouseLocked = false

-- Define interactable objects
local interactables = {
    {model = nil, name = "Trial Structure", position = {0, 0, -15}},
    {model = nil, name = "Bench", position = {-8, 0, -10}},
    {model = nil, name = "Earth", position = {4, 1, 0}},
}

function love.load()
    -- Set camera starting position
    g3d.camera.position = {0, 2, 5}
    g3d.camera.target = {0, 2, -5}
    g3d.camera.up = {0, 1, 0}
    
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
    
    -- Assign models to interactables
    interactables[1].model = trial
    interactables[2].model = bench
    interactables[3].model = earth
end

function love.update(dt)
    timer = timer + dt
    
    -- Update alert timer
    if alertTimer > 0 then
        alertTimer = alertTimer - dt
        if alertTimer <= 0 then
            alertMessage = ""
        end
    end
    
    -- Camera movement only when mouse is locked
    if mouseLocked then
        g3d.camera.firstPersonMovement(dt, 5)
    end
    
    -- Check which object the player is looking at
    selectedObject = nil
    local minDistance = math.huge
    local interactionRange = 15
    
    for _, obj in ipairs(interactables) do
        local dx = obj.position[1] - g3d.camera.position[1]
        local dy = obj.position[2] - g3d.camera.position[2]
        local dz = obj.position[3] - g3d.camera.position[3]
        local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
        
        if distance < interactionRange and distance < minDistance then
            local dirZ = g3d.camera.target[3] - g3d.camera.position[3]
            if (dz * dirZ) > 0 then
                minDistance = distance
                selectedObject = obj
            end
        end
    end
    
    if love.keyboard.isDown "escape" then
        love.event.push "quit"
    end
end

function love.draw()
    -- Draw green ground (tint it green)
    love.graphics.setColor(0.2, 0.6, 0.2)
    ground:draw()
    love.graphics.setColor(1, 1, 1)
    
    -- Draw leaves on ground
    leaves:draw()
    leaves2:draw()
    leaves3:draw()
    
    -- Draw trial structure
    trial:draw()
    
    -- Draw earth sphere
    earth:draw()
    
    -- Draw bench with shader
    love.graphics.setShader(multiTextureShader)
    multiTextureShader:send("normalMap", benchNormal)
    multiTextureShader:send("roughnessMap", benchRoughness)
    bench:draw()
    love.graphics.setShader()
    
    -- Draw spheres
    for _, sphere in ipairs(spheres) do
        sphere:draw()
    end
    
    -- Draw background/skybox
    background:draw()
    
    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Right-click to toggle mouse look | WASD to move", 10, 10)
    love.graphics.print("Mouse locked: " .. tostring(mouseLocked), 10, 30)
    love.graphics.print("Camera position: " .. 
        string.format("%.1f, %.1f, %.1f", 
        g3d.camera.position[1], 
        g3d.camera.position[2], 
        g3d.camera.position[3]), 10, 50)
    
    -- Show which object is selected
    if selectedObject then
        love.graphics.print("Looking at: " .. selectedObject.name .. " (Press E to interact)", 10, 70)
    end
    
    -- Display alert message
    if alertMessage ~= "" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(alertMessage, 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
    end
end

-- Handle interaction
function love.keypressed(key)
    if key == "e" and selectedObject then
        -- Add custom behavior for each object
        if selectedObject.name == "Bench" then
            alertMessage = "You sat on the bench. It's quite comfortable!"
        elseif selectedObject.name == "Earth" then
            alertMessage = "You touched the Earth sphere. It spins gently."
        elseif selectedObject.name == "Trial Structure" then
            alertMessage = "The trial structure is mysterious and ancient."
        end
        
        alertTimer = 3
    end
end

function love.mousepressed(x, y, button)
    if button == 2 then -- Right click
        mouseLocked = not mouseLocked
        love.mouse.setRelativeMode(mouseLocked)
        love.mouse.setVisible(not mouseLocked)
    end
end

function love.mousemoved(x, y, dx, dy)
    if mouseLocked then
        g3d.camera.firstPersonLook(dx, dy)
    end
end