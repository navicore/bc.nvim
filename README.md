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

## Requirements

- Neovim 0.7+
- `bc` command-line calculator (usually pre-installed on Unix-like systems)

## Limitations

- Only works in markdown or telekasten files (filetype must be `markdown` or `telekasten`)
- Uses `bc` syntax, so expressions must be valid `bc` input
- For decimal results, you may need to use `scale=2;` prefix (e.g., `scale=2; 10/3`)
