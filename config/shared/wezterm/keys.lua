local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
	config.disable_default_key_bindings = true
	config.keys = {
		{ key = "h", mods = "CTRL", action = act.SendKey({ key = "LeftArrow" }) },
		{ key = "j", mods = "CTRL", action = act.SendKey({ key = "DownArrow" }) },
		{ key = "k", mods = "CTRL", action = act.SendKey({ key = "UpArrow" }) },
		{ key = "l", mods = "CTRL", action = act.SendKey({ key = "RightArrow" }) },
		{ key = "c", mods = "CMD", action = act.SendKey({ key = "c", mods = "CTRL" }) },
		{ key = "a", mods = "CMD", action = act.SendKey({ key = "a", mods = "CTRL" }) },
		{ key = "v", mods = "CMD", action = act.SendKey({ key = "v", mods = "CTRL" }) },
		{ key = "x", mods = "CMD", action = act.SendKey({ key = "x", mods = "CTRL" }) },
		{ key = "c", mods = "SHIFT|CMD", action = act.CopyTo("Clipboard") },
		{ key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
		{ key = "v", mods = "SHIFT|CMD", action = act.PasteFrom("Clipboard") },
		{ key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
		{ key = "e", mods = "CTRL", action = act.SendString("nvim\n") },
		{ key = "y", mods = "ALT|CTRL", action = act.ActivateCopyMode },
		{ key = "p", mods = "ALT|CTRL", action = act.PasteFrom("PrimarySelection") },
		{ key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "|", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "e", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "q", mods = "ALT", action = act.CloseCurrentTab({ confirm = false }) },
		{ key = "h", mods = "ALT|SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "l", mods = "ALT|SHIFT", action = act.ActivateTabRelative(1) },
		{ key = "[", mods = "ALT", action = act.ActivatePaneDirection("Left") },
		{ key = "]", mods = "ALT", action = act.ActivatePaneDirection("Right") },
		{ key = "{", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Up") },
		{ key = "}", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Down") },
		{ key = "h", mods = "ALT|SHIFT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", mods = "ALT|SHIFT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", mods = "ALT|SHIFT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", mods = "ALT|SHIFT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = " ", mods = "ALT", action = act.QuickSelect },
		{ key = "o", mods = "ALT", action = act.ShowTabNavigator },
	}
	for i = 1, 9 do
		table.insert(config.keys, { key = tostring(i), mods = "ALT", action = act.ActivateTab(i - 1) })
	end

	-- Disable middle-click paste.
	config.mouse_bindings = {
		{ event = { Up = { streak = 1, button = "Middle" } }, mods = "NONE", action = act.Nop },
		{ event = { Down = { streak = 1, button = "Middle" } }, mods = "NONE", action = act.Nop },
	}
end

return M
