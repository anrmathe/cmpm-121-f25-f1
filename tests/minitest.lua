local M = {}
local tests = {}
local current_context = ""

function M.describe(name, fn)
    local prev = current_context
    current_context = (prev ~= "" and (prev .. " / " .. name) or name)
    fn()
    current_context = prev
end

function M.it(name, fn)
    local full = (current_context ~= "" and (current_context .. " :: " .. name) or name)
    table.insert(tests, { name = full, fn = fn })
end

local function fail(msg)
    error(msg, 2)
end

function M.assert_true(cond, msg)
    if not cond then
        fail(msg or "expected condition to be true")
    end
end

function M.assert_false(cond, msg)
    if cond then
        fail(msg or "expected condition to be false")
    end
end

function M.assert_equal(expected, actual, msg)
    if expected ~= actual then
        fail((msg or "values not equal") ..
             string.format(" (expected %s, got %s)", tostring(expected), tostring(actual)))
    end
end

function M.run()
    local passed, failed = 0, 0
    for _, t in ipairs(tests) do
        local ok, err = pcall(t.fn)
        if ok then
            passed = passed + 1
            print("[PASS] " .. t.name)
        else
            failed = failed + 1
            print("[FAIL] " .. t.name)
            print("       " .. tostring(err))
        end
    end
    print(("== Summary: %d passed, %d failed =="):format(passed, failed))
    if failed > 0 then os.exit(1) end
end

return M