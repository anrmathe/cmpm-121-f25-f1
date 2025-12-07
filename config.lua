-- config.lua
-- Loads external DSL 

local json = require("dkjson")

local M = {}
local config = nil

local function loadConfig()
    if config then
        return config
    end

    -- Read JSON 
    local contents, size = love.filesystem.read("assets/game_config.json")
    if not contents then
        error("Could not read assets/game_config.json")
    end

    local decoded, pos, err = json.decode(contents, 1, nil)
    if err then
        error("JSON decode error in game_config.json: " .. err)
    end

    config = decoded
    return config
end

function M.get()
    return loadConfig()
end

function M.get2D(difficulty)
    local cfg = loadConfig()
    return cfg.sudoku2d[difficulty] or cfg.sudoku2d["medium"]
end

function M.get3D(difficulty)
    local cfg = loadConfig()
    return cfg.sudoku3d[difficulty] or cfg.sudoku3d["medium"]
end

function M.getWorld3D()
    local cfg = loadConfig()
    return cfg.world3d
end

return M
