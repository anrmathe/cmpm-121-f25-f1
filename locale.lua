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

        loading_puzzle        = "Loading puzzle...",

        hud_time_label        = "Time: %s",
        hud_pause_unpause     = "Press SPACE to unpause",
        hud_pause_pause       = "Press SPACE to pause",

        hud_save_button       = "Save",
        hud_new_button        = "New",
        hud_save_success      = "Game Saved!",
        hud_save_failed       = "Save Failed!",
        hud_new_game          = "New Game!",

        hud_no_undo           = "No moves to undo!",
        hud_no_redo           = "No moves to redo!",

        world_controls_hint   = "LMB drag joystick: move | LMB drag elsewhere: look | Space / Jump button: jump",
        world_jump_button     = "Jump",

        settings_autosave_on  = "Auto-Save: ON",
        settings_autosave_off = "Auto-Save: OFF",

        win_time_label        = "Time taken: %s",

        hud_2d_instructions   = "Click on cells to interact | Number keys to fill | Backspace to clear",
        hud_2d_esc            = "Press ESC to return to menu",
        hud_2d_selected       = "Selected: [%d,%d]",
        hud_2d_undo           = "Press U to undo | Press R to redo",

        hud_3d_instructions   = "Drag to rotate | Use arrow keys for fine rotation\nClick cells to interact | Number keys to fill",
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

        loading_puzzle        = "正在加载谜题...",

        hud_time_label        = "时间：%s",
        hud_pause_unpause     = "按空格继续",
        hud_pause_pause       = "按空格暂停",

        hud_save_button       = "保存",
        hud_new_button        = "新游戏",
        hud_save_success      = "游戏已保存！",
        hud_save_failed       = "保存失败！",
        hud_new_game          = "已开始新游戏！",

        hud_no_undo           = "没有可以撤销的操作！",
        hud_no_redo           = "没有可以重做的操作！",

        world_controls_hint   = "左键拖动摇杆移动 | 左键在其他地方拖动观察 | 空格 / 跳跃按钮：跳跃",
        world_jump_button     = "跳跃",

        settings_autosave_on  = "自动保存：开",
        settings_autosave_off = "自动保存：关",

        win_time_label        = "用时：%s",

        hud_2d_instructions   = "点击格子再选数字 | 或使用数字键 | Backspace 删除",
        hud_2d_esc            = "按 ESC 返回菜单",
        hud_2d_selected       = "已选：[%d,%d]",
        hud_2d_undo           = "按 U 撤销 | 按 R 重做",

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

        loading_puzzle        = "جارٍ تحميل اللغز...",

        hud_time_label        = "الوقت: %s",
        hud_pause_unpause     = "اضغط SPACE للمتابعة",
        hud_pause_pause       = "اضغط SPACE للإيقاف المؤقت",

        hud_save_button       = "حفظ",
        hud_new_button        = "جديد",
        hud_save_success      = "تم الحفظ!",
        hud_save_failed       = "فشل الحفظ!",
        hud_new_game          = "لعبة جديدة!",

        hud_no_undo           = "لا يوجد ما يمكن التراجع عنه!",
        hud_no_redo           = "لا يوجد ما يمكن إعادته!",

        world_controls_hint   = "اسحب بالفأرة على عصا التحكم للتحرك | اسحب في مكان آخر للنظر | Space / زر القفز: قفز",
        world_jump_button     = "قفز",

        settings_autosave_on  = "الحفظ التلقائي: يعمل",
        settings_autosave_off = "الحفظ التلقائي: متوقف",

        win_time_label        = "الوقت المستغرق: %s",

        hud_2d_instructions   = "انقر على الخانة ثم رقم | أو استخدم أزرار الأرقام | Backspace للحذف",
        hud_2d_esc            = "اضغط ESC للعودة إلى القائمة",
        hud_2d_selected       = "المحدد: [%d,%d]",
        hud_2d_undo          = "اضغط U للتراجع | اضغط R للإعادة",

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
