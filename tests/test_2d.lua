local sudoku2d = require("2d")
local T = sudoku2d._test

local function emptyGrid()
    local g = {}
    for r = 1, 9 do
        g[r] = {}
        for c = 1, 9 do
            g[r][c] = 0
        end
    end
    return g
end

describe("2D Sudoku logic", function()

    it("solveSudoku fills an empty grid with a valid solution", function()
        local g = emptyGrid()
        assert_true(T.solveSudoku(g, 1, 1), "solver should return true")

        -- Check each row has 1-9 without duplicates
        for r = 1, 9 do
            local seen = {}
            for c = 1, 9 do
                local v = g[r][c]
                assert_true(v >= 1 and v <= 9, "value in range")
                assert_false(seen[v], "no duplicate in row")
                seen[v] = true
            end
        end

        -- Check each column has 1-9 without duplicates
        for c = 1, 9 do
            local seen = {}
            for r = 1, 9 do
                local v = g[r][c]
                assert_true(v >= 1 and v <= 9, "value in range")
                assert_false(seen[v], "no duplicate in column")
                seen[v] = true
            end
        end
    end)

    it("isValidPlacement rejects row/column/box duplicates", function()
        local grid = T.getGrid()
        -- Reset internal grid to all zeros
        for r = 1, 9 do
            grid[r] = grid[r] or {}
            for c = 1, 9 do
                grid[r][c] = 0
            end
        end

        -- Place a 5 at (1,1)
        grid[1][1] = 5

        local ok, msg = T.isValidPlacement(1, 2, 5)
        assert_false(ok, "duplicate in same row should be invalid")
        assert_true(msg ~= nil)

        ok, msg = T.isValidPlacement(2, 1, 5)
        assert_false(ok, "duplicate in same column should be invalid")

        -- Same 3x3 box
        grid[1][1] = 7
        ok, msg = T.isValidPlacement(2, 2, 7)
        assert_false(ok, "duplicate in same box should be invalid")

        -- Different row/col/box should be OK
        ok, msg = T.isValidPlacement(4, 4, 7)
        assert_true(ok)
    end)

    it("isPuzzleComplete only returns true for a full correct puzzle", function()
        local solved = emptyGrid()
        assert_true(T.solveSudoku(solved, 1, 1))

        local grid = T.getGrid()
        for r = 1, 9 do
            grid[r] = grid[r] or {}
            for c = 1, 9 do
                grid[r][c] = solved[r][c]
            end
        end

        assert_true(T.isPuzzleComplete())

        -- Break the puzzle to test false case
        grid[1][1] = 0
        assert_false(T.isPuzzleComplete())
    end)

end)