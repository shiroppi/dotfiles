-- configure mason.nvim
require("mason").setup({
	ui = {
		border = "rounded",
	},
})

-- nvim-lspconfig は各サーバーの既定設定（lsp/*.lua）を提供するだけで、
-- ここでの設定はその上に vim.lsp.config() でマージされる
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- denols / ts_ls の root 判定（deno.json があれば denols、なければ ts_ls）は
-- nvim-lspconfig の既定設定がやってくれるので root_dir は指定しない
vim.lsp.config("denols", {
	settings = {
		deno = {
			lint = true,
			suggest = {
				imports = {
					hosts = {
						["https://deno.land"] = true,
						["https://cdn.nest.land"] = true,
						["https://crux.land"] = true,
					},
				},
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	init_options = {
		hostInfo = "neovim",
		maxTsServerMemory = 4096,
		tsserver = { useSyntaxServer = "never" },
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

-- mason でインストール済みのサーバーを vim.lsp.enable() する（automatic_enable）
require("mason-lspconfig").setup()
