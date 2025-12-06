-- 3d.lua - 3D Rotating Sudoku Cube with Theme Support

local module = {}
local theme = require("theme")

local boards = {}
local rotation = {x = 0.3, y = 0.3}
local mouseDown = false
local lastMouseX, lastMouseY = 0, 0
local selectedCell = nil
local cellSize = 60
local errorMessage = ""
local errorTimer = 0
local cubeSize = 540
local currentDifficulty = "medium"

local faces = {
    {name = "front", normal = {0, 0, 1}, offset = {0, 0, cubeSize/2}},
    {name = "back", normal = {0, 0, -1}, offset = {0, 0, -cubeSize/2}},
    {name = "right", normal = {1, 0, 0}, offset = {cubeSize/2, 0, 0}},
    {name = "left", normal = {-1, 0, 0}, offset = {-cubeSize/2, 0, 0}},
    {name = "top", normal = {0, 1, 0}, offset = {0, cubeSize/2, 0}},
    {name = "bottom", normal = {0, -1, 0}, offset = {0, -cubeSize/2, 0}},
}

local function multiplyMatrixVector(mat, vec)
    local x = vec.x * mat[1] + vec.y * mat[2] + vec.z * mat[3] + mat[4]
    local y = vec.x * mat[5] + vec.y * mat[6] + vec.z * mat[7] + mat[8]
    local z = vec.x * mat[9] + vec.y * mat[10] + vec.z * mat[11] + mat[12]
    local w = vec.x * mat[13] + vec.y * mat[14] + vec.z * mat[15] + mat[16]
    
    if w ~= 0 then 
      x, y, z = x/w, y/w, z/w 
    end
    
    return {x = x, y = y, z = z, w = w}
end

local function getRotationMatrix(rx, ry)
    local cosX, sinX = math.cos(rx), math.sin(rx)
    local cosY, sinY = math.cos(ry), math.sin(ry)
    
    return {
        cosY, sinX * sinY, cosX * sinY, 0,
        0, cosX, -sinX, 0,
        -sinY, sinX * cosY, cosX * cosY, 0,
        0, 0, 0, 1
    }
end

local function project3D(x, y, z, width, height)
    local fov = 500
    local distance = 1200
    local mat = getRotationMatrix(rotation.x, rotation.y)
    local rotated = multiplyMatrixVector(mat, {x = x, y = y, z = z})
    
    rotated.z = rotated.z + distance
    
    local factor = fov / rotated.z
    local screenX = rotated.x * factor + width / 2
    local screenY = rotated.y * factor + height / 2
    return screenX, screenY, rotated.z
end

local function getCellPosition(faceIndex, row, col)
    local localX = (col - 5) * cellSize
    local localY = (row - 5) * cellSize
    local x, y, z
    local off = faces[faceIndex].offset
    
    if faceIndex == 1 then
        x = localX; y = localY; z = off[3]
    elseif faceIndex == 2 then
        x = localX; y = localY; z = off[3]
    elseif faceIndex == 3 then
        x = off[1]; y = localY; z = localX
    elseif faceIndex == 4 then
        x = off[1]; y = localY; z = localX
    elseif faceIndex == 5 then
        x = localX; y = off[2]; z = localY
    elseif faceIndex == 6 then
        x = localX; y = off[2]; z = localY
    end
    
    return x, y, z
end

local function isValidPlacement(board, row, col, value)
    if value == 0 then return true end
    
    for c = 1, 9 do
        if c ~= col and board[row][c].value == value then
            return false, "Number " .. value .. " already exists in this row!"
        end
    end
    
    for r = 1, 9 do
        if r ~= row and board[r][col].value == value then
            return false, "Number " .. value .. " already exists in this column!"
        end
    end
    
    local boxStartRow = math.floor((row - 1) / 3) * 3 + 1
    local boxStartCol = math.floor((col - 1) / 3) * 3 + 1
    for r = boxStartRow, boxStartRow + 2 do
        for c = boxStartCol, boxStartCol + 2 do
            if (r ~= row or c ~= col) and board[r][c].value == value then
                return false, "Number " .. value .. " already exists in this 3x3 box!"
            end
        end
    end
    return true
