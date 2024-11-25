local wezterm = require("wezterm")

-- helpers
local is_linux = function()
	return wezterm.target_triple:find("linux") ~= nil
end

local is_darwin = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

local is_dark = function()
	return wezterm.gui.get_appearance():find("Dark") ~= nil
end

-- settings
local config = wezterm.config_builder()
config.max_fps = 200
config.default_prog = is_darwin() and { "/opt/homebrew/bin/tmux" } or { "toolbox", "run", "tmux" }
config.use_dead_keys = false
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false
config.color_scheme = is_dark() and "zenbones_dark" or "zenbones_light"
-- config.color_scheme = is_dark() and "zenwritten_dark" or "zenwritten_light"

-- font
config.font = wezterm.font("Iosevka Term Extended")
config.font_size = is_linux() and 13.0 or 18.0
config.line_height = 1.5

-- tabbar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- styling
-- config.inactive_pane_hsb = { brightness = 0.95 }
-- config.window_background_opacity = 0.99
-- config.macos_window_background_blur = 999999
config.window_decorations = is_linux() and "TITLE | RESIZE" or "INTEGRATED_BUTTONS|RESIZE"
config.enable_wayland = is_linux() and false -- https://github.com/wez/wezterm/issues/4962
config.window_padding = { left = "16px", right = "16px", top = is_linux() and "8px" or "48px", bottom = "1px" }
config.window_close_confirmation = "NeverPrompt"
config.enable_scroll_bar = false

return config
