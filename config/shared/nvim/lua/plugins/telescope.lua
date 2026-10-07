local telescope = require("telescope")
local act = require("telescope.actions")
local fb_act = require("telescope._extensions.file_browser.actions")
local fb_utils = require("telescope._extensions.file_browser.utils")

-- fb_act.open は Linux だと xdg-open 決め打ちで、WSL では動かない
-- vim.ui.open で開き、WSL では Windows のパスに変換して explorer.exe に渡す
local function system_open(prompt_bufnr)
	local selections = fb_utils.get_selected_files(prompt_bufnr, true)
	for _, selection in ipairs(selections) do
		local path = selection:absolute()
		local opts
		if vim.fn.has("wsl") == 1 and vim.fn.executable("xdg-open") == 0 and vim.fn.executable("wslview") == 0 then
			path = vim.trim(vim.fn.system({ "wslpath", "-w", path }))
			opts = { cmd = { "explorer.exe" } }
		end
		local _, err = vim.ui.open(path, opts)
		if err then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
	act.close(prompt_bufnr)
end

-- 拡張の設定を反映させるため、setup してから load_extension する
telescope.setup({
	defaults = {
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		mappings = {
			i = {
				["<C-S>"] = act.select_vertical,
				["<C-s>"] = act.select_horizontal,
			},
			n = {
				["s"] = act.select_vertical,
				["S"] = act.select_horizontal,
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},
		file_browser = {
			hijack_netrw = true,
			mappings = {
				["i"] = {
					["<C-o>"] = system_open,
				},
				["n"] = {
					f = false,
					["o"] = system_open,
					["n"] = fb_act.create,
					["m"] = fb_act.move,
					["d"] = fb_act.remove,
					["r"] = fb_act.rename,
					["."] = fb_act.toggle_hidden,
					["s"] = false,
				},
			},
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("frecency")
telescope.load_extension("file_browser")
