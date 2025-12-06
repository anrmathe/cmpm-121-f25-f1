# Testing Guide

## Overview

This project includes automated tests for the 2D and 3D Sudoku logic. Tests are
written using a custom test framework (`minitest.lua`) and verify the core
functionality of the Sudoku solvers and validators.

## Test Structure

### Test Files

- **`tests/test_2d.lua`** - Tests for 2D Sudoku solver and validation logic
- **`tests/test_3d.lua`** - Tests for 3D cube Sudoku logic
- **`tests/minitest.lua`** - Custom test framework providing `describe`, `it`,
  `assert_*` functions
- **`tests/spec_helper.lua`** - Test utilities and setup

### Test Runner

- **`run_tests.lua`** - Main test runner that loads all test files and executes
  them

## Test Cases

### 2D Sudoku Tests (`test_2d.lua`)

#### 1. **solveSudoku fills an empty grid with a valid solution**

- **Purpose:** Verifies that the 2D Sudoku solver can solve an empty 9×9 grid
- **Validation:**
  - Returns `true` on successful solve
  - Each row contains all digits 1-9 without duplicates
  - Each column contains all digits 1-9 without duplicates

#### 2. **isValidPlacement rejects row/column/box duplicates**

- **Purpose:** Verifies that placement validation enforces Sudoku constraints
- **Test Cases:**
  - Rejects numbers that duplicate in the same row
  - Rejects numbers that duplicate in the same column
  - Rejects numbers that duplicate in the same 3×3 box
  - Accepts valid placements in different rows, columns, and boxes
- **Returns:** Boolean status and optional error message

#### 3. **isPuzzleComplete only returns true for a full correct puzzle**

- **Purpose:** Verifies puzzle completion validation
- **Test Cases:**
  - Returns `true` when a fully solved puzzle is complete
  - Returns `false` when any cell is empty (value = 0)
  - Ensures all cells are filled before considering the puzzle complete

### 3D Sudoku Tests (`test_3d.lua`)

#### 1. **isValidPlacement enforces row/column/box constraints**

- **Purpose:** Verifies that the 3D board respects standard Sudoku constraints
- **Test Cases:**
  - Rejects placements that duplicate in the same row
  - Allows placements in different rows, columns, and boxes
- **Note:** Board cells are stored as tables with a `value` field

#### 2. **isBoardComplete only returns true for a valid full board**

- **Purpose:** Verifies that a board is completely and correctly filled
- **Test Cases:**
  - Returns `true` for a fully solved 9×9 board with all values 1-9 in each
    row/column/box
  - Returns `false` when a cell is modified to create a duplicate
- **Setup:** Uses the 2D solver to generate a valid reference solution

#### 3. **initBoardsForTest builds 6 faces with valid given cells**

- **Purpose:** Verifies that the 3D cube initialization generates a valid puzzle
- **Validation:**
  - Creates 6 faces (one for each cube face)
  - Each face is a 9×9 grid with 9 rows and 9 columns
  - All given (non-zero) cells satisfy Sudoku constraints
  - Each cell exists as a proper table structure

## How to Run Tests

From the project root directory, run:

```
lua53 run_tests.lua
```

This will:

1. Load the test framework and utilities
2. Execute all tests in `test_2d.lua` and `test_3d.lua`
3. Display results showing passing and failing tests

### Expected Output

On success, you'll see output similar to:

```
2D Sudoku logic
[PASS] solveSudoku fills an empty grid with a valid solution
[PASS] isValidPlacement rejects row/column/box duplicates
[PASS] isPuzzleComplete only returns true for a full correct puzzle

3D cube Sudoku logic
[PASS] isValidPlacement enforces row/column/box
[PASS] isBoardComplete only returns true for a valid full board
[PASS] initBoardsForTest builds 6 faces with valid given cells
```

### Test Exit Codes

- **Exit code 0** - All tests passed
- **Non-zero exit code** - One or more tests failed
