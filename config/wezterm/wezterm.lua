local wezterm = require("wezterm")
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- automatic dark/light mode
local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return theme.moon.colors()
	else
		return theme.dawn.colors()
	end
end

-- settings
config.use_dead_keys = false
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false

-- set color_scheme
config.colors = scheme_for_appearance(get_appearance())

-- font
config.font = wezterm.font_with_fallback({ "MonoLisa", "JetBrains Mono" })
config.font_size = 16.0
config.line_height = 1.5

-- tabbar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- styling
config.inactive_pane_hsb = { brightness = 0.95 }
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.native_macos_fullscreen_mode = true
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_decorations = "RESIZE"
config.window_padding = {
	left = "1px",
	right = "1px",
	bottom = "1px",
}
config.window_close_confirmation = "NeverPrompt"
config.enable_scroll_bar = false

-- keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1003 }
config.keys = {
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "%", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "f", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "h", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "j", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "k", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "l", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}
for i = 1, 8 do
	-- LEADER + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

return config
