#!/usr/bin/env nu

if (pgrep wofi | is-empty) {
  wofi --show drun --normal-window
} else {
  pkill wofi
}
