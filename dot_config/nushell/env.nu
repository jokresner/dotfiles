$env.__NU_START_TIME = (date now)

use std *

path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin
path add ~/.local/share/bob/nvim-bin

$env.SHELL = '/usr/bin/nu'
$env.ZELLIJ_SOCKET_DIR = '/tmp/zellij'
$env.RAINFROG_CONFIG = '~/.config/rainfrog'

if ($nu.os-info.name == 'macos') {
	path add /opt/homebrew/bin
    path add /opt/nanobrew/prefix/bin
    path add ~/.orbstack/bin
	path add ~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin
    path add /Applications/lux-cli.app/Contents/MacOS
    path add /nix/var/nix/profiles/default/bin

	$env.SHELL = '/opt/homebrew/bin/nu'
    $env.XDG_RUNTIME_DIR = "/tmp/"
}

if not ($nu.cache-dir | path exists) {
    mkdir $"($nu.cache-dir)"
}

def create_cache [name: string, generator: closure] {
    let file = $"($nu.cache-dir)/($name).nu"
    if not ($file | path exists) {
        do $generator | save -f $file
    }
}

create_cache starship { starship init nu }
create_cache zoxide { zoxide init nushell }
create_cache atuin { atuin init nu }
create_cache carapace { 
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'; 
    ^carapace _carapace nushell | str replace '$env.config = $current' '$env.config = ($env.config? | default {} | merge $current)'
}
create_cache mise { ^mise activate nu }
