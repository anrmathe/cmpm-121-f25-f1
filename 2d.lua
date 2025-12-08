local module = {}
local theme  = require("theme")
local locale = require("locale")
local Save   = require("save")
local config = require("config")
local Win    = require("win")   -- win check 

local cellSize     = 50
local selectedRow  = nil
local selectedCol  = nil
local paletteY     = 0
local grid         = {}
local fixed        = {}
local errorMessage = ""
local errorTimer   = 0

-- center offsets
local offsetX = 0
local offsetY = 0

-- Undo/Redo system
local moveHistory = {} -- Array A
local undoneMoves = {} -- Array B

local saveBtn = {x = 20,  y = 0, w = 60, h = 25}
local newBtn  = {x = 110, y = 0, w = 60, h = 25}

-- timer state
local elapsedTime    = 0    -- in seconds
local puzzleComplete = false

-- New: Save/New game feedback
local saveMessage = ""
local saveMessageTimer = 0

-- Track if puzzle is initialized
local puzzleInitialized = false

-- Pause state
local isPaused = false

-- format elapsed time as 0:00 or 00:00:00
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
    if not puzzleInitialized or puzzleComplete then return end
    isPaused = not isPaused
end

-- Initialize empty grid and fixed arrays
local function initEmptyGrid()
    grid = {}
    fixed = {}
    for i = 1, 9 do
        grid[i] = {}
        fixed[i] = {}
        for j = 1, 9 do
            grid[i][j] = 0
            fixed[i][j] = false
        end
    end
end

-- Store a move in history
local function storeMove(row, col, oldValue, newValue)
    if not puzzleInitialized or isPaused then return end
    if #undoneMoves > 0 then
        undoneMoves = {}
    end
    
    if oldValue ~= newValue then
        table.insert(moveHistory, {
            row = row,
            col = col,
            oldValue = oldValue,
            newValue = newValue
        })
    end

    Save.autosave("2d", module.currentDifficulty, module.exportState())
end

-- Undo last move
local function undo()
    if not puzzleInitialized or isPaused then return false end
    if #moveHistory > 0 then
        local lastMove = table.remove(moveHistory)
        local row, col, oldValue = lastMove.row, lastMove.col, lastMove.oldValue
        
        table.insert(undoneMoves, lastMove)
        
        grid[row][col] = oldValue
        
        errorMessage = ""
        errorTimer = 0

        Save.autosave("2d", module.currentDifficulty, module.exportState())
        return true
    end
    return false
end

-- Redo last undone move
local function redo()
    if not puzzleInitialized or isPaused then return false end
    if #undoneMoves > 0 then
        local lastUndone = table.remove(undoneMoves)
        local row, col, newValue = lastUndone.row, lastUndone.col, lastUndone.newValue
        
        table.insert(moveHistory, lastUndone)
        grid[row][col] = newValue
        
        errorMessage = ""
        errorTimer = 0

        Save.autosave("2d", module.currentDifficulty, module.exportState())
        return true
    end
    return false
end

function isSafe(grid, row, col, num)
    if not grid or not grid[row] then return false end
    for c = 1, 9 do
        if c ~= col and grid[row][c] == num then return false end
    end
    for r = 1, 9 do
        if r ~= row and grid[r][col] == num then return false end
    end

    local boxR = math.floor((row-1)/3)*3 + 1
    local boxC = math.floor((col-1)/3)*3 + 1

    for r = boxR, boxR+2 do
        for c = boxC, boxC+2 do
            if (r ~= row or c ~= col) and grid[r][c] == num then
                return false
            end
        end
    end

    return true
end

function solveSudoku(grid, row, col)
    if not grid then return false end
    if row == 10 then return true end
    if col == 10 then return solveSudoku(grid, row+1, 1) end

    if grid[row][col] ~= 0 then
        return solveSudoku(grid, row, col+1)
    end

    local nums = {1,2,3,4,5,6,7,8,9}
    for i = 9, 2, -1 do
        local j = love.math.random(1, i)
        nums[i], nums[j] = nums[j], nums[i]
    end

    for i = 1, 9 do
        if isSafe(grid, row, col, nums[i]) then
            grid[row][col] = nums[i]
            if solveSudoku(grid, row, col+1) then return true end
            grid[row][col] = 0
        end
    end
    return false
end

function makePuzzle(grid, holes)
    if not grid then return end
    local removed = 0
    while removed < holes do
        local r = love.math.random(1,9)
        local c = love.math.random(1,9)
        if grid[r][c] ~= 0 then
            grid[r][c] = 0
            removed = removed + 1
        end
    end
end

