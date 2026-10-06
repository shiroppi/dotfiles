local signs = { Error = "", Warn = "", Hint = "💡", Info = "" }
local severity = vim.diagnostic.severity

vim.diagnostic.config({
	-- 行内の診断表示は diagflow.nvim が担当するので virtual_text は切る
	virtual_text = false,
	severity_sort = true,
	signs = {
		text = {
			[severity.ERROR] = signs.Error,
			[severity.WARN] = signs.Warn,
			[severity.HINT] = signs.Hint,
			[severity.INFO] = signs.Info,
		},
	},
})
