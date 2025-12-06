# bc.nvim

A simple Neovim plugin to evaluate mathematical expressions using `bc` in markdown and telekasten files.

## Installation

### lazy.nvim

Add to your lazy.nvim plugin specification:

```lua
"navicore/bc.nvim"
```

Or in your full lazy setup:

```lua
require("lazy").setup({
  -- your other plugins...
  "navicore/bc.nvim",
  -- more plugins...
})
```

### Other plugin managers

#### packer.nvim
```lua
use 'navicore/bc.nvim'
```

#### vim-plug
```vim
Plug 'navicore/bc.nvim'
```

## Usage

1. Open a markdown or telekasten file
2. Visually select a mathematical expression (e.g., `2 * (33 - 1)`)
3. Run `:Bc` or `:'<,'>Bc`
4. The selection will be replaced with the expression and its result (e.g., `2 * (33 - 1) = 64`)

## Financial Formatting

The plugin supports currency and comma formatting:

- `$` symbols are preserved and the result uses 2 decimal places
- Comma separators in numbers (e.g., `10,000`) are preserved in the result

Examples:
- `2 * $5` → `2 * $5 = $10.00`
- `$100 / 3` → `$100 / 3 = $33.33`
- `2 * 10,000` → `2 * 10,000 = 20,000`
- `$1,000 + $500` → `$1,000 + $500 = $1,500.00`

## Decimal Handling

The output type is inferred from the input:

- **Integers only** → integer result (e.g., `10 / 3 = 3`)
- **Any float in input** → float result matching max decimal places (e.g., `10.0 / 3 = 3.3`)
- **Currency ($)** → always 2 decimal places (e.g., `$10 / 3 = $3.33`)

To get decimal results from integer division, use a float in the input: `10.0 / 3` instead of `10 / 3`.

## Requirements

- Neovim 0.7+
- `bc` command-line calculator (usually pre-installed on Unix-like systems)

## Limitations

- Only works in markdown or telekasten files (filetype must be `markdown` or `telekasten`)
- Uses `bc` syntax, so expressions must be valid `bc` input
