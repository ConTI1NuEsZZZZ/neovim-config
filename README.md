# SvvEeT1dREamS Neovim Config

Welcome to my personal [Neovim](https://neovim.io/) configuration!  
It’s designed to be fast, modern, and easy to extend. Perfect for coding in Python, Lua, Markdown, and more.


---

## Screenshots

### Dashboard
![Dashboard](/screenshots/Dashboard.png)

### Plugins
![Plugins](/screenshots/Plugins.png)

### lsp-line
![lsp-line](/screenshots/lsp-line.png)

### trouble
![trouble](/screenshots/trouble.png)

### lsp
![lsp1](/screenshots/lsp1.png)
![lsp2](/screenshots/lsp2.png)

### term
![term](/screenshots/term.png)

---

##  Features


-  Beautiful UI with [Catppuccin](https://github.com/catppuccin/nvim) colorscheme
-  Powerful LSP support via `mason.nvim`, `lspconfig`, and `cmp`
-  Fast fuzzy search using `telescope.nvim`
-  Syntax highlighting and structure via `nvim-treesitter`
-  Auto-formatting with `conform.nvim`
-  File tree navigation with `nvim-tree`
-  AI autocomplete with `copilot.vim`
-  Code linting & formatting with `black`, `stylua`, `shfmt`, etc.


---

## Requirements

Make sure you have these installed:

- Neovim `v0.9+` or `v0.10+` 
- [`fd`](https://github.com/sharkdp/fd)
- [`ripgrep`](https://github.com/BurntSushi/ripgrep)
- Formatter tools (optional): `black`, `stylua`, `shfmt`, `prettier`, etc.

**On macOS:**
```bash
 brew install fd ripgrep black stylua shfmt
```

**On Ubuntu/Debian:** 
```bash
sudo apt install fd-find ripgrep
```
---

## Getting Started

1. Clone the repo:
```bash
git clone https://github.com/conti1nueszzzz/neovim-config ~/.config/nvim
```

2. Open Neovim:
```bash
nvim
```

3.	Plugins will be automatically installed via [lazy.nvim](https://github.com/folke/lazy.nvim)

---

## Key Mapping


## ⌨️ Key Mappings

Here are some of the most useful key bindings in my Neovim config:

| Shortcut     | Mode       | Description                    |
|--------------|------------|--------------------------------|
| `<leader>ff` | Normal     | 🔍 Find files (Telescope)      |
| `<leader>fg` | Normal     | 🔎 Live grep (Telescope)       |
| `<leader>fb` | Normal     | 📚 List open buffers           |
| `F2`         | Normal     | 📁 Toggle file explorer (nvim-tree) |
| `<leader>gd` | Normal     | 📌 Go to definition (LSP)      |
| `<leader>gr` | Normal     | 🔁 Go to references (LSP)      |
| `<leader>rn` | Normal     | ✏️ Rename symbol (LSP)         |
| `<leader>ca` | Normal     | 💡 Code action (LSP)           |
| `K`          | Normal     | 📘 Hover documentation (LSP)   |
| `[d`         | Normal     | ⬆️ Previous diagnostic         |
| `]d`         | Normal     | ⬇️ Next diagnostic             |
| `<leader>f`  | Normal     | 🧼 Format current buffer        |
| `gc`         | Visual/Normal | 💬 Comment toggle (Comment.nvim) |
