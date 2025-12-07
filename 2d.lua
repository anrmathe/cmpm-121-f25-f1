local module = {}
local theme = require("theme")
local locale = require("locale")
local Save = require("save")
-- load external dsl config
local config = require("config")

local cellSize = 50
local selectedRow = nil
local selectedCol = nil
local paletteY = 0
local grid = {}
local fixed = {}
local errorMessage = ""
local errorTimer = 0

-- center offsets
local offsetX = 0
local offsetY = 0

-- Undo/Redo system
local moveHistory = {} -- Array A
local undoneMoves = {} -- Array B

local saveBtn = {x = 20, y = 0, w = 60, h = 25}
local newBtn = {x = 110, y = 0, w = 60, h = 25}

-- Store a move in history
local function storeMove(row, col, oldValue, newValue)
    -- Clear undone moves if we're making a new move after undoing
    if #undoneMoves > 0 then
        undoneMoves = {}
    end
    
    -- Only store moves where something actually changed
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
    if #moveHistory > 0 then
        local lastMove = table.remove(moveHistory)
        local row, col, oldValue = lastMove.row, lastMove.col, lastMove.oldValue
        
        -- Store the move that we're undoing
        table.insert(undoneMoves, lastMove)
        
        -- Restore the old value
        grid[row][col] = oldValue
        
        -- Clear any error messages
        errorMessage = ""
        errorTimer = 0

        Save.autosave("2d", module.currentDifficulty, module.exportState())
        
        return true
    end
    return false
end

-- Redo last undone move
local function redo()
    if #undoneMoves > 0 then
        local lastUndone = table.remove(undoneMoves)
        local row, col, newValue = lastUndone.row, lastUndone.col, lastUndone.newValue
        
        -- Store the move that we're redoing
        table.insert(moveHistory, lastUndone)
        
        -- Apply the new value
        grid[row][col] = newValue
        
        -- Clear any error messages
        errorMessage = ""
        errorTimer = 0

        Save.autosave("2d", module.currentDifficulty, module.exportState())
        
        return true
    end
    return false
end

function isSafe(grid, row, col, num)
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

    for i=1,9 do
        if isSafe(grid, row, col, nums[i]) then
            grid[row][col] = nums[i]
            if solveSudoku(grid, row, col+1) then return true end
            grid[row][col] = 0
        end
    end
    return false
end

function makePuzzle(grid, holes)
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
    return {
        grid = grid,
        fixed = fixed,
        moveHistory = moveHistory,
        undoneMoves = undoneMoves
    }
end

function module.loadSavedState(state)
    grid = state.grid
    fixed = state.fixed
    moveHistory = state.moveHistory or {}
    undoneMoves = state.undoneMoves or {}
end

function module.load(difficulty)
    module.currentDifficulty = difficulty
    cellSize = 40

    selectedRow = nil
    selectedCol = nil
    errorMessage = ""
    errorTimer = 0

    local saved = Save.load("2d", difficulty)
    if saved then
        module.loadSavedState(saved)

        local boardSize = cellSize * 9
        offsetX = (love.graphics.getWidth() - boardSize) / 2
        offsetY = (love.graphics.getHeight() - boardSize - 100) / 2
        paletteY = offsetY + boardSize + 20

        return
    end

    moveHistory = {}
    undoneMoves = {}

    grid = {}
    fixed = {}

    for i = 1, 9 do
        grid[i] = {}
        for j = 1, 9 do
            grid[i][j] = 0
        end
    end

    -- Generate a full solved Sudoku
    solveSudoku(grid,1,1)

    local diffCfg = config.get2D(difficulty)
    local holes = (diffCfg and diffCfg.holes) or 45

    makePuzzle(grid, holes)

    for i = 1, 9 do
        fixed[i] = {}
        for j = 1, 9 do
            fixed[i][j] = (grid[i][j] ~= 0)
        end
    end

    local boardSize = cellSize * 9
    offsetX = (love.graphics.getWidth() - boardSize) / 2
    offsetY = (love.graphics.getHeight() - boardSize - 100) / 2

    paletteY = offsetY + boardSize + 20

    Save.autosave("2d", difficulty, module.exportState())
end

function module.update(dt)
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
        if errorTimer <= 0 then
            errorMessage = ""
        end
    end

    if isPuzzleComplete() then
        return "win"
    end
end

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

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
    love.graphics.print(locale.text("hud_2d_esc"), offsetX + 40, paletteY + cellSize + 15)
    
    if selectedRow and selectedCol then
        love.graphics.print(locale.text("hud_2d_selected", selectedRow, selectedCol), offsetX + 110, paletteY + cellSize + 50)
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
    
    -- Draw undo/redo instructions in bottom right corner
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    theme.setColor("text")
    locale.applyFont("small")
    
    local undoText = "Press U to undo | Press R to redo"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(undoText)
    love.graphics.print(undoText, screenWidth - textWidth - 20, screenHeight - 40)

    saveBtn.y = screenHeight - 40
    newBtn.y = screenHeight - 40

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", saveBtn.x, saveBtn.y, saveBtn.w, saveBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf("Save", saveBtn.x, saveBtn.y + 5, saveBtn.w, "center")

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", newBtn.x, newBtn.y, newBtn.w, newBtn.h, 8, 8)
    theme.setColor("text")
    love.graphics.printf("New", newBtn.x, newBtn.y + 5, newBtn.w, "center")
end

function module.mousepressed(x, y, button)
    if button == 1 then
        if x >= saveBtn.x and x <= saveBtn.x + saveBtn.w and
           y >= saveBtn.y and y <= saveBtn.y + saveBtn.h then
            Save.save("2d", module.currentDifficulty, grid, fixed)
            return
        end

        if x >= newBtn.x and x <= newBtn.x + newBtn.w and
           y >= newBtn.y and y <= newBtn.y + newBtn.h then
            Save.delete("2d", module.currentDifficulty)
            return "back"
        end
    end

    if button == 1 then
        if x >= offsetX and x < offsetX + cellSize*9 and y >= offsetY and y < offsetY + cellSize*9 then
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
    getGrid = function() return grid end,
    getFixed = function() return fixed end,
    solveSudoku = solveSudoku,
    makePuzzle = makePuzzle,
    isValidPlacement = isValidPlacement,
    isPuzzleComplete = isPuzzleComplete,
    undo = undo,
    redo = redo,
    getMoveHistory = function() return moveHistory end,
    getUndoneMoves = function() return undoneMoves end,
}

return module
