-- シェルは vim.o.shell（options.lua で fish があれば fish）が使われる
require("toggleterm").setup({
	direction = "float",
	float_opts = {
		border = "rounded",
		width = function()
			return math.floor(vim.o.columns * 0.9)
		end,
		height = function()
			return math.floor(vim.o.lines * 0.9)
		end,
	},
	on_open = function(term)
		vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = term.bufnr, desc = "Close terminal" })
	end,
})
