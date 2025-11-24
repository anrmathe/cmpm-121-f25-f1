selectedRow = nil
selectedCol = nil

function isSafe(grid, row, col, num)
    for c=1,9 do
        if grid[row][c] == num then return false end
    end

    for r=1,9 do
        if grid[r][col] == num then return false end
    end

    local boxR = math.floor((row-1)/3)*3 + 1
    local boxC = math.floor((col-1)/3)*3 + 1
    for r=boxR, boxR+2 do
        for c=boxC, boxC+2 do
            if grid[r][c] == num then return false end
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

            if solveSudoku(grid, row, col+1) then
                return true
            end

            grid[row][col] = 0
        end
    end

    return false
end

function makePuzzle(grid, holes) -- removes numbers from solved board to make puzzle
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


function love.load()
    cellSize = 50
    selectedRow = nil
    selectedCol = nil
    paletteY = cellSize*9 + 20

    grid = {}  -- 9x9 empty grid
    for i = 1, 9 do
        grid[i] = {}
        for j = 1, 9 do
            grid[i][j] = 0 -- 0 means empty
        end
    end

    solveSudoku(grid, 1, 1)
    makePuzzle(grid, 40)

    originalGrid = {}
    for i = 1, 9 do
        originalGrid[i] = {}
        for j = 1, 9 do
            originalGrid[i][j] = grid[i][j]
        end
    end
    
    gridOffsetX = (love.graphics.getWidth() - cellSize * 9) / 2
    gridOffsetY = (love.graphics.getHeight() - (cellSize * 9 + 20 + cellSize)) / 2

    paletteY = gridOffsetY + cellSize * 9 + 20
end

function love.draw()
    -- Draw grid
    for i = 1, 9 do
        for j = 1, 9 do
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill",
                gridOffsetX + (j-1)*cellSize,
                gridOffsetY + (i-1)*cellSize,
                cellSize, cellSize)

            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line",
                gridOffsetX + (j-1)*cellSize,
                gridOffsetY + (i-1)*cellSize,
                cellSize, cellSize)

            if grid[i][j] ~= 0 then
                if originalGrid[i][j] ~= 0 then
                    love.graphics.setColor(0,0,0)
                else
                    love.graphics.setColor(0.3,0.3,0.3)
                end

                love.graphics.print(
                    grid[i][j],
                    gridOffsetX + (j-1)*cellSize + cellSize/3,
                    gridOffsetY + (i-1)*cellSize + cellSize/4
                )
            end
        end
    end

    -- Draw thicker 3x3 lines
    love.graphics.setLineWidth(3)
    for i = 0,3 do
        love.graphics.line(
            gridOffsetX,
            gridOffsetY + i*cellSize*3,
            gridOffsetX + 9*cellSize,
            gridOffsetY + i*cellSize*3
        )
        love.graphics.line(
            gridOffsetX + i*cellSize*3,
            gridOffsetY,
            gridOffsetX + i*cellSize*3,
            gridOffsetY + 9*cellSize
        )
    end
    love.graphics.setLineWidth(1)

    -- Draw number palette
    for n = 1, 9 do
        love.graphics.setColor(0.8,0.8,0.8)
        love.graphics.rectangle("fill", gridOffsetX + (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", gridOffsetX + (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.print(n, gridOffsetX + (n-1)*cellSize + cellSize/3, paletteY + cellSize/4)
    end

    -- Draw selection highlight
    if selectedRow and selectedCol then
        love.graphics.setColor(1,1,0,0.5)
        love.graphics.rectangle("fill",
            gridOffsetX + (selectedCol-1)*cellSize,
            gridOffsetY + (selectedRow-1)*cellSize,
            cellSize, cellSize)
    end

    love.graphics.setColor(0,0,0)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- Grid selection
        if x >= gridOffsetX and x < gridOffsetX + cellSize*9 and
           y >= gridOffsetY and y < gridOffsetY + cellSize*9 then

            local col = math.floor((x - gridOffsetX) / cellSize) + 1
            local row = math.floor((y - gridOffsetY) / cellSize) + 1

            if originalGrid[row][col] == 0 then
                selectedRow = row
                selectedCol = col
            end
        end

        -- Palette selection
        if y >= paletteY and y <= paletteY + cellSize then
            local numClicked = math.floor((x - gridOffsetX) / cellSize) + 1
            if selectedRow and selectedCol and numClicked >= 1 and numClicked <= 9 then
                if originalGrid[selectedRow][selectedCol] == 0 then
                    grid[selectedRow][selectedCol] = numClicked
                end
            end
        end
    end
end



