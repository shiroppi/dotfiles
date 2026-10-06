-- noice はコマンドラインのポップアップと LSP の見た目だけに使う
-- メッセージ・通知は横取りせず、Neovim 標準のコマンドライン領域に出す
require("noice").setup({
	messages = {
		enabled = false, -- エラーなどのメッセージは標準のコマンドライン領域に出す
	},
	notify = {
		enabled = false, -- vim.notify を横取りしない（ポップアップ通知を出さない）
	},
	lsp = {
		-- window/showMessage も標準のハンドラ（vim.notify）に任せる
		message = {
			enabled = false,
		},
		-- cmp のドキュメントや LSP の hover を treesitter でハイライトする
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	presets = {
		lsp_doc_border = true, -- hover / signature help に枠を付ける
	},
})
