#!/usr/bin/env nu

def apply-theme [selected: string] {
  let choice = if $selected == "auto" {
    let color_scheme = (bash -lc "gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true" | str trim)

    if ($color_scheme | str contains "prefer-dark") {
      "mocha"
    } else if ($color_scheme | str contains "prefer-light") {
      "latte"
    } else {
      let hour = (date now | format date "%H" | into int)
      if ($hour >= 19 or $hour < 7) { "mocha" } else { "latte" }
    }
  } else {
    $selected
  }

  let home = $env.HOME
  let base = $"($home)/.config/themes/catppuccin/($choice)"

  if not ($base | path exists) {
    notify-send "Theme not found" $base
    exit 1
  }

  let gtk_theme = (open $"($base)/gtk-theme-name" | str trim)

  $choice | save -f $"($home)/.config/current-theme"

  # Hypr palette. Configs must source ~/.config/hypr/theme.conf to use this.
  ln -sfn $"($base)/hypr.conf" $"($home)/.config/hypr/theme.conf"

  # Quickshell singleton theme.
  cp -f $"($base)/quickshell/Theme.qml" $"($home)/.config/quickshell/Theme/Theme.qml"

  # Wofi colors.
  if ($"($home)/.config/wofi" | path exists) {
    ln -sfn $"($base)/wofi.css" $"($home)/.config/wofi/style.css"
  }

  # Mako colors, only if mako config dir exists.
  if ($"($home)/.config/mako" | path exists) {
    ln -sfn $"($base)/mako.conf" $"($home)/.config/mako/config"
    if (which makoctl | is-not-empty) { makoctl reload }
  }

  # GTK theme, only if installed.
  if ($"/usr/share/themes/($gtk_theme)" | path exists) {
    gsettings set org.gnome.desktop.interface gtk-theme $gtk_theme
    let color_scheme = if $choice == "mocha" { "prefer-dark" } else { "prefer-light" }
    gsettings set org.gnome.desktop.interface color-scheme $color_scheme

    if ($"($home)/.config/gtk-3.0/settings.ini" | path exists) {
      bash -lc $'sed -i "s/^gtk-theme-name=.*/gtk-theme-name=($gtk_theme)/" "$HOME/.config/gtk-3.0/settings.ini"'
    }
  } else {
    notify-send "GTK theme not installed" $gtk_theme
  }

  hyprctl reload
  bash -lc "pkill quickshell 2>/dev/null; setsid quickshell >/tmp/quickshell-theme-switch.log 2>&1 < /dev/null &"
  notify-send "Theme applied" $"($choice) via ($selected)"
}

def main [
  mode?: string
  --auto
  --mocha
  --latte
] {
  let valid = ["auto" "mocha" "latte"]
  let selected = if $auto {
    "auto"
  } else if $mocha {
    "mocha"
  } else if $latte {
    "latte"
  } else if $mode == null {
    ($valid | str join "\n" | wofi --dmenu --prompt "Theme")
  } else {
    $mode
  }

  if ($selected not-in $valid) { exit }
  apply-theme $selected
}
