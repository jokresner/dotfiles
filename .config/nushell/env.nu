use std *

path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin

if ($nu.os-info.name == 'macos') {
	path add /opt/homebrew/bin
	path add ~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin
}

# load plugins
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

mkdir ~/.cache/zoxide
zoxide init nushell | save -f ~/.cache/zoxide/init.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/atuin
atuin init nu | save --force ~/.cache/atuin/init.nu

$env.PNPM_HOME = "~/.local/share/pnpm"
$env.PATH = ($env.PATH | split row (char esep) | prepend $env.PNPM_HOME )
path add $env.PNPM_HOME
