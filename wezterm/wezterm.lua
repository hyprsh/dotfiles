local wezterm = require("wezterm")

-- init config
local config = {}

-- automatic dark/light mode
local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "tokyonight_storm"
	else
		return "tokyonight_day"
	end
end

-- settings
config.use_dead_keys = false
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false

-- set color_scheme
config.color_scheme = scheme_for_appearance(get_appearance())

-- font
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16.0
config.line_height = 1.4

-- window
config.enable_tab_bar = false
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.native_macos_fullscreen_mode = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
	left = "1px",
	right = "1px",
	top = "60px",
	bottom = "1px",
}
config.window_close_confirmation = "NeverPrompt"
config.enable_scroll_bar = false

return config
