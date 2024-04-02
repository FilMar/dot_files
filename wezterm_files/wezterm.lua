local wezterm = require("wezterm")


local config = {
    color_scheme = "Catppuccin Mocha",
    font = wezterm.font("FiraCode Nerd Font"),
    window_background_opacity = 0.9,
    enable_wayland = false,
    hide_tab_bar_if_only_one_tab = true
    --  keys = {
    --      {
    --          key = "n",
    --          mods = "ALT",
    --          action = wezterm.action.SpawnTab('CurrentPaneDomain'),
    --      },
    --      {
    --          key = "q",
    --          mods = "ALT",
    --          action = wezterm.action.CloseCurrentTab({ confirm = false }),
    --      },
    --      { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
    --      { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
    --      { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
    --      { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
    --      { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
    --      { key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
    --      { key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
    --      { key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
    --      { key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(8) },
    --      { key = '0', mods = 'ALT', action = wezterm.action.ActivateTab(9) },

    --  },
}

return config
