-- 2d.lua - 2D Sudoku Mode with Theme Support

local module = {}
local theme = require("theme")

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
            return false, "Number " .. value .. " already exists in this row!"
        end
    end
    for r = 1, 9 do
        if r ~= row and grid[r][col] == value then
            return false, "Number " .. value .. " already exists in this column!"
        end
    end
    
    local boxRow = math.floor((row - 1) / 3) * 3
    local boxCol = math.floor((col - 1) / 3) * 3
    
    for r = boxRow + 1, boxRow + 3 do
        for c = boxCol + 1, boxCol + 3 do
            if (r ~= row or c ~= col) and grid[r][c] == value then
                return false, "Number " .. value .. " already exists in this 3x3 box!"
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

function module.load(difficulty)
    cellSize = 40

    selectedRow = nil
    selectedCol = nil
    errorMessage = ""
    errorTimer = 0

    grid = {}
    fixed = {}

    for i = 1, 9 do
        grid[i] = {}
        for j = 1, 9 do
            grid[i][j] = 0
        end
    end

    solveSudoku(grid,1,1)

    local holes = 45 -- default
    if difficulty == "testing" then
        holes = 2
    elseif difficulty == "easy" then
        holes = 25
    elseif difficulty == "medium" then
        holes = 45
    elseif difficulty == "hard" then
        holes = 60
    end

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
    local mainFont = love.graphics.newFont(20)
    love.graphics.setFont(mainFont)

    love.graphics.print("Click cell then number palette | Or use number keys | Backspace to clear", offsetX - 170, cellSize + 30)
    love.graphics.print("Press ESC to return to menu", offsetX + 40, paletteY + cellSize + 15)
    
    if selectedRow and selectedCol then
        love.graphics.print("Selected: [" .. selectedRow .. "," .. selectedCol .. "]", offsetX + 110, paletteY + cellSize + 50)
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

function module.mousepressed(x, y, button)
    if button == 1 then
        if x >= offsetX and x < offsetX + cellSize*9 and y >= offsetY and y < offsetY + cellSize*9 then
            selectedCol = math.floor((x - offsetX) / cellSize) + 1
            selectedRow = math.floor((y - offsetY) / cellSize) + 1
        end

        if y >= paletteY and y <= paletteY + cellSize then
            local numClicked = math.floor((x - offsetX) / cellSize) + 1
            if selectedRow and selectedCol and numClicked >= 1 and numClicked <= 9 then
                if not fixed[selectedRow][selectedCol] then
                    local valid, errMsg = isValidPlacement(selectedRow, selectedCol, numClicked)
                    if valid then
                        grid[selectedRow][selectedCol] = numClicked
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
    if selectedRow and selectedCol then
        if not fixed[selectedRow][selectedCol] then
            local num = tonumber(key)
            if num and num >= 1 and num <= 9 then
                local valid, errMsg = isValidPlacement(selectedRow, selectedCol, num)
                if valid then
                    grid[selectedRow][selectedCol] = num
                    errorMessage = ""
                    errorTimer = 0
                else
                    errorMessage = errMsg
                    errorTimer = 3
                end
            elseif key == "backspace" or key == "delete" or key == "0" then
                grid[selectedRow][selectedCol] = 0
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
}

return module