end

local function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function fillBoard(board)
    for row = 1, 9 do
        for col = 1, 9 do
            if board[row][col].value == 0 then
                local nums = {1,2,3,4,5,6,7,8,9}
                shuffle(nums)
                for _, n in ipairs(nums) do
                    if isValidPlacement(board, row, col, n) then
                        board[row][col].value = n
                        if fillBoard(board) then return true end
                        board[row][col].value = 0
                    end
                end
                return false
            end
        end
    end
    return true
end

local function removeNumbers(board)
    local holes = 45
    if currentDifficulty == "testing" then holes = 2 end
    if currentDifficulty == "easy" then holes = 25 end
    if currentDifficulty == "medium" then holes = 45 end
    if currentDifficulty == "hard" then holes = 60 end

    local removed = 0
    while removed < holes do
        local r = math.random(1, 9)
        local c = math.random(1, 9)
        if board[r][c].value ~= 0 then
            board[r][c].value = 0
            board[r][c].fixed = false
            removed = removed + 1
        end
    end

    for r = 1, 9 do
        for c = 1, 9 do
            if board[r][c].value ~= 0 then
                board[r][c].fixed = true
            end
        end
    end
end

local function initBoards()
    for faceIndex = 1, 6 do
        boards[faceIndex] = {}
        for row = 1, 9 do
            boards[faceIndex][row] = {}
            for col = 1, 9 do
                local x, y, z = getCellPosition(faceIndex, row, col)
                boards[faceIndex][row][col] = {
                    value = 0,
                    fixed = false,
                    x = x, y = y, z = z,
                    faceIndex = faceIndex
                }
            end
        end
        fillBoard(boards[faceIndex])
        removeNumbers(boards[faceIndex])
    end
end

local function isBoardComplete(board)
    for r = 1, 9 do
        for c = 1, 9 do
            local v = board[r][c].value
            if v == 0 then return false end
            local ok = isValidPlacement(board, r, c, v)
            if not ok then return false end
        end
    end
    return true
end

local function isCubeComplete()
    for face = 1, 6 do
        if not isBoardComplete(boards[face]) then
            return false
        end
    end
    return true
end

function module.load(difficulty)
    currentDifficulty = difficulty or "medium"
    rotation = {x = 0.3, y = 0.3}
    mouseDown = false
    selectedCell = nil
    errorMessage = ""
    errorTimer = 0
    initBoards()
end

function module.update(dt)
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
        if errorTimer <= 0 then
            errorMessage = ""
        end
    end

    if isCubeComplete() then
        return "win"
    end
end

