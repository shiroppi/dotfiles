local wezterm = require("wezterm")

local M = {}

local is_mac = wezterm.target_triple:find("darwin") ~= nil

function M.apply(config)
	config.color_scheme = "Catppuccin Macchiato"
	config.font = wezterm.font("UDEV Gothic 35NFLG", { weight = "Bold" })
	config.font_size = is_mac and 16 or 13
	config.window_background_opacity = 1
	config.macos_window_background_blur = 30
	config.window_decorations = "RESIZE"
	config.window_padding = { left = "1cell", right = "1cell", top = "0.5cell", bottom = "0.5cell" }
	config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }

	-- WezTerm cannot animate cursor movement like Neovide; only the
	-- blink can be smoothed natively, via easing at a higher frame rate.
	config.max_fps = 120
	config.animation_fps = 120
	config.default_cursor_style = "BlinkingBar"
	config.cursor_blink_rate = 800
	config.cursor_blink_ease_in = "EaseIn"
	config.cursor_blink_ease_out = "EaseOut"

	-- Let applications that request it (e.g. Neovim) use the Kitty
	-- keyboard protocol for less ambiguous key input. Unlike
	-- enable_csi_u_key_encoding, this does not force the encoding on
	-- applications that do not request it.
	config.enable_kitty_keyboard = true

	config.use_ime = true
	config.enable_wayland = true
	config.warn_about_missing_glyphs = false
	config.adjust_window_size_when_changing_font_size = false
end

return M
