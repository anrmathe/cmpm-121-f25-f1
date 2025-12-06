-- locale.lua
-- very small i18n helper for EN / 中文 / العربية

local locale = {}

locale.currentLanguage = "en"

locale.languages = {
    en = {
        direction = "ltr",
        window_title          = "Sudoku Worlds",
        menu_title            = "SUDOKU & WORLD",
        menu_choose_mode      = "Choose Mode:",
        menu_mode_2d          = "2D Sudoku",
        menu_mode_3d          = "3D Sudoku",
        menu_mode_world       = "World 3D",
        menu_settings         = "Settings",
        menu_esc_hint         = "Press ESC to return to menu",

        settings_title            = "SETTINGS",
        settings_theme_mode       = "Theme Mode:",
        settings_light            = "Light",
        settings_dark             = "Dark",
        settings_palette_label    = "Color Palette:",
        settings_palette_blue     = "Blue",
        settings_palette_purple   = "Purple",
        settings_palette_green    = "Green",
        settings_palette_sunset   = "Sunset",
        settings_language_label   = "Language:",
        settings_lang_en          = "English",
        settings_lang_zh          = "中文",
        settings_lang_ar          = "العربية",
        settings_back             = "Back to Menu",
        settings_esc_hint         = "Press ESC to return to menu",

        difficulty_title      = "SELECT DIFFICULTY",
        difficulty_testing    = "Testing",
        difficulty_easy       = "Easy",
        difficulty_medium     = "Medium",
        difficulty_hard       = "Hard",
        difficulty_esc_hint   = "Press ESC in game to return to menu",

        win_title_text        = "YOU WIN!",
        win_esc_hint          = "Press ESC to return to menu",

        hud_2d_instructions   = "Click cell then number palette | Or use number keys | Backspace to clear",
        hud_2d_esc            = "Press ESC to return to menu",
        hud_2d_selected       = "Selected: [%d,%d]",

        hud_3d_instructions   = "Drag to rotate | Click cells | Number keys to fill | Arrow keys for fine rotation",
        hud_3d_esc            = "Press ESC to return to menu",
        hud_3d_selected       = "Selected: Face %s [%d,%d]",

        world_hint_mouse      = "Right-Click to capture mouse and move",
        world_hint_locked     = "WASD to Walk | Mouse to Look | ESC to release",
        world_position        = "Position: %.1f, %.1f, %.1f",
        world_inventory       = "Inventory: %d / 20 spheres",

        error_row             = "Number %d already exists in this row!",
        error_col             = "Number %d already exists in this column!",
        error_box             = "Number %d already exists in this 3x3 box!",
    },

    zh = {
        direction = "ltr",
        window_title          = "数独世界",
        menu_title            = "数独与世界",
        menu_choose_mode      = "选择模式：",
        menu_mode_2d          = "2D 数独",
        menu_mode_3d          = "3D 数独",
        menu_mode_world       = "3D 世界",
        menu_settings         = "设置",
        menu_esc_hint         = "按 ESC 返回菜单",

        settings_title            = "设置",
        settings_theme_mode       = "主题模式：",
        settings_light            = "浅色",
        settings_dark             = "深色",
        settings_palette_label    = "配色方案：",
        settings_palette_blue     = "蓝色",
        settings_palette_purple   = "紫色",
        settings_palette_green    = "绿色",
        settings_palette_sunset   = "日落",
        settings_language_label   = "语言：",
        settings_lang_en          = "English",
        settings_lang_zh          = "中文",
        settings_lang_ar          = "العربية",
        settings_back             = "返回菜单",
        settings_esc_hint         = "按 ESC 返回菜单",

        difficulty_title      = "选择难度",
        difficulty_testing    = "测试",
        difficulty_easy       = "简单",
        difficulty_medium     = "中等",
        difficulty_hard       = "困难",
        difficulty_esc_hint   = "游戏中按 ESC 返回菜单",

        win_title_text        = "你赢了！",
        win_esc_hint          = "按 ESC 返回菜单",

        hud_2d_instructions   = "点击格子再选数字 | 或使用数字键 | Backspace 删除",
        hud_2d_esc            = "按 ESC 返回菜单",
        hud_2d_selected       = "已选：[%d,%d]",

        hud_3d_instructions   = "拖动旋转 | 点击格子 | 数字键填写 | 方向键微调",
        hud_3d_esc            = "按 ESC 返回菜单",
        hud_3d_selected       = "已选：面 %s [%d,%d]",

        world_hint_mouse      = "右键锁定鼠标并移动",
        world_hint_locked     = "WASD 移动 | 鼠标观察 | ESC 释放",
        world_position        = "位置：%.1f, %.1f, %.1f",
        world_inventory       = "物品：%d / 20 球体",

        error_row             = "数字 %d 在这一行已存在！",
        error_col             = "数字 %d 在这一列已存在！",
        error_box             = "数字 %d 在这个 3x3 宫格中已存在！",
    },

    ar = {
        direction = "rtl",
        window_title          = "سودوكو العوالم",
        menu_title            = "سودوكو والعالم",
        menu_choose_mode      = "اختر الوضع:",
        menu_mode_2d          = "سودوكو ثنائي الأبعاد",
        menu_mode_3d          = "سودوكو ثلاثي الأبعاد",
        menu_mode_world       = "العالم ثلاثي الأبعاد",
        menu_settings         = "الإعدادات",
        menu_esc_hint         = "اضغط ESC للعودة إلى القائمة",

        settings_title            = "الإعدادات",
        settings_theme_mode       = "وضع السمة:",
        settings_light            = "فاتح",
        settings_dark             = "داكن",
        settings_palette_label    = "لوحة الألوان:",
        settings_palette_blue     = "أزرق",
        settings_palette_purple   = "بنفسجي",
        settings_palette_green    = "أخضر",
        settings_palette_sunset   = "غروب",
        settings_language_label   = "اللغة:",
        settings_lang_en          = "English",
        settings_lang_zh          = "中文",
        settings_lang_ar          = "العربية",
        settings_back             = "عودة إلى القائمة",
        settings_esc_hint         = "اضغط ESC للعودة إلى القائمة",

        difficulty_title      = "اختر مستوى الصعوبة",
        difficulty_testing    = "تجريبي",
        difficulty_easy       = "سهل",
        difficulty_medium     = "متوسط",
        difficulty_hard       = "صعب",
        difficulty_esc_hint   = "اضغط ESC في اللعبة للعودة إلى القائمة",

        win_title_text        = "فزت!",
        win_esc_hint          = "اضغط ESC للعودة إلى القائمة",

        hud_2d_instructions   = "انقر على الخانة ثم رقم | أو استخدم أزرار الأرقام | Backspace للحذف",
        hud_2d_esc            = "اضغط ESC للعودة إلى القائمة",
        hud_2d_selected       = "المحدد: [%d,%d]",

        hud_3d_instructions   = "اسحب للدوران | انقر على الخانات | أزرار الأرقام للتعبئة | الأسهم لتدوير دقيق",
        hud_3d_esc            = "اضغط ESC للعودة إلى القائمة",
        hud_3d_selected       = "المحدد: الوجه %s [%d,%d]",

        world_hint_mouse      = "زر الفأرة الأيمن لقفل المؤشر والحركة",
        world_hint_locked     = "WASD للمشي | الفأرة للنظر | ESC للإفلات",
        world_position        = "الموقع: %.1f, %.1f, %.1f",
        world_inventory       = "المخزون: %d / 20 كرة",

        error_row             = "الرقم %d موجود بالفعل في هذا الصف!",
        error_col             = "الرقم %d موجود بالفعل في هذا العمود!",
        error_box             = "الرقم %d موجود بالفعل في هذا المربع 3x3!",
    },
}

-- change language at runtime
function locale.setLanguage(code)
    if locale.languages[code] then
        locale.currentLanguage = code
    end
end

function locale.getLanguage()
    return locale.currentLanguage
end

function locale.getDirection()
    local lang = locale.languages[locale.currentLanguage]
    return (lang and lang.direction) or "ltr"
end

-- main helper: returns localized string; if extra args are passed, uses string.format
function locale.text(key, ...)
    local lang = locale.languages[locale.currentLanguage] or locale.languages.en
    local template = lang[key] or locale.languages.en[key] or "??"
    if select("#", ...) > 0 then
        return string.format(template, ...)
    else
        return template
    end
end

function locale.applyFont(kind)
    if not fonts then return end
    local set = fonts[locale.currentLanguage] or fonts.en
    if not set then return end

    if kind == "huge" and set.huge then
        love.graphics.setFont(set.huge)
    elseif kind == "title" and set.title then
        love.graphics.setFont(set.title)
    elseif kind == "small" and set.small then
        love.graphics.setFont(set.small)
    else
        -- default to text
        love.graphics.setFont(set.text or set.title or set.small)
    end
end

return locale
