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

-- >>> Leader key
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

	--  Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {},
					lualine_x = { "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = { "filename" },
					lualine_b = { "branch" },
					lualine_c = {},
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				extensions = { "fugitive" },
			})
		end,
	},

	--  Nvim-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
			vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
		end,
	},

	--  Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			require("telescope").load_extension("fzf")
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		end,
	},

	--  Gitsigns
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	--  Nvim-treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				incremental_selection = {
					enable = true,
				},
			})
		end,
	},

	--  LSP manager
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason intergration LSP
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "lua_ls", "bashls", "jsonls", "html", "cssls" },
			})
		end,
	},

	-- Base LSP support
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

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

	--  Autocomplete
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
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			})
		end,
	},

	-- Autoformater: conform.nvim
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
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim", -- lsp_lines plugin
		config = function()
			require("lsp_lines").setup()

			vim.diagnostic.config({
				virtual_text = false,
				update_in_insert = true,
			})

			vim.keymap.set("n", "<Leader>l", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })
		end,
	},

	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("lspsaga").setup({
				ui = {
					border = "rounded",
					code_action = " ",
				},
				hover = {
					max_width = 80,
				},
			})
		end,
	},
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
		---@diagnostic disable-next-line: undefined-doc-name
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
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					hover = { enabled = true },
					signature = { enabled = true },
					message = { enabled = true },
				},
				presets = {
					lsp_doc_border = true,
				},
			})
		end,
	},

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			local logo = [[
  ██████ ██▒   █▓ ██▒   █▓▓█████ ▓█████▄▄▄█████▓▓█████▄  ██▀███  ▓█████ ▄▄▄       ███▄ ▄███▓  ██████
▒██    ▒▓██░   █▒▓██░   █▒▓█   ▀ ▓█   ▀▓  ██▒ ▓▒▒██▀ ██▌▓██ ▒ ██▒▓█   ▀▒████▄    ▓██▒▀█▀ ██▒▒██    ▒
░ ▓██▄   ▓██  █▒░ ▓██  █▒░▒███   ▒███  ▒ ▓██░ ▒░░██   █▌▓██ ░▄█ ▒▒███  ▒██  ▀█▄  ▓██    ▓██░░ ▓██▄
  ▒   ██▒ ▒██ █░░  ▒██ █░░▒▓█  ▄ ▒▓█  ▄░ ▓██▓ ░ ░▓█▄   ▌▒██▀▀█▄  ▒▓█  ▄░██▄▄▄▄██ ▒██    ▒██   ▒   ██▒
▒██████▒▒  ▒▀█░     ▒▀█░  ░▒████▒░▒████▒ ▒██▒ ░ ░▒████▓ ░██▓ ▒██▒░▒████▒▓█   ▓██▒▒██▒   ░██▒▒██████▒▒
▒ ▒▓▒ ▒ ░  ░ ▐░     ░ ▐░  ░░ ▒░ ░░░ ▒░ ░ ▒ ░░    ▒▒▓  ▒ ░ ▒▓ ░▒▓░░░ ▒░ ░▒▒   ▓▒█░░ ▒░   ░  ░▒ ▒▓▒ ▒ ░
░ ░▒  ░ ░  ░ ░░     ░ ░░   ░ ░  ░ ░ ░  ░   ░     ░ ▒  ▒   ░▒ ░ ▒░ ░ ░  ░ ▒   ▒▒ ░░  ░      ░░ ░▒  ░ ░
░  ░  ░      ░░       ░░     ░      ░    ░       ░ ░  ░   ░░   ░    ░    ░   ▒   ░      ░   ░  ░  ░
      ░       ░        ░     ░  ░   ░  ░           ░       ░        ░  ░     ░  ░       ░         ░
             ░        ░                          ░
    ]]
			logo = string.rep("\n", 2) .. logo .. "\n\n"

			require("dashboard").setup({
				theme = "hyper",
				config = {
					header = vim.split(logo, "\n"),
					shortcut = {
						{
							icon = "󰒲 ",
							icon_hl = "@constant",
							desc = "Update Plugins",
							group = "@property",
							action = "Lazy update",
							key = "u",
						},
						{
							icon = " ",
							icon_hl = "@variable",
							desc = "Find Files",
							group = "Label",
							action = "Telescope find_files",
							key = "f",
						},
						{
							icon = " ",
							icon_hl = "@variable",
							desc = "Dotfiles",
							group = "Label",
							action = "Telescope find_files cwd=~/.config",
							key = "d",
						},
						{
							icon = " ",
							icon_hl = "@string",
							desc = "Installed Plugins",
							group = "Label",
							action = "Lazy",
							key = "p",
						},
						{
							icon = " ",
							icon_hl = "@function",
							desc = "Recently Used Files",
							group = "Label",
							action = "Telescope oldfiles",
							key = "r",
						},
						{
							icon = " ",
							icon_hl = "@function",
							desc = "Quit Neovim",
							group = "Error",
							action = "qa",
							key = "q",
						},
					},

					mru = {
						enable = true,
						limit = 6,
						icon = " ",
						label = "Recent Files",
						cwd_only = false,
					},

					footer = {
						" ",
						" ",
						"⚰  Welcome to the Abyss",
						"  Stay focused. Stay dark.",
						"⚠  Configured by ConTI1NuEsZZZ",
					},
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "dashboard",
				callback = function()
					vim.cmd("IBLDisable")
				end,
			})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	"xiyaowong/transparent.nvim",
	config = function()
		-- Optional, you don't have to run setup.
		require("transparent").setup({
			-- table: default groups
			groups = {
				"Normal",
				"NormalNC",
				"Comment",
				"Constant",
				"Special",
				"Identifier",
				"Statement",
				"PreProc",
				"Type",
				"Underlined",
				"Todo",
				"String",
				"Function",
				"Conditional",
				"Repeat",
				"Operator",
				"Structure",
				"LineNr",
				"NonText",
				"SignColumn",
				"CursorLine",
				"CursorLineNr",
				"StatusLine",
				"StatusLineNC",
				"EndOfBuffer",
			},
			-- table: additional groups that should be cleared
			extra_groups = {},
			-- table: groups you don't want to clear
			exclude_groups = {},
			-- function: code to be executed after highlight groups are cleared
			-- Also the user event "TransparentClear" will be triggered
			on_clear = function() end,
		})
	end,
})

vim.opt.signcolumn = "yes:1"

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Форматувати файл" })

local map = vim.keymap.set

map("n", "<F2>", ":NvimTreeToggle<CR>", { desc = "Файловий менеджер" })
map("n", "<leader>q", ":bd<CR>", { desc = "Закрити буфер" })
map("n", "<leader>w", ":w<CR>", { desc = "Зберегти" })
map("n", "<leader>x", ":q<CR>", { desc = "Вийти" })
map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files, { desc = "Пошук файлів" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Глобальний пошук" })
map("n", "<leader>fb", builtin.buffers, { desc = "Список буферів" })

map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Документація" })
map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "До визначення" })
map("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Знайти посилання" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Перейменування" })
map("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Попередня помилка" })
map("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Наступна помилка" })

map("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Форматувати файл" })
