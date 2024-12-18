# Update PATH
use std *
path add ~/.cargo/bin
path add ~/.local/bin

path add /opt/homebrew/bin

# Install Starship Config
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Install Carapace Config
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
