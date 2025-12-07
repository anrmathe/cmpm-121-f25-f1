local Save = {}

local json = require("dkjson") or require("json")

local function makeFilename(mode, difficulty)
    return string.format("save_%s_%s.json", mode, difficulty)
end

local function encode(data)
    return json.encode(data, { indent = false })
end

local function decode(str)
    return json.decode(str)
end

function Save.save(mode, difficulty, state)
    if not state then return end
    local filename = makeFilename(mode, difficulty)
    local payload = {
        mode = mode,
        difficulty = difficulty,
        timestamp = os.time(),
        grid = state.grid,
        fixed = state.fixed,
        boards = state.boards,
        moveHistory = state.moveHistory or {},
        undoneMoves = state.undoneMoves or {},
        autosave = state.autosave ~= false
    }
    return love.filesystem.write(filename, encode(payload))
end

Save.autosaveEnabled = true

function Save.autosave(mode, difficulty, state)
    if Save.autosaveEnabled then
        Save.save(mode, difficulty, state)
    end
end

function Save.load(mode, difficulty)
    local filename = makeFilename(mode, difficulty)
    if not love.filesystem.getInfo(filename) then return nil end
    local contents = love.filesystem.read(filename)
    if not contents then return nil end
    return decode(contents)
end

function Save.delete(mode, difficulty)
    local filename = makeFilename(mode, difficulty)
    if love.filesystem.getInfo(filename) then
        love.filesystem.remove(filename)
    end
end

function Save.exists(mode, difficulty)
    local filename = makeFilename(mode, difficulty)
    return love.filesystem.getInfo(filename) ~= nil
end

return Save
