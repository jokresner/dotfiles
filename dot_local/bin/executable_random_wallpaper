#!/usr/bin/env bash

DIR="$HOME/Nextcloud/Wallpaper"
INTERVAL=300   # seconds between changes

swww init 2>/dev/null

while true; do
  img="$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)"
  [ -n "$img" ] && swww img "$img" --transition-type any --transition-duration 1
  sleep "$INTERVAL"
done