local function isValidPlacement(row, col, value)
    if not puzzleInitialized or not grid or isPaused then return true end
    if value == 0 then return true end
    
    for c = 1, 9 do
        if c ~= col and grid[row][c] == value then
            return false, locale.text("error_row", value)
        end
    end
    for r = 1, 9 do
        if r ~= row and grid[r][col] == value then
            return false, locale.text("error_col", value)
        end
    end
    
    local boxRow = math.floor((row - 1) / 3) * 3
    local boxCol = math.floor((col - 1) / 3) * 3
    
    for r = boxRow + 1, boxRow + 3 do
        for c = boxCol + 1, boxCol + 3 do
            if (r ~= row or c ~= col) and grid[r][c] == value then
                return false, locale.text("error_box", value)
            end
        end
    end
    return true
end

local function isPuzzleComplete()
    if not puzzleInitialized or not grid or isPaused then return false end
    for i = 1, 9 do
        for j = 1, 9 do
            if grid[i][j] == 0 or not isSafe(grid, i, j, grid[i][j]) then
                return false
            end
        end
    end
    return true
end

function module.exportState()
    if not puzzleInitialized then return nil end
    return {
        grid          = grid,
        fixed         = fixed,
        moveHistory   = moveHistory,
        undoneMoves   = undoneMoves,
        elapsedTime   = elapsedTime,
        puzzleComplete = puzzleComplete,
    }
end

function module.loadSavedState(state)
    if not state then return false end
    if not state.grid or not state.fixed then
        return false
    end
    
    -- Ensure grid is properly structured
    grid = {}
    for i = 1, 9 do
        grid[i] = state.grid[i] or {}
        for j = 1, 9 do
            grid[i][j] = state.grid[i][j] or 0
        end
    end
    
    -- Ensure fixed is properly structured
    fixed = {}
    for i = 1, 9 do
        fixed[i] = state.fixed[i] or {}
        for j = 1, 9 do
            fixed[i][j] = state.fixed[i][j] or false
        end
    end
    
    moveHistory    = state.moveHistory or {}
    undoneMoves    = state.undoneMoves or {}
    elapsedTime    = state.elapsedTime or 0
    puzzleComplete = state.puzzleComplete or false
    puzzleInitialized = true
    isPaused = false
    return true
end

function module.load(difficulty)
    module.currentDifficulty = difficulty
    cellSize = 40

    selectedRow = nil
    selectedCol = nil
    errorMessage = ""
    errorTimer = 0
    elapsedTime = 0
    puzzleComplete = false
    saveMessage = ""
    saveMessageTimer = 0
    puzzleInitialized = false
    isPaused = false

    -- First, delete any corrupted save file for easy mode
    if difficulty == "easy" then
        Save.delete("2d", "easy")
    end
    
    local saved = Save.load("2d", difficulty)
    if saved then
        if module.loadSavedState(saved) then
            local boardSize = cellSize * 9
            offsetX = (love.graphics.getWidth()  - boardSize) / 2
            offsetY = (love.graphics.getHeight() - boardSize - 100) / 2
            paletteY = offsetY + boardSize + 20
            return
        else
            -- If saved state is corrupted, delete it and generate new
            Save.delete("2d", difficulty)
        end
    end

    -- Generate new puzzle
    moveHistory = {}
    undoneMoves = {}
    
    initEmptyGrid()

    -- Generate a full solved Sudoku
    if not solveSudoku(grid, 1, 1) then
        -- If solving fails, create a simple valid grid
        for i = 1, 9 do
            for j = 1, 9 do
                grid[i][j] = ((i-1)*3 + math.floor((i-1)/3) + (j-1)) % 9 + 1
            end
        end
    end

    local diffCfg = config.get2D(difficulty)
    local holes   = (diffCfg and diffCfg.holes) or 45

    makePuzzle(grid, holes)

    for i = 1, 9 do
        for j = 1, 9 do
            fixed[i][j] = (grid[i][j] ~= 0)
        end
    end

    local boardSize = cellSize * 9
    offsetX = (love.graphics.getWidth()  - boardSize) / 2
    offsetY = (love.graphics.getHeight() - boardSize - 100) / 2

    paletteY = offsetY + boardSize + 20
    
    puzzleInitialized = true

    Save.autosave("2d", difficulty, module.exportState())
end

function module.update(dt)
    if not puzzleInitialized or isPaused or puzzleComplete then return end
    
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
        if errorTimer <= 0 then
            errorMessage = ""
        end
    end
    
    -- Update save message timer
    if saveMessageTimer > 0 then
        saveMessageTimer = saveMessageTimer - dt
        if saveMessageTimer <= 0 then
            saveMessage = ""
        end
    end

    -- timer only while puzzle is not finished
    if not puzzleComplete then
        elapsedTime = elapsedTime + dt

        if isPuzzleComplete() then
            puzzleComplete = true
            Win.setTime(elapsedTime)  -- hand final time to win screen
            return "win"
        end
    end
