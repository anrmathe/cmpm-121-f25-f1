selectedRow = nil
selectedCol = nil


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
end

function love.draw()
    -- Draw grid
    for i = 1, 9 do
        for j = 1, 9 do
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", (j-1)*cellSize, (i-1)*cellSize, cellSize, cellSize)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", (j-1)*cellSize, (i-1)*cellSize, cellSize, cellSize)

            if grid[i][j] ~= 0 then
                love.graphics.print(grid[i][j], (j-1)*cellSize + cellSize/3, (i-1)*cellSize + cellSize/4)
            end
        end
    end

    -- Draw thicker 3x3 lines
    love.graphics.setLineWidth(3)
    for i = 0,3 do
        love.graphics.line(0, i*cellSize*3, 9*cellSize, i*cellSize*3)
        love.graphics.line(i*cellSize*3, 0, i*cellSize*3, 9*cellSize)
    end
    love.graphics.setLineWidth(1)

    -- Draw number palette
    for n = 1, 9 do
        love.graphics.setColor(0.8,0.8,0.8)
        love.graphics.rectangle("fill", (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", (n-1)*cellSize, paletteY, cellSize, cellSize)
        love.graphics.print(n, (n-1)*cellSize + cellSize/3, paletteY + cellSize/4)
    end

    -- Draw selection highlight
    if selectedRow and selectedCol then
        love.graphics.setColor(1,1,0,0.5)
        love.graphics.rectangle("fill", (selectedCol-1)*cellSize, (selectedRow-1)*cellSize, cellSize, cellSize)
    end

    love.graphics.setColor(0,0,0)
end

function love.mousepressed(x, y, button)
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
                grid[selectedRow][selectedCol] = numClicked
            end
        end
    end
end
