# Update PATH
use std *
path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin
path add /opt/homebrew/bin

source ~/.config/nushell/env.local.nu

# Install Starship Config
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Install Zoxide Config 
mkdir ~/.cache/zoxide
zoxide init nushell --cmd cd | save -f ~/.cache/zoxide/init.nu

# Install Carapace Config
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
