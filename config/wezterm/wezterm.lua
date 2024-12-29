local wezterm = require("wezterm")

-- helpers
local is_dark = function()
	return wezterm.gui.get_appearance():find("Dark") ~= nil
end

-- settings
local config = wezterm.config_builder()
config.max_fps = 200
config.default_prog = { "/opt/homebrew/bin/tmux" }
config.use_dead_keys = false
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false
config.color_scheme = is_dark() and "zenbones_dark" or "zenbones_light"

-- font
-- config.font = wezterm.font("Iosevka Term Extended")
config.font = wezterm.font("JetBrains Mono")
config.font_size = 18.0
config.line_height = 1.5

-- tabbar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- styling
-- config.inactive_pane_hsb = { brightness = 0.95 }
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = "16px", right = "16px", top = "48px", bottom = "1px" }
config.window_close_confirmation = "NeverPrompt"
config.enable_scroll_bar = false

return config
