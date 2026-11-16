-- Web formatters are chosen per project: oxfmt when the project uses oxc,
-- biome when it uses Biome, and prettier otherwise. conform runs the first
-- available formatter in this list, and the `condition` functions in the
-- setup call below decide which tools count as available for a buffer.
local web_formatter = { "oxfmt", "biome", "prettier", stop_after_first = true }

local web_filetypes = {
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"css",
	"html",
	"json",
	"jsonc",
	"yaml",
	"markdown",
	"graphql",
	"scss",
}

-- Filetypes Biome can format. In a Biome project the other web filetypes
-- (html, scss, yaml, markdown) still go to prettier.
local biome_filetypes = {
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
	json = true,
	jsonc = true,
	css = true,
	graphql = true,
}

local biome_markers = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
local oxfmt_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

local function dir_has_file(dir, names)
	for _, name in ipairs(names) do
		if vim.fn.filereadable(dir .. "/" .. name) == 1 then
			return true
		end
	end
	return false
end

-- The tool a directory's package.json declares, if any. oxfmt is checked
-- first: it is a formatter-only tool, while Biome is often present only as
-- a linter.
local function package_json_tool(dir)
	local path = dir .. "/package.json"
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
	if not ok or type(decoded) ~= "table" then
		return nil
	end
	local function declares(name)
		for _, section in ipairs({ "dependencies", "devDependencies" }) do
			local deps = decoded[section]
			if type(deps) == "table" and deps[name] ~= nil then
				return true
			end
		end
		return false
	end
	if declares("oxfmt") then
		return "oxfmt"
	end
	if declares("@biomejs/biome") then
		return "biome"
	end
	return nil
end

-- Results are cached per starting directory; a formatter config created
-- mid-session is picked up after restarting Neovim.
local project_tool_cache = {}

---Find the web formatter tool the buffer's project uses, searching upward
---from the file's directory. The nearest directory with a marker wins, and
---oxfmt wins within a single directory. The search stops after the
---directory containing .git, or at the filesystem root.
---@param bufnr integer
---@return "oxfmt"|"biome"|nil
local function project_tool(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	local start_dir = vim.fn.fnamemodify(name, ":p:h")
	local cached = project_tool_cache[start_dir]
	if cached ~= nil then
		return cached or nil
	end

	local result = nil
	local dir = start_dir
	while true do
		if dir_has_file(dir, oxfmt_markers) then
			result = "oxfmt"
		elseif dir_has_file(dir, biome_markers) then
			result = "biome"
		else
			result = package_json_tool(dir)
		end
		if result then
			break
		end
		if vim.fn.isdirectory(dir .. "/.git") == 1 or vim.fn.filereadable(dir .. "/.git") == 1 then
			break
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end

	project_tool_cache[start_dir] = result or false
	return result
end

local formatters_by_ft = {
	lua = { "stylua" },
	python = { "isort", "black" },
	astro = { "prettier" },
	mdx = { "prettier" },
	sh = { "shfmt" },
	bash = { "shfmt" },
	fish = { "fish_indent" },
	rust = { "rustfmt" },
	go = { "gofmt" },
	zig = { "zigfmt" },
	["*"] = { "trim_whitespace", "trim_newlines" },
}

for _, ft in ipairs(web_filetypes) do
	formatters_by_ft[ft] = web_formatter
end

-- configure language
local rustfmt = require("conform.formatters.rustfmt")
rustfmt.args = function()
	return { "--edition", "2021", "--emit", "stdout" }
end

require("conform").setup({
	formatters_by_ft = formatters_by_ft,
	formatters = {
		biome = {
			condition = function(_, ctx)
				return biome_filetypes[vim.bo[ctx.buf].filetype] == true and project_tool(ctx.buf) == "biome"
			end,
		},
		oxfmt = {
			condition = function(_, ctx)
				return project_tool(ctx.buf) == "oxfmt"
			end,
		},
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
