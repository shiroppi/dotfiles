local options = {
	number = true,
	tabstop = 2,
	shiftwidth = 2,
	helplang = "ja",
	virtualedit = "onemore",
	expandtab = true,
	splitright = true,
	smartindent = true,
	showmatch = true,
	updatetime = 250,
	signcolumn = "yes",
	mouse = "",
	wildmode = "list:longest",
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- fish が無い環境（Windows や素の Linux）では既定のシェルを使う
if vim.fn.executable("fish") == 1 then
	vim.opt.shell = "fish"
end
