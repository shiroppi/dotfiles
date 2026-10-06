-- nvim-treesitter (main ブランチ) の設定
-- パーサーのビルドには tree-sitter CLI (0.26.1 以降) と C コンパイラが必要。詳しくは README.md を参照

local ts = require("nvim-treesitter")

-- mdx は markdown パーサーで扱う
vim.treesitter.language.register("markdown", { "mdx" })

local function start(buf, lang)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.treesitter.start(buf, lang)
	end
end

local warned_no_cli = false

-- 旧 auto_install 相当: 開いたファイルのパーサーが無ければインストールし、ハイライトを有効にする
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(args.match)
		if not lang then
			return
		end

		if vim.treesitter.language.add(lang) then
			start(args.buf, lang)
			return
		end

		if not vim.list_contains(ts.get_available(), lang) then
			return
		end

		if vim.fn.executable("tree-sitter") == 0 then
			if not warned_no_cli then
				warned_no_cli = true
				vim.notify("tree-sitter CLI が見つからないためパーサーをインストールできません", vim.log.levels.WARN)
			end
			return
		end

		ts.install(lang):await(function(err, ok)
			if err or not ok then
				return
			end
			vim.schedule(function()
				start(args.buf, lang)
			end)
		end)
	end,
})