local function drawCell(cell, row, col, faceIndex, width, height)
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    local corners = {}
    local depth = 5
    local face = faces[faceIndex]
    local nx, ny, nz = face.normal[1], face.normal[2], face.normal[3]
    local offsets = {}
    local halfCell = cellSize / 2
    
    if math.abs(nz) > 0.5 then
        offsets = {
            {-halfCell, -halfCell, 0}, {halfCell, -halfCell, 0},
            {halfCell, halfCell, 0}, {-halfCell, halfCell, 0},
        }
    elseif math.abs(nx) > 0.5 then
        offsets = {
            {0, -halfCell, -halfCell}, {0, -halfCell, halfCell},
            {0, halfCell, halfCell}, {0, halfCell, -halfCell},
        }
    else
        offsets = {
            {-halfCell, 0, -halfCell}, {halfCell, 0, -halfCell},
            {halfCell, 0, halfCell}, {-halfCell, 0, halfCell},
        }
    end
    
    for i, offset in ipairs(offsets) do
        local x, y, z = project3D(cell.x + offset[1],
                                   cell.y + offset[2],
                                   cell.z + offset[3],
                                   width, height)
        corners[i] = {x = x, y = y, z = z}
    end
    
    local mat = getRotationMatrix(rotation.x, rotation.y)
    local rotNormal = multiplyMatrixVector(mat, {x = nx, y = ny, z = nz})
    if rotNormal.z >= 0 then return 0 end
    
    local brightness = math.abs(rotNormal.z) * 0.3 + 0.7
    love.graphics.setColor(t.cellFill[1] * brightness, t.cellFill[2] * brightness, t.cellFill[3] * brightness, 1)
    
    if selectedCell and selectedCell.faceIndex == faceIndex and
       selectedCell.row == row and selectedCell.col == col then
        love.graphics.setColor(p.highlight)
    end
    
    if cell.fixed then
        love.graphics.setColor(t.cellFixed[1] * brightness, t.cellFixed[2] * brightness, t.cellFixed[3] * brightness, 1)
    end
    
    love.graphics.polygon('fill',
        corners[1].x, corners[1].y,
        corners[2].x, corners[2].y,
        corners[3].x, corners[3].y,
        corners[4].x, corners[4].y
    )
    
    love.graphics.setColor(t.cellBorder)
    love.graphics.setLineWidth(1)
    love.graphics.line(corners[1].x, corners[1].y, corners[2].x, corners[2].y)
    love.graphics.line(corners[2].x, corners[2].y, corners[3].x, corners[3].y)
    love.graphics.line(corners[3].x, corners[3].y, corners[4].x, corners[4].y)
    love.graphics.line(corners[4].x, corners[4].y, corners[1].x, corners[1].y)
    
    love.graphics.setColor(t.gridLine)
    love.graphics.setLineWidth(3)
    if col == 3 or col == 6 then
        love.graphics.line(corners[2].x, corners[2].y, corners[3].x, corners[3].y)
    end
    if row == 3 or row == 6 then
        love.graphics.line(corners[3].x, corners[3].y, corners[4].x, corners[4].y)
    end
    if col == 1 then
        love.graphics.line(corners[4].x, corners[4].y, corners[1].x, corners[1].y)
    end
    if row == 1 then
        love.graphics.line(corners[1].x, corners[1].y, corners[2].x, corners[2].y)
    end
    if col == 9 then
        love.graphics.line(corners[2].x, corners[2].y, corners[3].x, corners[3].y)
    end
    if row == 9 then
        love.graphics.line(corners[3].x, corners[3].y, corners[4].x, corners[4].y)
    end
    
    if cell.value > 0 then
        local cx, cy, _ = project3D(cell.x + nx * depth, cell.y + ny * depth,
                                     cell.z + nz * depth, width, height)
        love.graphics.setColor(t.text)
        local font = love.graphics.getFont()
        local text = tostring(cell.value)
        if not cell.fixed then
            love.graphics.print(text, cx - font:getWidth(text)/2, cy - font:getHeight()/2)
            love.graphics.print(text, cx - font:getWidth(text)/2 + 1, cy - font:getHeight()/2)
        else
            love.graphics.print(text, cx - font:getWidth(text)/2, cy - font:getHeight()/2)
        end
    end
    return corners[1].z
