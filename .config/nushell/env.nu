use std *

path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin

if ($nu.os-info.name == 'macos') {
	path add /opt/homebrew/bin
}

let local_env = '~/.config/nushell/env.local.nu' | path expand
if ($local_env | path exists) {
    . $local_env
}

# Load starship config
if command_exists(starship) {
	mkdir ~/.cache/starship
	starship init nu | save -f ~/.cache/starship/init.nu
}

# Load zoxide config
if command_exists(zoxide) {
	mkdir ~/.cache/zoxide
	zoxide init nushell --cmd cd | save -f ~/.cache/zoxide/init.nu
}

# Install Carapace Config
if command_exists(carapace) {
	$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
	mkdir ~/.cache/carapace
	carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}

def command_exists [cmd] {
 if (which $cmd | is-not-empty) {
	return true
 }
 return false
}
