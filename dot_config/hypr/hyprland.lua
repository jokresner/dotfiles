-- Migrated from hyprland.conf for Hyprland 0.55+.
-- Keep this file active as ~/.config/hypr/hyprland.lua.

local hypr_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr"

----------------
--- MONITORS ---
----------------

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

dofile(hypr_dir .. "/monitors.lua")

-------------------
--- MY PROGRAMS ---
-------------------

local terminal = "ghostty"
local fileManager = "nemo"
local menu = "qs ipc call appLauncher open"
local clipboard = "qs ipc call clipboardPicker open"
local lock = "hyprlock"
local powermenu = "qs ipc call powerMenu open"

-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("trayscale --hide-window")
	hl.exec_cmd("owncloud")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("easyeffects --service-mode")
	hl.exec_cmd("lxqt-polkit-agent")
	hl.exec_cmd("/home/johannes/.local/bin/mcpproxy")
	hl.exec_cmd("awww-daemon")
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct:qt6ct")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("MOZ_DBUS_REMOTE", "1")
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_FORCE_DPI", "physical")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("EGL_PLATFORM", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("TERM", "ghostty")
hl.env("TERMINAL", "ghostty")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GTK_THEME", "catppuccin-mocha-mauve-standard+default")
hl.env("PROTON_DLSS_UPGRADE", "1")

---------------------
--- LOOK AND FEEL ---
---------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		col = {
			active_border = "rgb(f38ba8)",
			inactive_border = "rgb(45475a)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 2,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "slave",
	},
	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.9,
		direction = "right",
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})

hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

hl.workspace_rule({
	workspace = "2",
	layout_opts = { direction = "right" },
})

-------------
--- INPUT ---
-------------

hl.config({
	input = {
		kb_layout = "de",
		kb_model = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-------------------
--- KEYBINDINGS ---
-------------------

local mainMod = "SUPER"

-- Apps
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + H", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipboard))

-- Layout
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))

-- Theme / wallpaper switchers
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("qs ipc call themeSwitcher open"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs ipc call wallpaperSwitcher open"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("qs ipc call wallpaperSwitcher random"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true })

-- Media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

hl.window_rule({
	match = { class = "vivaldi-snapshot" },
	opacity = "1.0 override 1.0 override",
})

local quickshell_popups = {
	"Theme Switcher",
	"Wallpaper Switcher",
	"Power Menu",
	"Clipboard Picker",
	"App Launcher",
}

for _, title in ipairs(quickshell_popups) do
	hl.window_rule({
		match = { class = "^(org.quickshell)$", title = "^(" .. title .. ")$" },
		float = true,
	})
	hl.window_rule({
		match = { class = "^(org.quickshell)$", title = "^(" .. title .. ")$" },
		decorate = false,
	})
	hl.window_rule({
		match = { class = "^(org.quickshell)$", title = "^(" .. title .. ")$" },
		rounding = 20,
	})
end