end

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    local width, height = love.graphics.getDimensions()
    
    -- Use palette-tinted background based on theme mode
    if theme.currentMode == "light" then
        -- Light mode: bright, heavily tinted white
        local tint = 0.15
        love.graphics.setColor(
            p.primary[1] * tint + (1 - tint),
            p.primary[2] * tint + (1 - tint),
            p.primary[3] * tint + (1 - tint)
        )
    else
        -- Dark mode: dark, subtly tinted black
        local tint = 0.3
        love.graphics.setColor(
            p.primary[1] * tint,
            p.primary[2] * tint,
            p.primary[3] * tint
        )
    end
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    local cellsWithDepth = {}
    for faceIndex = 1, 6 do
        for row = 1, 9 do
            for col = 1, 9 do
                local cell = boards[faceIndex][row][col]
                local _, _, z = project3D(cell.x, cell.y, cell.z, width, height)
                table.insert(cellsWithDepth, {
                    cell = cell, row = row, col = col,
                    z = z, faceIndex = faceIndex
                })
            end
        end
    end
    table.sort(cellsWithDepth, function(a, b) return a.z > b.z end)
    
    for _, item in ipairs(cellsWithDepth) do
        drawCell(item.cell, item.row, item.col, item.faceIndex, width, height)
    end
    
    theme.setColor("text")
    local mainFont = love.graphics.newFont(20)
    love.graphics.setFont(mainFont)

    love.graphics.print("Drag to rotate | Click cells | Number keys to fill | Arrow keys for fine rotation", 70, 30)
    love.graphics.print("Press ESC to return to menu", 300, 650)

    if selectedCell then
        love.graphics.print("Selected: Face " .. faces[selectedCell.faceIndex].name ..
                          " [" .. selectedCell.row .. "," .. selectedCell.col .. "]", 10, 10)
    end
    
    if errorMessage ~= "" then
        love.graphics.setColor(0.9, 0.1, 0.1, 1)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(errorMessage)
        love.graphics.rectangle('fill', width/2 - textWidth/2 - 20, height - 80, textWidth + 40, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(errorMessage, width/2 - textWidth/2, height - 70)
    end
end

function module.mousepressed(x, y, button)
    if button == 1 then
        mouseDown = true
        lastMouseX, lastMouseY = x, y
        local width, height = love.graphics.getDimensions()
        local minDist = math.huge
        local closest = nil
        for faceIndex = 1, 6 do
            for row = 1, 9 do
                for col = 1, 9 do
                    local cell = boards[faceIndex][row][col]
                    local cx, cy, cz = project3D(cell.x, cell.y, cell.z, width, height)
                    local face = faces[faceIndex]
                    local nx, ny, nz = face.normal[1], face.normal[2], face.normal[3]
                    local mat = getRotationMatrix(rotation.x, rotation.y)
                    local rotNormal = multiplyMatrixVector(mat, {x = nx, y = ny, z = nz})
                    if rotNormal.z < 0 then
                        local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
                        if dist < cellSize/2 and cz < minDist then
                            minDist = cz
                            closest = {row = row, col = col, faceIndex = faceIndex}
                        end
                    end
                end
            end
        end
        selectedCell = closest
    end
end

function module.mousereleased(x, y, button)
    if button == 1 then mouseDown = false end
end

function module.mousemoved(x, y, dx, dy)
    if mouseDown then
        rotation.y = rotation.y + dx * 0.01
        rotation.x = rotation.x + dy * 0.01
        rotation.x = math.max(-math.pi/2, math.min(math.pi/2, rotation.x))
    end
end

function module.keypressed(key)
    if selectedCell then
        local board = boards[selectedCell.faceIndex]
        local cell = board[selectedCell.row][selectedCell.col]
        if not cell.fixed then
            local num = tonumber(key)
            if num and num >= 1 and num <= 9 then
                local valid, errMsg = isValidPlacement(board, selectedCell.row, selectedCell.col, num)
                if valid then
                    cell.value = num
                    errorMessage = ""
                    errorTimer = 0
                else
                    errorMessage = errMsg
                    errorTimer = 3
                end
            elseif key == "backspace" or key == "delete" or key == "0" then
                cell.value = 0
                errorMessage = ""
                errorTimer = 0
            end
        end
    end
    if key == "left" then rotation.y = rotation.y - 0.1 end
    if key == "right" then rotation.y = rotation.y + 0.1 end
    if key == "up" then rotation.x = rotation.x - 0.1 end
    if key == "down" then rotation.x = rotation.x + 0.1 end
end

module._test = {
    getBoards = function() return boards end,
    initBoardsForTest = function(diff)
        currentDifficulty = diff or "medium"
        initBoards()
    end,
    isValidPlacement = isValidPlacement,
    isBoardComplete = isBoardComplete,
    isCubeComplete = isCubeComplete,
}

return module