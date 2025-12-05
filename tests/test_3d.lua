local cube = require("3d")
local T = cube._test

-- Helper: make a 9x9 board of {value=0}
local function emptyBoard()
    local b = {}
    for r = 1, 9 do
        b[r] = {}
        for c = 1, 9 do
            b[r][c] = { value = 0 }
        end
    end
    return b
end

describe("3D cube Sudoku logic", function()

    it("isValidPlacement enforces row/column/box", function()
        local board = emptyBoard()
        board[1][1].value = 3

        local ok, msg = T.isValidPlacement(board, 1, 2, 3)
        assert_false(ok, "same row duplicate should be invalid")
        assert_true(msg ~= nil)

        ok, msg = T.isValidPlacement(board, 4, 4, 3)
        assert_true(ok, "different row/col/box should be valid")
    end)

    it("isBoardComplete only returns true for a valid full board", function()
        -- Reuse 2D solver to build a valid board
        local sudoku2d = require("2d")._test
        local grid = {}
        for r = 1, 9 do
            grid[r] = {}
            for c = 1, 9 do
                grid[r][c] = 0
            end
        end
        assert_true(sudoku2d.solveSudoku(grid, 1, 1))

        local board = emptyBoard()
        for r = 1, 9 do
            for c = 1, 9 do
                board[r][c].value = grid[r][c]
            end
        end

        assert_true(T.isBoardComplete(board))

        -- Break it to test false case
        board[1][1].value = board[1][2].value
        assert_false(T.isBoardComplete(board))
    end)

    it("initBoardsForTest builds 6 faces with valid given cells", function()
        T.initBoardsForTest("testing")
        local boards = T.getBoards()
        assert_equal(6, #boards, "should have 6 faces")

        for face = 1, 6 do
            local b = boards[face]
            assert_true(b ~= nil, "face exists")
            assert_equal(9, #b, "9 rows")
            for r = 1, 9 do
                assert_equal(9, #b[r], "9 cols")
                for c = 1, 9 do
                    local cell = b[r][c]
                    assert_true(cell ~= nil, "cell exists")
                    if cell.value ~= 0 then
                        local ok, msg = T.isValidPlacement(b, r, c, cell.value)
                        assert_true(ok, msg or "generated value should be valid")
                    end
                end
            end
        end
    end)

end)