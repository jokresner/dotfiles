$env.__NU_START_TIME = (date now)

use std *

path add ~/.cargo/bin
path add ~/.local/bin
path add ~/go/bin
path add ~/.local/share/bob/nvim-bin

$env.SHELL = '/usr/bin/nu'

if ($nu.os-info.name == 'macos') {
	path add /opt/homebrew/bin
    path add ~/.orbstack/bin
	path add ~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin
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
create_cache carapace { $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'; carapace _carapace nushell }
create_cache mise { ^mise activate nu }
