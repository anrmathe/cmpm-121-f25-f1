love = love or {}

love.math = love.math or {}
love.math.random = love.math.random or math.random

love.graphics = love.graphics or {}

love.graphics.getWidth = love.graphics.getWidth or function() return 900 end
love.graphics.getHeight = love.graphics.getHeight or function() return 700 end
love.graphics.getDimensions = love.graphics.getDimensions or function()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

love.graphics.clear = love.graphics.clear or function() end
love.graphics.setColor = love.graphics.setColor or function() end
love.graphics.rectangle = love.graphics.rectangle or function() end
love.graphics.line = love.graphics.line or function() end
love.graphics.polygon = love.graphics.polygon or function(...) end
love.graphics.print = love.graphics.print or function() end
love.graphics.printf = love.graphics.printf or function() end
love.graphics.setLineWidth = love.graphics.setLineWidth or function() end

love.graphics.newFont = love.graphics.newFont or function()
    return {
        getWidth = function() return 0 end,
        getHeight = function() return 14 end,
    }
end

love.graphics.getFont = love.graphics.getFont or function()
    return love.graphics.newFont()
end

love.window = love.window or {}
love.window.setTitle = love.window.setTitle or function() end
love.window.setMode = love.window.setMode or function() end

love.event = love.event or {}
love.event.quit = love.event.quit or function() end

return true