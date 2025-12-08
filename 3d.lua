-- 3d.lua - 3D Rotating Sudoku Cube with Theme Support

local module = {}
local theme  = require("theme")
local locale = require("locale")
-- load external dsl config
local config = require("config")
local Win    = require("win")   -- win check
local Save   = require("save")

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

-- Undo/redo system
local moveHistory = {} -- Array A: stores all moves made
local undoneMoves = {} -- Array B: stores undone moves

-- timer state
local elapsedTime    = 0     -- in seconds
local puzzleComplete = false

-- Pause state
local isPaused = false

-- Save/New game feedback
local saveMessage = ""
local saveMessageTimer = 0

-- Track if puzzle is initialized
local puzzleInitialized = false

-- Save/New buttons
local saveBtn = {x = 20,  y = 0, w = 60, h = 25}
local newBtn  = {x = 110, y = 0, w = 60, h = 25}

-- format elapsed time as M:SS or HH:MM:SS
local function formatElapsed(seconds)
    local total = math.floor(seconds)
    local hours = math.floor(total / 3600)
    local mins  = math.floor((total % 3600) / 60)
    local secs  = total % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, mins, secs)
    else
        return string.format("%d:%02d", mins, secs)
    end
end

-- Toggle pause state
local function togglePause()
    if puzzleComplete or not puzzleInitialized then return end
    isPaused = not isPaused
end

local faces = {
    {name = "front",  normal = {0, 0,  1}, offset = {0, 0,  cubeSize/2}},
    {name = "back",   normal = {0, 0, -1}, offset = {0, 0, -cubeSize/2}},
    {name = "right",  normal = {1, 0,  0}, offset = { cubeSize/2, 0, 0}},
    {name = "left",   normal = {-1,0,  0}, offset = {-cubeSize/2, 0, 0}},
    {name = "top",    normal = {0, 1,  0}, offset = {0,  cubeSize/2, 0}},
    {name = "bottom", normal = {0,-1,  0}, offset = {0, -cubeSize/2, 0}},
}

local function multiplyMatrixVector(mat, vec)
    local x = vec.x * mat[1]  + vec.y * mat[2]  + vec.z * mat[3]  + mat[4]
    local y = vec.x * mat[5]  + vec.y * mat[6]  + vec.z * mat[7]  + mat[8]
    local z = vec.x * mat[9]  + vec.y * mat[10] + vec.z * mat[11] + mat[12]
    local w = vec.x * mat[13] + vec.y * mat[14] + vec.z * mat[15] + mat[16]
    
    if w ~= 0 then 
      x, y, z = x / w, y / w, z / w
    end
    
    return {x = x, y = y, z = z, w = w}
end