end

function module.draw()
    if not puzzleInitialized then 
        -- Draw loading message
        local width, height = love.graphics.getDimensions()
        love.graphics.setColor(theme.getTheme().background)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(theme.getTheme().text)
        love.graphics.print("Loading puzzle...", width/2 - 50, height/2)
        return
    end
    
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Don't draw the puzzle if paused
    if not isPaused then
        for i = 1, 9 do
            for j = 1, 9 do
                local x = offsetX + (j-1)*cellSize
                local y = offsetY + (i-1)*cellSize

                if fixed[i][j] then
                    love.graphics.setColor(t.cellFixed)
                else
                    love.graphics.setColor(t.cellFill)
                end
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                
                love.graphics.setColor(t.cellBorder)
                love.graphics.rectangle("line", x, y, cellSize, cellSize)

                if grid[i][j] ~= 0 then
                    if fixed[i][j] then
                        love.graphics.setColor(t.textFixed)
                    else
                        love.graphics.setColor(t.text)
                    end
                    love.graphics.print(grid[i][j], x + cellSize/3, y + cellSize/4)
                end
            end
        end

        love.graphics.setColor(t.gridLine)
        love.graphics.setLineWidth(3)
        for i = 0, 3 do
            love.graphics.line(offsetX, offsetY + i*cellSize*3, offsetX + cellSize*9, offsetY + i*cellSize*3)
            love.graphics.line(offsetX + i*cellSize*3, offsetY, offsetX + i*cellSize*3, offsetY + cellSize*9)
        end
        love.graphics.setLineWidth(1)

        for n = 1, 9 do
            local px = offsetX + (n-1)*cellSize
            theme.setPaletteColor("button", 0.7)
            love.graphics.rectangle("fill", px, paletteY, cellSize, cellSize)
            theme.setColor("text")
            love.graphics.rectangle("line", px, paletteY, cellSize, cellSize)
            love.graphics.print(n, px + cellSize/3, paletteY + cellSize/4)
        end

        if selectedRow and selectedCol then
            love.graphics.setColor(p.highlight)
            local hx = offsetX + (selectedCol-1)*cellSize
            local hy = offsetY + (selectedRow-1)*cellSize
            love.graphics.rectangle("fill", hx, hy, cellSize, cellSize)
        end

        theme.setColor("text")
        locale.applyFont("text")

        love.graphics.print(locale.text("hud_2d_instructions"), offsetX - 170, cellSize + 30)
        love.graphics.print(locale.text("hud_2d_esc"),          offsetX + 40,  paletteY + cellSize + 15)
        
        if selectedRow and selectedCol then
            love.graphics.print(
                locale.text("hud_2d_selected", selectedRow, selectedCol),
                offsetX + 110, paletteY + cellSize + 50
            )
        end
        
        if errorMessage ~= "" then
            local width = love.graphics.getWidth()
            love.graphics.setColor(0.9, 0.1, 0.1, 1)
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(errorMessage)
            love.graphics.rectangle('fill', width/2 - textWidth/2 - 20, paletteY - 60, textWidth + 40, 40, 5, 5)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(errorMessage, width/2 - textWidth/2, paletteY - 50)
        end
    end
    
    -- Bottom-right undo/redo + top-right timer
    local screenWidth  = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    theme.setColor("text")
    locale.applyFont("small")
    
    -- timer (top right)
    local timeText   = "Time: " .. formatElapsed(elapsedTime)
    local timerFont  = love.graphics.getFont()
    local timerWidth = timerFont:getWidth(timeText)
    love.graphics.print(timeText, screenWidth - timerWidth - 20, 10)

    -- pause text (above undo/redo)
    local pauseText = isPaused and "Press SPACE to unpause" or "Press SPACE to pause"
    local pauseWidth = timerFont:getWidth(pauseText)
    love.graphics.print(pauseText, screenWidth - pauseWidth - 20, screenHeight - 80)

    -- undo / redo (bottom right)
    local undoText = "Press U to undo | Press R to redo"
    local textWidth = timerFont:getWidth(undoText)
    love.graphics.print(undoText, screenWidth - textWidth - 20, screenHeight - 40)

    -- Save / New buttons
    saveBtn.y = screenHeight - 40
    newBtn.y  = screenHeight - 40

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", saveBtn.x, saveBtn.y, saveBtn.w, saveBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf("Save", saveBtn.x, saveBtn.y + 5, saveBtn.w, "center")

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", newBtn.x, newBtn.y, newBtn.w, newBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf("New", newBtn.x, newBtn.y + 5, newBtn.w, "center")
    
    -- Draw save message if active
    if saveMessage ~= "" then
        local messageX = screenWidth / 2
        local messageY = 60
        love.graphics.setColor(0.2, 0.7, 0.2, 1)
        local messageFont = love.graphics.getFont()
        local messageWidth = messageFont:getWidth(saveMessage)
        love.graphics.rectangle('fill', messageX - messageWidth/2 - 20, messageY - 15, messageWidth + 40, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(saveMessage, messageX - messageWidth/2, messageY - 5)
    end
end

function module.mousepressed(x, y, button)
    if not puzzleInitialized or isPaused then return end
    
    if button == 1 then
        -- Save button clicked
        if x >= saveBtn.x and x <= saveBtn.x + saveBtn.w and
           y >= saveBtn.y and y <= saveBtn.y + saveBtn.h then
            local state = module.exportState()
            if state and Save.save("2d", module.currentDifficulty, state) then
                saveMessage = "Game Saved!"
                saveMessageTimer = 2  -- Show for 2 seconds
            else
                saveMessage = "Save Failed!"
                saveMessageTimer = 2
            end
            return
        end

        -- New game button clicked
        if x >= newBtn.x and x <= newBtn.x + newBtn.w and
           y >= newBtn.y and y <= newBtn.y + newBtn.h then
            -- Delete the current save file
            Save.delete("2d", module.currentDifficulty)
            -- Reload the puzzle
            puzzleInitialized = false
            module.load(module.currentDifficulty)
            saveMessage = "New Game!"
            saveMessageTimer = 2  -- Show for 2 seconds
            return
        end
    end

    if button == 1 then
        if x >= offsetX and x < offsetX + cellSize*9 and
           y >= offsetY and y < offsetY + cellSize*9 then
            selectedCol = math.floor((x - offsetX) / cellSize) + 1
            selectedRow = math.floor((y - offsetY) / cellSize) + 1
        end

        if y >= paletteY and y <= paletteY + cellSize then
            local numClicked = math.floor((x - offsetX) / cellSize) + 1
            if selectedRow and selectedCol and numClicked >= 1 and numClicked <= 9 then
                if not fixed[selectedRow][selectedCol] then
                    local oldValue = grid[selectedRow][selectedCol]
                    local valid, errMsg = isValidPlacement(selectedRow, selectedCol, numClicked)
                    if valid then
                        grid[selectedRow][selectedCol] = numClicked
                        storeMove(selectedRow, selectedCol, oldValue, numClicked)
                        errorMessage = ""
                        errorTimer = 0
                    else
                        errorMessage = errMsg
                        errorTimer = 3
                    end
                end
            end
        end
    end
end

function module.mousereleased(x, y, button)
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
    
    if key == "u" then
        undo()
        return
    elseif key == "r" then
        redo()
        return
    end
    
    if selectedRow and selectedCol then
        if not fixed[selectedRow][selectedCol] then
            local num = tonumber(key)
            if num and num >= 1 and num <= 9 then
                local oldValue = grid[selectedRow][selectedCol]
                local valid, errMsg = isValidPlacement(selectedRow, selectedCol, num)
                if valid then
                    grid[selectedRow][selectedCol] = num
                    storeMove(selectedRow, selectedCol, oldValue, num)
                    errorMessage = ""
                    errorTimer = 0
                else
                    errorMessage = errMsg
                    errorTimer = 3
                end
            elseif key == "backspace" or key == "delete" or key == "0" then
                local oldValue = grid[selectedRow][selectedCol]
                grid[selectedRow][selectedCol] = 0
                storeMove(selectedRow, selectedCol, oldValue, 0)
                errorMessage = ""
                errorTimer = 0
            end
        end
    end
    
    if selectedRow and selectedCol then
        if key == "up" and selectedRow > 1 then
            selectedRow = selectedRow - 1
        elseif key == "down" and selectedRow < 9 then
            selectedRow = selectedRow + 1
        elseif key == "left" and selectedCol > 1 then
            selectedCol = selectedCol - 1
        elseif key == "right" and selectedCol < 9 then
            selectedCol = selectedCol + 1
        end
    end
end

-- test helpers
module._test = {
    getGrid        = function() return grid end,
    getFixed       = function() return fixed end,
    solveSudoku    = solveSudoku,
    makePuzzle     = makePuzzle,
    isValidPlacement = isValidPlacement,
    isPuzzleComplete  = isPuzzleComplete,
    undo           = undo,
    redo           = redo,
    getMoveHistory = function() return moveHistory end,
    getUndoneMoves = function() return undoneMoves end,
    togglePause    = togglePause,
    isPaused       = function() return isPaused end,
}

return module
