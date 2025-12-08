local module = {}
local theme = require("theme")
local locale = require("locale")
local Save = require("save")

module.buttons = {}

function module.draw()
    local t = theme.getTheme()
    local p = theme.getPalette()
    
    love.graphics.setColor(t.menuBackground)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local width, height = love.graphics.getDimensions()
    
    theme.setColor("text")
    locale.applyFont("title")
    love.graphics.printf(locale.text("settings_title"), 0, height/2 - 300, width, "center")

    locale.applyFont("text")
    love.graphics.printf(locale.text("settings_theme_mode"), 0, height/2 - 220, width, "center")
    
    local bw = 150
    local bh = 50
    local spacing = 20
    local startY = height/2 - 180
    
    local themeX = width/2 - bw - spacing/2
    
    if theme.currentMode == "light" then
        love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3], 0.8)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", themeX, startY, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf(locale.text("settings_light"), themeX, startY + 15, bw, "center")
    
    themeX = width/2 + spacing/2
    if theme.currentMode == "dark" then
        love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3], 0.8)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", themeX, startY, bw, bh, 10, 10)
    theme.setColor("text")
    love.graphics.printf(locale.text("settings_dark"), themeX, startY + 15, bw, "center")
    
    theme.setColor("text")
    locale.applyFont("text")
    love.graphics.printf(locale.text("settings_palette_label"), 0, height/2 - 90, width, "center")
    
    local paletteY = height/2 - 50
    local paletteStartX = width/2 - bw - spacing/2
    
    local palettes = {
        {name = "blue", label = "settings_palette_blue", x = paletteStartX, y = paletteY},
        {name = "purple", label = "settings_palette_purple", x = width/2 + spacing/2, y = paletteY},
        {name = "green", label = "settings_palette_green", x = paletteStartX, y = paletteY + bh + spacing},
        {name = "sunset", label = "settings_palette_sunset", x = width/2 + spacing/2, y = paletteY + bh + spacing},
    }
    
    module.buttons = {
        light = {x = width/2 - bw - spacing/2, y = height/2 - 180, w = bw, h = bh},
        dark = {x = width/2 + spacing/2, y = height/2 - 180, w = bw, h = bh},
        palettes = palettes
    }
    
    for _, pal in ipairs(palettes) do
        local palColors = theme.palettes[pal.name].primary
        if theme.currentPalette == pal.name then
            love.graphics.setColor(palColors[1], palColors[2], palColors[3], 0.9)
        else
            love.graphics.setColor(palColors[1], palColors[2], palColors[3], 0.5)
        end
        love.graphics.rectangle("fill", pal.x, pal.y, bw, bh, 10, 10)
        theme.setColor("text")
        locale.applyFont("text")
        love.graphics.printf(locale.text(pal.label), pal.x, pal.y + 15, bw, "center")
    end

    local langLabelY = paletteY + bh * 2 + spacing * 2
    locale.applyFont("text")
    love.graphics.printf(locale.text("settings_language_label"), 0, langLabelY, width, "center")
    
    local langBw, langBh = 120, 40
    local langSpacing = 20
    local totalLangWidth = langBw * 3 + langSpacing * 2
    local startLangX = (width - totalLangWidth) / 2
    local langY = langLabelY + 40
    
    local currentLang = locale.getLanguage()
    local langs = {
        {code = "en", labelKey = "settings_lang_en"},
        {code = "zh", labelKey = "settings_lang_zh"},
        {code = "ar", labelKey = "settings_lang_ar"},
    }
    
    module.buttons.languages = {}
    
    for i, lang in ipairs(langs) do
        local x = startLangX + (i - 1) * (langBw + langSpacing)
        local y = langY

        if currentLang == lang.code then
            love.graphics.setColor(p.primary[1], p.primary[2], p.primary[3], 0.8)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        love.graphics.rectangle("fill", x, y, langBw, langBh, 10, 10)
        theme.setColor("text")
        love.graphics.rectangle("line", x, y, langBw, langBh)

        local label
        if lang.code == "en" then
            love.graphics.setFont(fonts.en.text)
            label = "English"
        elseif lang.code == "zh" then
            love.graphics.setFont(fonts.zh.text)
            label = "中文"
        elseif lang.code == "ar" then
            love.graphics.setFont(fonts.ar.text)
            label = "العربية"
        end

        love.graphics.printf(label, x, y + 10, langBw, "center")

        module.buttons.languages[lang.code] = {x = x, y = y, w = langBw, h = langBh}
    end

    locale.applyFont("text")

    local autoY = langY + 60
    local autoLabelKey = Save.autosaveEnabled and "settings_autosave_on" or "settings_autosave_off"
    local autoLabel = locale.text(autoLabelKey)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", width/2 - 85, autoY, 170, 40, 10, 10)
    theme.setColor("text")
    love.graphics.printf(autoLabel, width/2 - 85, autoY + 10, 170, "center")

    
    
    local backY = height - 100
    theme.setPaletteColor("button")
    love.graphics.rectangle("fill", width/2 - 75, backY, 150, 50, 10, 10)
    theme.setColor("text")
    locale.applyFont("text")
    love.graphics.printf(locale.text("settings_back"), width/2 - 75, backY + 15, 150, "center")
    
    module.buttons.back = {x = width/2 - 75, y = backY, w = 150, h = 50}
    
    theme.setColor("textSecondary")
    locale.applyFont("small")
    love.graphics.printf(locale.text("settings_esc_hint"), 0, height - 30, width, "center")
end

function module.mousepressed(x, y)
    local b = module.buttons
    
    if x >= b.light.x and x <= b.light.x + b.light.w and
       y >= b.light.y and y <= b.light.y + b.light.h then
        theme.currentMode = "light"
        return nil
    end
    
    if x >= b.dark.x and x <= b.dark.x + b.dark.w and
       y >= b.dark.y and y <= b.dark.y + b.dark.h then
        theme.currentMode = "dark"
        return nil
    end
    
    for _, pal in ipairs(b.palettes) do
        if x >= pal.x and x <= pal.x + 150 and
           y >= pal.y and y <= pal.y + 50 then
            theme.setPalette(pal.name)
            return nil
        end
    end

    if b.languages then
        for code, btn in pairs(b.languages) do
            if x >= btn.x and x <= btn.x + btn.w and
               y >= btn.y and y <= btn.y + btn.h then
                locale.setLanguage(code)
                love.window.setTitle(locale.text("window_title"))
                return nil
            end
        end
    end

    if x >= b.autosave.x and x <= b.autosave.x + b.autosave.w and
       y >= b.autosave.y and y <= b.autosave.y + b.autosave.h then
        Save.autosaveEnabled = not Save.autosaveEnabled
        return nil
    end

    if x >= b.back.x and x <= b.back.x + b.back.w and
       y >= b.back.y and y <= b.back.y + b.back.h then
        return "back"
    end
    
    return nil
end

return module
