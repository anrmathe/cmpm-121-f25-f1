-- difficulty.lua - difficulty switcher for 2D Sudoku game

local module = {}

function module.draw()
    love.graphics.clear(0.2, 0.2, 0.3)
    local width, height = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SELECT DIFFICULTY", 0, height/2 - 150, width, "center")

    local bw = 150
    local bh = 60
    local spacing = 50
    local totalWidth = bw*2 + spacing
    local startX = (width - totalWidth)/2
    local startY = height/2 - 100

    module.buttons = {
        {label="Testing", x=startX, y=startY, difficulty="testing"},
        {label="Easy", x=startX + bw + spacing, y=startY, difficulty="easy"},
        {label="Medium", x=startX, y=startY + 100, difficulty="medium"},
        {label="Hard", x=startX + bw + spacing, y=startY + 100, difficulty="hard"},
    }

    for _, b in ipairs(module.buttons) do
        if b.label == "Testing" then
            love.graphics.setColor(0.3, 0.6, 0.8)
        elseif b.label == "Easy" then
            love.graphics.setColor(0.3, 0.8, 0.4)
        elseif b.label == "Medium" then
            love.graphics.setColor(0.8, 0.7, 0.3)
        elseif b.label == "Hard" then
            love.graphics.setColor(0.8, 0.3, 0.3)
        end
        love.graphics.rectangle("fill", b.x, b.y, bw, bh, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(b.label, b.x, b.y + 20, bw, "center")
    end
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ESC in game to return to menu", 0, height - 50, width, "center")
end

function module.mousepressed(x, y)
    local bw = 150
    local bh = 60

    for _, b in ipairs(module.buttons) do
        if x >= b.x and x <= b.x + bw and y >= b.y and y <= b.y + bh then
            return b.difficulty
        end
    end
    return nil
end

return module
