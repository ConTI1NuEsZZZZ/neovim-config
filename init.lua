-- >>> Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- >>> Base settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.laststatus = 0 -- Не показувати дефолтний статусбар
vim.opt.showmode = false -- Не показувати "-- INSERT --" і подібне

-- >>> Leader key (обов’язково до плагінів!)
vim.g.mapleader = " "

-- >>> Plugins
require("lazy").setup({

	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato",
				integrations = {
					treesitter = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
					lsp_trouble = true,
					lsp_saga = false,
					cmp = true,
					gitsigns = true,
					telescope = true,
					which_key = true,
				},
				highlight_overrides = {
					all = function(colors)
						return {
							["@keyword.import"] = { style = { "italic" }, fg = colors.mauve },
							["@variable.builtin"] = { style = { "italic" }, fg = colors.red },
							["@function.builtin"] = { fg = colors.blue },
							["@comment"] = { fg = colors.overlay1, style = { "italic" } },
						}
					end,
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- 🧱 Lualine — статусбар
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					globalstatus = true, -- Єдиний статусбар на весь екран
				},
				sections = {
					lualine_a = { "mode" }, -- Показує поточний режим (NORMAL/INSERT)
					lualine_b = { "branch" }, -- Ім’я гілки Git
					lualine_c = {},
					lualine_x = { "fileformat", "filetype" }, -- Кодування, формат файлу, тип
					lualine_y = { "progress" }, -- Прогрес (рядок/стовпець)
					lualine_z = { "location" }, -- Позиція в файлі (рядок:стовпець)
				},
				inactive_sections = {
					lualine_a = { "filename" }, -- Назва файлу для неактивних буферів
					lualine_b = { "branch" }, -- Гілка Git
					lualine_c = {},
					lualine_x = { "location" }, -- Місце в файлі для неактивних
					lualine_y = {},
					lualine_z = {},
				},
				extensions = { "fugitive" }, -- Для Git, якщо потрібно
			})
		end,
	},

	-- 🌲 Nvim-tree — файловий менеджер
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
			vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
		end,
	},

	-- 🔍 Telescope — пошук
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		end,
	},

	-- 🔧 Gitsigns — підсвічування змін
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- 🌲 Nvim-treesitter — синтаксичний аналізатор
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all", -- Встановити парсери для всіх підтримуваних мов
				highlight = {
					enable = true, -- Включити підсвічування синтаксису
					additional_vim_regex_highlighting = false, -- вимкнення додаткового підсвітлення
				},
				incremental_selection = {
					enable = true, -- Включити інкрементальний вибір
				},
			})
		end,
	},

	-- Пошуковий інструмент fd (sharkdp/fd)
	{
		"sharkdp/fd",
		run = ":UpdateFd",
	},

	-- ripgrep
	{
		"BurntSushi/ripgrep",
		run = ":UpdateRipgrep",
	},

	-- LSP менеджер
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},

	-- Інтеграція Mason з LSP
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "lua_ls", "bashls", "jsonls", "html", "cssls" },
			})
		end,
	},

	-- Основна LSP підтримка
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			-- Lua для конфігів
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})
		end,
	},

	-- Автодоповнення
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip", -- snippets
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- 📐 Автоформатер: conform.nvim
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "black" },
				lua = { "stylua" },
				javascript = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				sh = { "shfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	-- 🧪 Лінтер: nvim-lint + ruff
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				python = { "ruff" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble<cr>", desc = "Trouble" },
			{ "<leader>xq", "<cmd>Trouble quickfix<cr>", desc = "QuickFix" },
			{ "<leader>xd", "<cmd>Trouble diagnostics<cr>", desc = "Document Diagnostics" },
		},
	},

	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim", -- Плагін lsp_lines
		config = function()
			-- Ініціалізація плагіна
			require("lsp_lines").setup()

			-- Вимкнути стандартний virtual_text для діагностик
			vim.diagnostic.config({
				virtual_text = false,
				update_in_insert = true,
			})

			-- Можна додати гарячі клавіші для перемикання:
			vim.keymap.set("n", "<Leader>l", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })
		end,
	},

	-- 📦 Lspsaga — покращене LSP UI
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lspsaga").setup({})
		end,
	},

	-- 🧩 Автодоповнення для парних символів
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
				},
				query = {
					[""] = "rainbow-delimiters",
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
})

vim.opt.signcolumn = "yes:1"

-- >>> Keymap: <leader>f — ручне форматування
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Форматувати файл" })

local map = vim.keymap.set

-- Загальні мапінги
map("n", "<F2>", ":NvimTreeToggle<CR>", { desc = "Файловий менеджер" })
map("n", "<leader>q", ":bd<CR>", { desc = "Закрити буфер" })
map("n", "<leader>w", ":w<CR>", { desc = "Зберегти" })
map("n", "<leader>x", ":q<CR>", { desc = "Вийти" })
-- Вийти з режиму термінала на Esc
map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- Telescope
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files, { desc = "Пошук файлів" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Глобальний пошук" })
map("n", "<leader>fb", builtin.buffers, { desc = "Список буферів" })

-- LSP (через Lspsaga)
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Документація" })
map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "До визначення" })
map("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Знайти посилання" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Перейменування" })
map("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Попередня помилка" })
map("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Наступна помилка" })

-- Форматування
map("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Форматувати файл" })
