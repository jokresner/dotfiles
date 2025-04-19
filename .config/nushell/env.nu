use std *

path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin

if ($nu.os-info.name == 'macos') {
	path add /opt/homebrew/bin
}

const local_env = '~/.config/nushell/env.local.nu' | path expand
if ($local_env | path exists) {
	source $local_env
}

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

mkdir ~/.cache/zoxide
zoxide init nushell --cmd cd | save -f ~/.cache/zoxide/init.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
