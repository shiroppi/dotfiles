local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

-- friendly-snippets など runtimepath 上の VSCode 形式スニペットを読み込む
require("luasnip.loaders.from_vscode").lazy_load()

-- The following options are generally recommended for nvim-cmp
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Removed noinsert

-- Highlight group for CmpItemKind similar to CmpItemMenuDefault
vim.api.nvim_set_hl(0, "CmpItemKind", { link = "CmpItemMenuDefault" })

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(), -- Changed from close() to abort() for consistency
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text", -- Changed from "symbol"
			maxwidth = 50,
			ellipsis_char = "...",
			symbol_map = {
				Text = "  ",
				Method = "  ",
				Function = " 󰊕 ",
				Constructor = "  ",
				Field = " 󰽏 ",
				Variable = " 󰫧 ",
				Class = "  ",
				Interface = "  ",
				Module = "  ",
				Property = " ⅊ ",
				Unit = " ◫ ",
				Value = "  ",
				Enum = "  ",
				Keyword = "  ",
				Snippet = "  ",
				Color = "  ",
				File = " 󰈔 ",
				Reference = "  ",
				Folder = " 󰉋 ",
				EnumMember = "  ",
				Constant = "  ",
				Struct = "  ",
				Event = "  ",
				Operator = " ∏ ",
				TypeParameter = "  ",
			},
		}),
	},
	window = {
		completion = cmp.config.window.bordered({
			border = "rounded",
			winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
			col_offset = -3,
			side_padding = 0,
		}),
		documentation = cmp.config.window.bordered({
			border = "rounded",
			winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
		}),
	},
	experimental = {
		ghost_text = false,
	},
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" },
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/`
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
