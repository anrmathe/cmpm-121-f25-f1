-- theme.lua - Theme and color palette manager

local module = {}

-- Current theme settings
module.currentMode = "light" -- "light" or "dark"
module.currentPalette = "blue" -- "blue", "purple", "green", "sunset"

-- Theme definitions
module.themes = {
    light = {
        background = {0.68, 0.85, 0.9},
        menuBackground = {0.9, 0.9, 0.95},
        cellFill = {1, 1, 1},
        cellFixed = {0.85, 0.85, 0.9},
        cellBorder = {0.5, 0.5, 0.6},
        text = {0, 0, 0},
        textFixed = {0.1, 0.1, 0.3},
        textSecondary = {0.3, 0.3, 0.4},
        gridLine = {0.1, 0.1, 0.2},
    },
    dark = {
        background = {0.12, 0.15, 0.18},
        menuBackground = {0.15, 0.18, 0.22},
        cellFill = {0.22, 0.25, 0.28},
        cellFixed = {0.18, 0.20, 0.24},
        cellBorder = {0.4, 0.45, 0.5},
        text = {0.95, 0.95, 0.95},
        textFixed = {0.7, 0.75, 0.85},
        textSecondary = {0.6, 0.65, 0.7},
        gridLine = {0.5, 0.55, 0.6},
    }
}

-- Color palettes for highlights and buttons
module.palettes = {
    blue = {
        primary = {0.3, 0.5, 0.8},
        secondary = {0.5, 0.3, 0.8},
        accent = {0.2, 0.6, 0.4},
        highlight = {0.7, 0.8, 1, 0.5},
        button = {0.3, 0.5, 0.8},
    },
    purple = {
        primary = {0.6, 0.3, 0.8},
        secondary = {0.8, 0.3, 0.6},
        accent = {0.4, 0.2, 0.7},
        highlight = {0.8, 0.7, 1, 0.5},
        button = {0.6, 0.3, 0.8},
    },
    green = {
        primary = {0.2, 0.7, 0.5},
        secondary = {0.3, 0.6, 0.3},
        accent = {0.5, 0.8, 0.4},
        highlight = {0.7, 1, 0.8, 0.5},
        button = {0.2, 0.7, 0.5},
    },
    sunset = {
        primary = {0.9, 0.5, 0.3},
        secondary = {0.8, 0.3, 0.4},
        accent = {0.9, 0.7, 0.2},
        highlight = {1, 0.8, 0.6, 0.5},
        button = {0.9, 0.5, 0.3},
    }
}

-- Get current theme colors
function module.getTheme()
    return module.themes[module.currentMode]
end

-- Get current palette colors
function module.getPalette()
    return module.palettes[module.currentPalette]
end

-- Toggle between light and dark mode
function module.toggleMode()
    if module.currentMode == "light" then
        module.currentMode = "dark"
    else
        module.currentMode = "light"
    end
end

-- Set specific palette
function module.setPalette(paletteName)
    if module.palettes[paletteName] then
        module.currentPalette = paletteName
    end
end

-- Helper to set color from theme
function module.setColor(colorName, alpha)
    local theme = module.getTheme()
    local color = theme[colorName]
    if color then
        if alpha then
            love.graphics.setColor(color[1], color[2], color[3], alpha)
        else
            love.graphics.setColor(color[1], color[2], color[3])
        end
    end
end

-- Helper to set palette color
function module.setPaletteColor(colorName, alpha)
    local palette = module.getPalette()
    local color = palette[colorName]
    if color then
        if alpha then
            love.graphics.setColor(color[1], color[2], color[3], alpha)
        else
            love.graphics.setColor(color[1], color[2], color[3])
        end
    end
end

return module