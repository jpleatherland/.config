-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Aura Dark'

-- Font
config.font = wezterm.font('RobotoMono Nerd Font', { weight = 'Light' })

config.keys = {
	{
	  key = '_',
	  mods ='SHIFT|ALT',
	  action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
	},
	{
	  key = '+',
	  mods ='SHIFT|ALT',
	  action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
	},
	{
	  key = 'UpArrow',
	  mods ='ALT',
	  action = wezterm.action.ActivatePaneDirection 'Up',
	},
	{
	  key = 'DownArrow',
	  mods ='ALT',
	  action = wezterm.action.ActivatePaneDirection 'Down',
	},
	{
	  key = 'LeftArrow',
	  mods ='ALT',
	  action = wezterm.action.ActivatePaneDirection 'Left',
	},
	{
	  key = 'RightArrow',
	  mods = 'ALT',
	  action = wezterm.action.ActivatePaneDirection 'Right',
	},
	{
	  key = 'Home',
	  mods = 'ALT',
	  action = wezterm.action.ActivateTabRelative(-1)
	},
	{
	  key = 'End',
	  mods = 'ALT',
	  action = wezterm.action.ActivateTabRelative(1)
	},
	{
	  key = 't',
	  mods = 'ALT',
	  action = wezterm.action.SpawnTab 'CurrentPaneDomain'
	},
}

-- and finally, return the configuration to wezterm
return config