local function getRotationMatrix(rx, ry)
    local cosX, sinX = math.cos(rx), math.sin(rx)
    local cosY, sinY = math.cos(ry), math.sin(ry)
    
    return {
        cosY,          sinX * sinY,  cosX * sinY,  0,
        0,             cosX,         -sinX,        0,
        -sinY,         sinX * cosY,  cosX * cosY,  0,
        0,             0,            0,            1
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
            return false, locale.text("error_row", value)
        end
    end
    
    for r = 1, 9 do
        if r ~= row and board[r][col].value == value then
            return false, locale.text("error_col", value)
        end
    end
    
    local boxStartRow = math.floor((row - 1) / 3) * 3 + 1
    local boxStartCol = math.floor((col - 1) / 3) * 3 + 1
    for r = boxStartRow, boxStartRow + 2 do
        for c = boxStartCol, boxStartCol + 2 do
            if (r ~= row or c ~= col) and board[r][c].value == value then
                return false, locale.text("error_box", value)
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
    local diffCfg = config.get3D(currentDifficulty)
    local holes = (diffCfg and diffCfg.holes) or 45

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

-- Export current game state
function module.exportState()
    if not puzzleInitialized then return nil end
    
    -- Convert boards to a saveable format
    local saveBoards = {}
    for faceIndex = 1, 6 do
        saveBoards[faceIndex] = {}
        for row = 1, 9 do
            saveBoards[faceIndex][row] = {}
            for col = 1, 9 do
                local cell = boards[faceIndex][row][col]
                saveBoards[faceIndex][row][col] = {
                    value = cell.value,
                    fixed = cell.fixed,
                    x = cell.x,
                    y = cell.y,
                    z = cell.z,
                    faceIndex = cell.faceIndex
                }
            end
        end
    end
    
    return {
        boards = saveBoards,
        moveHistory = moveHistory,
        undoneMoves = undoneMoves,
        elapsedTime = elapsedTime,
        puzzleComplete = puzzleComplete,
        rotation = {x = rotation.x, y = rotation.y},
        selectedCell = selectedCell
    }
end

-- Load saved game state
function module.loadSavedState(state)
    if not state then return false end
    if not state.boards then return false end
    
    -- Restore boards from saved state
    boards = {}
    for faceIndex = 1, 6 do
        boards[faceIndex] = {}
        for row = 1, 9 do
            boards[faceIndex][row] = {}
            for col = 1, 9 do
                local savedCell = state.boards[faceIndex][row][col]
                boards[faceIndex][row][col] = {
                    value = savedCell.value or 0,
                    fixed = savedCell.fixed or false,
                    x = savedCell.x or 0,
                    y = savedCell.y or 0,
                    z = savedCell.z or 0,
                    faceIndex = savedCell.faceIndex or faceIndex
                }
            end
        end
    end
    
    -- Restore other state
    moveHistory = state.moveHistory or {}
    undoneMoves = state.undoneMoves or {}
    elapsedTime = state.elapsedTime or 0
    puzzleComplete = state.puzzleComplete or false
    rotation = state.rotation or {x = 0.3, y = 0.3}
    selectedCell = state.selectedCell
    
    puzzleInitialized = true
    isPaused = false
    errorMessage = ""
    errorTimer = 0
    
    return true
end

local function autosave3D()
    Save.autosave("3d", currentDifficulty, module.exportState())
end

local function recordMove(faceIndex, row, col, oldValue, newValue)
    if isPaused or not puzzleInitialized then return end

    if #undoneMoves > 0 then
        undoneMoves = {}
    end

    local move = {
        faceIndex = faceIndex,
        row       = row,
        col       = col,
        oldValue  = oldValue,
        newValue  = newValue,
        timestamp = os.time()
    }

    table.insert(moveHistory, move)
    autosave3D()
end

local function undoLastMove()
    if isPaused or not puzzleInitialized then return end
    if #moveHistory == 0 then
        errorMessage = locale.text("hud_no_undo")
        errorTimer   = 2
        return
    end
    
    local move = table.remove(moveHistory)
    table.insert(undoneMoves, move)
    boards[move.faceIndex][move.row][move.col].value = move.oldValue

    errorMessage = ""
    errorTimer   = 0

    autosave3D()
    return true
end

local function redoLastMove()
    if isPaused or not puzzleInitialized then return end
    if #undoneMoves == 0 then
        errorMessage = locale.text("hud_no_redo")
        errorTimer   = 2
        return
    end
    
    local move = table.remove(undoneMoves)
    boards[move.faceIndex][move.row][move.col].value = move.newValue
    table.insert(moveHistory, move)

    errorMessage = ""
    errorTimer   = 0

    autosave3D()
    return true
end

local function initBoards()
    moveHistory    = {}
    undoneMoves    = {}
    elapsedTime    = 0
    puzzleComplete = false
    isPaused       = false
    selectedCell   = nil
    errorMessage   = ""
    errorTimer     = 0
    rotation       = {x = 0.3, y = 0.3}

    for faceIndex = 1, 6 do
        boards[faceIndex] = {}
        for row = 1, 9 do
            boards[faceIndex][row] = {}
            for col = 1, 9 do
                local x, y, z = getCellPosition(faceIndex, row, col)
                boards[faceIndex][row][col] = {
                    value     = 0,
                    fixed     = false,
                    x         = x,
                    y         = y,
                    z         = z,
                    faceIndex = faceIndex
                }
            end
        end
        fillBoard(boards[faceIndex])
        removeNumbers(boards[faceIndex])
    end

    puzzleInitialized = true
    autosave3D()
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
    rotation          = {x = 0.3, y = 0.3}
    mouseDown         = false
    selectedCell      = nil
    errorMessage      = ""
    errorTimer        = 0
    elapsedTime       = 0
    puzzleComplete    = false
    isPaused          = false
    puzzleInitialized = false
    saveMessage       = ""
    saveMessageTimer  = 0

    local saved = Save.load("3d", difficulty)
    if saved then
        if module.loadSavedState(saved) then
            return
        else
            -- If saved state is corrupted, delete it and generate new
            Save.delete("3d", difficulty)
        end
    end

    -- Generate new puzzle
    initBoards()
    
    -- Initial autosave
    Save.autosave("3d", difficulty, module.exportState())
end

function module.update(dt)
    if not puzzleInitialized then return end
    
    if saveMessageTimer > 0 then
        saveMessageTimer = saveMessageTimer - dt
        if saveMessageTimer <= 0 then
            saveMessage = ""
        end
    end
    
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
        if errorTimer <= 0 then
            errorMessage = ""
        end
    end

    if isPaused or puzzleComplete then return end

    elapsedTime = elapsedTime + dt

    if isCubeComplete() then
        puzzleComplete = true
        Win.setTime(elapsedTime)
        return "win"
    end
end

local function drawCell(cell, row, col, faceIndex, width, height)
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    local corners = {}
    local depth = 5
    local face  = faces[faceIndex]
    local nx, ny, nz = face.normal[1], face.normal[2], face.normal[3]
    local offsets = {}
    local halfCell = cellSize / 2
    
    if math.abs(nz) > 0.5 then
        offsets = {
            {-halfCell, -halfCell, 0}, { halfCell, -halfCell, 0},
            { halfCell,  halfCell, 0}, {-halfCell,  halfCell, 0},
        }
    elseif math.abs(nx) > 0.5 then
        offsets = {
            {0, -halfCell, -halfCell}, {0, -halfCell,  halfCell},
            {0,  halfCell,  halfCell}, {0,  halfCell, -halfCell},
        }
    else
        offsets = {
            {-halfCell, 0, -halfCell}, { halfCell, 0, -halfCell},
            { halfCell, 0,  halfCell}, {-halfCell, 0,  halfCell},
        }
    end
    
    for i, offset in ipairs(offsets) do
        local x, y, z = project3D(
            cell.x + offset[1],
            cell.y + offset[2],
            cell.z + offset[3],
            width, height
        )
        corners[i] = {x = x, y = y, z = z}
    end
    
    local mat       = getRotationMatrix(rotation.x, rotation.y)
    local rotNormal = multiplyMatrixVector(mat, {x = nx, y = ny, z = nz})
    if rotNormal.z >= 0 then return 0 end
    
    local brightness = math.abs(rotNormal.z) * 0.3 + 0.7
    love.graphics.setColor(
        t.cellFill[1] * brightness,
        t.cellFill[2] * brightness,
        t.cellFill[3] * brightness,
        1
    )
    
    if selectedCell and selectedCell.faceIndex == faceIndex and
       selectedCell.row == row and selectedCell.col == col then
        love.graphics.setColor(p.highlight)
    end
    
    if cell.fixed then
        love.graphics.setColor(
            t.cellFixed[1] * brightness,
            t.cellFixed[2] * brightness,
            t.cellFixed[3] * brightness,
            1
        )
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
        local cx, cy, _ = project3D(
            cell.x + nx * depth,
            cell.y + ny * depth,
            cell.z + nz * depth,
            width, height
        )
        love.graphics.setColor(t.text)
        local font = love.graphics.getFont()
        local text = tostring(cell.value)
        if not cell.fixed then
            love.graphics.print(text, cx - font:getWidth(text)/2,     cy - font:getHeight()/2)
            love.graphics.print(text, cx - font:getWidth(text)/2 + 1, cy - font:getHeight()/2)
        else
            love.graphics.print(text, cx - font:getWidth(text)/2, cy - font:getHeight()/2)
        end
    end
    return corners[1].z
end

function module.draw()
    if not puzzleInitialized then 
        -- Draw loading message
        local width, height = love.graphics.getDimensions()
        love.graphics.setColor(theme.getTheme().background)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(theme.getTheme().text)
        love.graphics.print(locale.text("loading_puzzle"), width/2 - 50, height/2)
        return
    end
    
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
    
    -- Only draw the cube if not paused
    if not isPaused then
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
        locale.applyFont("text")

        love.graphics.print(locale.text("hud_3d_instructions"), 70, 30)
        love.graphics.print(locale.text("hud_3d_esc"),          300, 650)

        if selectedCell then
            local faceName = faces[selectedCell.faceIndex].name
            love.graphics.print(
                locale.text("hud_3d_selected", faceName, selectedCell.row, selectedCell.col),
                70, 70
            )
        end
    end
    
    -- timer (top right)
    locale.applyFont("small")
    theme.setColor("text")
    local timeText   = locale.text("hud_time_label", formatElapsed(elapsedTime))
    local font       = love.graphics.getFont()
    local timerWidth = font:getWidth(timeText)
    love.graphics.print(timeText, width - timerWidth - 20, 10)
    
    -- Draw pause text (above undo/redo instructions)
    local pauseText = isPaused and locale.text("hud_pause_unpause") or locale.text("hud_pause_pause")
    local pauseWidth = font:getWidth(pauseText)
    love.graphics.print(pauseText, width - pauseWidth - 20, height - 80)
    
    -- Draw undo/redo instructions in lower right corner (right-aligned)
    local undoText  = locale.text("hud_2d_undo")
    local undoWidth = font:getWidth(undoText)
    love.graphics.print(undoText, width - undoWidth - 20, height - 40)
    
    -- Save / New buttons
    saveBtn.y = height - 40
    newBtn.y  = height - 40

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", saveBtn.x, saveBtn.y, saveBtn.w, saveBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf(locale.text("hud_save_button"), saveBtn.x, saveBtn.y + 5, saveBtn.w, "center")

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", newBtn.x, newBtn.y, newBtn.w, newBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf(locale.text("hud_new_button"), newBtn.x, newBtn.y + 5, newBtn.w, "center")
    
    -- Draw save message if active
    if saveMessage ~= "" then
        local messageX = width / 2
        local messageY = 60
        love.graphics.setColor(0.2, 0.7, 0.2, 1)
        local messageFont = love.graphics.getFont()
        local messageWidth = messageFont:getWidth(saveMessage)
        love.graphics.rectangle('fill', messageX - messageWidth/2 - 20, messageY - 15, messageWidth + 40, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(saveMessage, messageX - messageWidth/2, messageY - 5)
    end
    
    if errorMessage ~= "" then
        love.graphics.setColor(0.9, 0.1, 0.1, 1)
        local textWidth = font:getWidth(errorMessage)
        love.graphics.rectangle('fill', width/2 - textWidth/2 - 20, height - 120, textWidth + 40, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(errorMessage, width/2 - textWidth/2, height - 110)
    end
end

function module.mousepressed(x, y, button)
    if not puzzleInitialized or isPaused then return end
    
    if button == 1 then
        -- Save button clicked
        if x >= saveBtn.x and x <= saveBtn.x + saveBtn.w and
           y >= saveBtn.y and y <= saveBtn.y + saveBtn.h then
            local state = module.exportState()
            if state and Save.save("3d", currentDifficulty, state) then
                saveMessage = locale.text("hud_save_success")
                saveMessageTimer = 2  -- Show for 2 seconds
            else
                saveMessage = locale.text("hud_save_failed")
                saveMessageTimer = 2
            end
            return
        end

        -- New game button clicked
        if x >= newBtn.x and x <= newBtn.x + newBtn.w and
           y >= newBtn.y and y <= newBtn.y + newBtn.h then
            -- Delete the current save file
            Save.delete("3d", currentDifficulty)
            -- Reload the puzzle
            puzzleInitialized = false
            module.load(currentDifficulty)
            saveMessage = locale.text("hud_new_game")
            saveMessageTimer = 2  -- Show for 2 seconds
            return
        end
    end
    
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
    if not puzzleInitialized or isPaused then return end
    if mouseDown then
        rotation.y = rotation.y + dx * 0.01
        rotation.x = rotation.x + dy * 0.01
        rotation.x = math.max(-math.pi/2, math.min(math.pi/2, rotation.x))
    end
end

function module.keypressed(key)
    if not puzzleInitialized then return end
    
    -- Space to toggle pause
    if key == "space" then
        togglePause()
        return
    end
    
    -- Don't process other keys if paused
    if isPaused then return end
    
    if selectedCell then
        local board = boards[selectedCell.faceIndex]
        local cell  = board[selectedCell.row][selectedCell.col]
        if not cell.fixed then
            local num = tonumber(key)
            if num and num >= 1 and num <= 9 then
                local valid, errMsg = isValidPlacement(board, selectedCell.row, selectedCell.col, num)
                if valid then
                    recordMove(selectedCell.faceIndex, selectedCell.row, selectedCell.col, cell.value, num)
                    cell.value   = num
                    errorMessage = ""
                    errorTimer   = 0
                else
                    errorMessage = errMsg
                    errorTimer   = 3
                end
            elseif key == "backspace" or key == "delete" or key == "0" then
                recordMove(selectedCell.faceIndex, selectedCell.row, selectedCell.col, cell.value, 0)
                cell.value   = 0
                errorMessage = ""
                errorTimer   = 0
            end
        end
    end
    
    -- Undo/redo key handling
    if key == "u" then
        undoLastMove()
    elseif key == "r" then
        redoLastMove()
    end
    
    -- Rotation controls
    if key == "left"  then rotation.y = rotation.y - 0.1 end
    if key == "right" then rotation.y = rotation.y + 0.1 end
    if key == "up"    then rotation.x = rotation.x - 0.1 end
    if key == "down"  then rotation.x = rotation.x + 0.1 end
end

module._test = {
    getBoards        = function() return boards end,
    initBoardsForTest = function(diff)
        currentDifficulty = diff or "medium"
        initBoards()
    end,
    isValidPlacement = isValidPlacement,
    isBoardComplete  = isBoardComplete,
    isCubeComplete   = isCubeComplete,
    undoLastMove     = undoLastMove,
    redoLastMove     = redoLastMove,
    recordMove       = recordMove,
    getMoveHistory   = function() return moveHistory end,
    getUndoneMoves   = function() return undoneMoves end,
    togglePause      = togglePause,
    isPaused         = function() return isPaused end,
    exportState      = module.exportState,
    loadSavedState   = module.loadSavedState,
}

return module
