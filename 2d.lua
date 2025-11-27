-- 2d.lua - 2D Sudoku Mode

local module = {}

local cellSize = 50
local selectedRow = nil
local selectedCol = nil
local paletteY = 0
local grid = {}
local fixed = {}
local errorMessage = ""
local errorTimer = 0

-- Starting puzzle
local puzzle = {
    {5,3,0,0,7,0,0,0,0},
    {6,0,0,1,9,5,0,0,0},
    {0,9,8,0,0,0,0,6,0},
    {8,0,0,0,6,0,0,0,3},
    {4,0,0,8,0,3,0,0,1},
    {7,0,0,0,2,0,0,0,6},
    {0,6,0,0,0,0,2,8,0},
    {0,0,0,4,1,9,0,0,5},
    {0,0,0,0,8,0,0,7,9}
}

local function isValidPlacement(row, col, value)
    if value == 0 then return true end
    
    -- Check row
    for c = 1, 9 do
        if c ~= col and grid[row][c] == value then
            return false, "Number " .. value .. " already exists in this row!"
        end
    end
    
    -- Check column
    for r = 1, 9 do
        if r ~= row and grid[r][col] == value then
            return false, "Number " .. value .. " already exists in this column!"
        end
    end
    
    -- Check 3x3 box
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

function module.load()
    cellSize = 50
    selectedRow = nil
    selectedCol = nil
    paletteY = cellSize * 9 + 20
    errorMessage = ""
    errorTimer = 0

    grid = {}
    fixed = {}
    for i = 1, 9 do
        grid[i] = {}
        fixed[i] = {}
        for j = 1, 9 do
            grid[i][j] = puzzle[i][j]
            fixed[i][j] = (puzzle[i][j] ~= 0)
        end
    end
end

function module.update(dt)
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
        if errorTimer <= 0 then
            errorMessage = ""
        end
    end
end

function module.draw()
    love.graphics.clear(0.68, 0.85, 0.9)
    
    -- Draw grid
    for i = 1, 9 do
        for j = 1, 9 do
            -- Cell background
            if fixed[i][j] then
                love.graphics.setColor(0.85, 0.85, 0.9)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", (j-1)*cellSize, (i-1)*cellSize, cellSize, cellSize)
            
            -- Cell border
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", (j-1)*cellSize, (i-1)*cellSize, cellSize, cellSize)

            -- Number
            if grid[i][j] ~= 0 then
                if fixed[i][j] then
                    love.graphics.setColor(0.1, 0.1, 0.3)
                else
                    love.graphics.setColor(0, 0, 0)
                end
                love.graphics.print(grid[i][j], (j-1)*cellSize + cellSize/3, (i-1)*cellSize + cellSize/4)
            end
        end
    end

    -- Draw thicker 3x3 lines
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.setLineWidth(3)
    for i = 0, 3 do
        love.graphics.line(0, i*cellSize*3, 9*cellSize, i*cellSize*3)
        love.graphics.line(i*cellSize*3, 0, i*cellSize*3, 9*cellSize)
    end
    love.graphics.setLineWidth(1)

    -- Draw number palette
    for n = 1, 9 do
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.print(n, (n-1)*cellSize + cellSize/3, paletteY + cellSize/4)
    end

    -- Draw selection highlight
    if selectedRow and selectedCol then
        love.graphics.setColor(0.7, 0.8, 1, 0.5)
        love.graphics.rectangle("fill", (selectedCol-1)*cellSize, (selectedRow-1)*cellSize, cellSize, cellSize)
    end

    -- Instructions
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Click cell then number palette | Or use number keys | Backspace to clear", 10, paletteY + cellSize + 10)
    love.graphics.print("Press ESC to return to menu", 10, paletteY + cellSize + 30)
    
    if selectedRow and selectedCol then
        love.graphics.print("Selected: [" .. selectedRow .. "," .. selectedCol .. "]", 10, paletteY + cellSize + 50)
    end
    
    -- Error message
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
        -- Grid selection
        if x < cellSize*9 and y < cellSize*9 then
            selectedCol = math.floor(x / cellSize) + 1
            selectedRow = math.floor(y / cellSize) + 1
        end

        -- Palette selection
        if y >= paletteY and y <= paletteY + cellSize then
            local numClicked = math.floor(x / cellSize) + 1
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
    -- Not needed for 2D mode
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
    
    -- Arrow key navigation
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

return module