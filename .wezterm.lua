local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Frappe'

-- Key bindings
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '_',
        mods = 'LEADER|SHIFT',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    {
        key = 'a',
        mods = 'LEADER|CTRL',
        action = act.SendKey { key = 'a', mods = 'CTRL' },
    },
}

-- Mouse bindings
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = act.PasteFrom('PrimarySelection')
    }
}

-- Font
config.font = wezterm.font_with_fallback { { family = 'MesloLGS Nerd Font Propo', weight = 'Bold' } }
config.font_size = 16.0
config.font_rules = {
    {
        italic = true,
        intensity = 'Bold',
        font = wezterm.font {
            family = 'Operator Mono SSm',
            italic = true,
            weight = 'Medium'
        }
    },
    {
        italic = true,
        intensity = 'Normal',
        font = wezterm.font {
            family = 'Operator Mono SSm',
            italic = true,
            weight = 'Book'
        }
    },
    {
        italic = true,
        intensity = 'Half',
        font = wezterm.font {
            family = 'Operator Mono SSm',
            italic = true,
            weight = 'Light'
        }
    }
}

-- Tab bar
config.window_frame = {
    font = wezterm.font { family = 'Operator Mono SSm', weight = 'Book', italic = true },
    font_size = 14.0
}

-- Window
config.window_background_opacity = 0.96
config.macos_window_background_blur = 30
local border_color = wezterm.get_builtin_color_schemes()['catppuccin-frappe'].selection_bg;
config.window_frame = {
    border_left_width = '0.2cell',
    border_right_width = '0.2cell',
    border_bottom_height = '0.1cell',
    border_left_color = border_color,
    border_right_color = border_color,
    border_bottom_color = border_color,
}

-- Misc
config.default_cursor_style = 'SteadyBar'
config.cursor_thickness = 1
config.default_cwd = wezterm.home_dir .. '/devel'
config.pane_focus_follows_mouse = true
config.term = 'wezterm'

return config
