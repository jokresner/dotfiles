#-------------------
# Autostart Commands
#-------------------

if (which zellij | is-empty) {
	echo "Zellij not found, skipping autostart."
} else {
	zellij --layout ~/.config/zellij/layouts/default.kdl
}

