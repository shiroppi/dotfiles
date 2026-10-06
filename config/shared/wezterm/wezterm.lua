local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("appearance").apply(config)
require("tab_bar").apply(config)
require("keys").apply(config)

if wezterm.target_triple:find("windows") then
	config.default_domain = "WSL:archlinux"

	-- Without a known pane cwd, WSL starts in the Windows-side directory
	-- wezterm itself was launched from (e.g. /mnt/c/Users/...).
	local wsl_domains = wezterm.default_wsl_domains()
	for _, domain in ipairs(wsl_domains) do
		domain.default_cwd = "~"
	end
	config.wsl_domains = wsl_domains
end

return config
