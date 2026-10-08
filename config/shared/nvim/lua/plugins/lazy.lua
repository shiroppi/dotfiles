local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
		return
	end
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "folke/lazy.nvim", lazy = false, priority = 1000 },
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		config = function()
			require("plugins.conform")
		end,
	},
	{
		"tummetott/reticle.nvim",
		event = { "BufNewFile", "BufReadPre" },
		config = function()
			require("plugins.reticle")
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("plugins.noice")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufNewFile", "BufReadPre" },
		opts = {
			indent = {
				char = "▏",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- upstream notes Treesitter itself is not lazy-load friendly
		build = ":TSUpdate",
		config = function()
			require("plugins.treesitter")
		end,
	},
	{
		"Wansmer/treesj",
		keys = {
			{
				"gJ",
				function()
					require("treesj").toggle()
				end,
				desc = "Toggle split/join",
			},
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme catppuccin-macchiato]])
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufNewFile", "BufReadPre" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("plugins.lspconfig")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"petertriho/cmp-git",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
				dependencies = {
					"rafamadriz/friendly-snippets",
				},
			},
		},
		config = function()
			require("plugins.cmp")
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			auto_close = true,
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		cmd = "Lspsaga",
		event = "LspAttach",
		keys = {
			{ "<C-q>", "<Cmd>Lspsaga hover_doc<CR>", desc = "Hover doc" },
			-- 使っていなかったので無効化。KEYMAP_REVIEW.md の「LSP」節も参照
			-- { "<C-S-q>", "<Cmd>Lspsaga peek_definition<CR>", desc = "Peek definition" },
			-- { "<C-j>", "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next diagnostic" },
			-- { "gd", "<Cmd>Lspsaga finder<CR>", desc = "LSP finder" },
			-- { "gp", "<Cmd>Lspsaga peek_definition<CR>", desc = "Peek definition" },
			-- { "gr", "<Cmd>Lspsaga rename<CR>", desc = "Rename" },
			-- { "ge", "<Cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line diagnostics" },
			-- { "[e", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev diagnostic" },
			-- { "]e", "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next diagnostic" },
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("plugins.lspsaga")
		end,
	},
	-- denops plugins
	-- denops は起動時に rtp 上のプラグインを登録するため、
	-- 遅延読み込みにすると bufpreview が denops に認識されず動かない
	{ "vim-denops/denops.vim", lazy = false },
	{
		"kat0h/bufpreview.vim",
		lazy = false,
		build = "deno task prepare",
	},
	{
		"HidemaruOwO/mdxsnap.nvim",
		cmd = "PasteImage",
		ft = { "markdown", "mdx" },
		config = function()
			require("plugins.mdxsnap")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<C-f>", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
			{ "<C-s>", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
			{ "<C-S-s>", "<Cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
			{
				"<C-m>",
				"<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR><ESC>",
				desc = "File browser",
			},
			{ "<C-S-m>", "<Cmd>Telescope frecency<CR>", desc = "Frecent files" },
			{ "<C-.>", "<Cmd>Telescope symbols<CR>", mode = { "n", "i" }, desc = "Insert symbol" },
		},
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-symbols.nvim" },
			{ "nvim-telescope/telescope-frecency.nvim" },
			{ "nvim-telescope/telescope-file-browser.nvim" },
		},
		config = function()
			require("plugins.telescope")
		end,
	},
	{
		"echasnovski/mini.ai",
		version = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufNewFile", "BufReadPre", "InsertEnter" },
		config = function()
			require("plugins.autotag")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufNewFile", "BufReadPre" },
		opts = {},
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		keys = {
			{ "<C-t>", "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
		},
		config = function()
			require("plugins.toggleterm")
		end,
	},
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
		keys = {
			{ "<leader>or", "<Cmd>OverseerRun<CR>", desc = "Overseer run" },
		},
		opts = {},
	},
	{
		"norcalli/nvim-colorizer.lua",
		event = { "BufNewFile", "BufReadPre" },
		config = function()
			-- setup() の第1引数は filetype のリストなので opts = {} にはできない
			require("colorizer").setup()
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			{ "<leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>u", "<Cmd>UndotreeToggle<CR>", desc = "Undo tree" },
		},
	},
}

require("lazy").setup(plugins, {})
