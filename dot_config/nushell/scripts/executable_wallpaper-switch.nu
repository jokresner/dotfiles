#!/usr/bin/env nu

const image_exts = ["jpg" "jpeg" "png" "webp"]

def wallpaper-dirs [] {
  [
    ($"($env.HOME)/Nextcloud/Wallpaper")
    ($"($env.HOME)/Nextcloud/Wallpaper_32x9")
  ] | where {|dir| $dir | path exists }
}

def list-wallpapers [] {
  wallpaper-dirs
  | each {|dir| ls $dir }
  | flatten
  | where type == file
  | where {|file| (($file.name | path parse | get extension | str downcase) in $image_exts) }
  | sort-by name
}

def set-wallpaper [path: string] {
  if not ($path | path exists) {
    notify-send "Wallpaper not found" $path
    exit 1
  }

  awww img $path --transition-type grow --transition-duration 1
  $path | save -f $"($env.HOME)/.config/current-wallpaper"
  notify-send "Wallpaper applied" ($path | path basename)
}

def choose-wallpaper [] {
  let files = (list-wallpapers)
  if ($files | is-empty) {
    notify-send "No wallpapers found" "~/Nextcloud/Wallpaper or ~/Nextcloud/Wallpaper_32x9"
    exit 1
  }

  let choice = ($files | get name | path basename | str join "\n" | wofi --dmenu --prompt "Wallpaper")
  if ($choice == "") { exit }

  let selected = ($files | where {|file| ($file.name | path basename) == $choice } | get name | first)
  set-wallpaper $selected
}

def random-wallpaper [] {
  let files = (list-wallpapers)
  if ($files | is-empty) {
    notify-send "No wallpapers found" "~/Nextcloud/Wallpaper or ~/Nextcloud/Wallpaper_32x9"
    exit 1
  }

  let selected = ($files | shuffle | get name | first)
  set-wallpaper $selected
}

def current-wallpaper [] {
  let file = $"($env.HOME)/.config/current-wallpaper"
  if ($file | path exists) { open $file | str trim }
}

def main [
  path?: string
  --menu
  --random
  --set: string
  --current
  --list
] {
  if $list {
    list-wallpapers | get name | to json --raw
  } else if $current {
    current-wallpaper
  } else if $random {
    random-wallpaper
  } else if $set != null {
    set-wallpaper $set
  } else if $path != null {
    set-wallpaper $path
  } else {
    choose-wallpaper
  }
}
