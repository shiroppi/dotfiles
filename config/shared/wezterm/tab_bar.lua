local wezterm = require("wezterm")

local M = {}

-- Show the tab number, or an icon while one of these is in the foreground.
local function process_icon(path)
	local name = path:gsub("^.*[/\\]", ""):gsub("%.exe$", ""):lower()
	if name == "nvim" then
		return wezterm.nerdfonts.linux_neovim
	end
	-- The native installer runs ~/.local/share/claude/versions/<version>.
	if name == "claude" or path:find("/claude/versions/", 1, true) then
		return "✳"
	end
	return nil
end

-- WSL panes on Windows only expose wsl.exe as the process, so fall back to
-- the title the program sets (nvim needs `set title`).
local function title_icon(title)
	local lower = title:lower()
	if lower:find("^nvim") or lower:find("%- nvim$") then
		return wezterm.nerdfonts.linux_neovim
	end
	if title:find("^✳") or lower:find("claude code", 1, true) then
		return "✳"
	end
	return nil
end

wezterm.on("format-tab-title", function(tab)
	local pane = tab.active_pane
	local label = process_icon(pane.foreground_process_name or "")
		or title_icon(pane.title or "")
		or tostring(tab.tab_index + 1)
	return " " .. label .. " "
end)

function M.apply(config)
	config.use_fancy_tab_bar = false
	config.tab_bar_at_bottom = true
	config.hide_tab_bar_if_only_one_tab = true
	config.show_new_tab_button_in_tab_bar = false
end

return M
