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
-- config.font = wezterm.font("FiraCode Nerd Font")
config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.font_size = 17.0
config.line_height = 1.4

-- tabbar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- styling
config.inactive_pane_hsb = { brightness = 0.9 }
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

-- keys
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1003 }
config.keys = {
	{ key = "\\", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	{ key = "w", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ key = "h", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "j", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 6 }) },
	{ key = "k", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "l", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "LeftArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },
}
for i = 1, 8 do
	-- LEADER + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
