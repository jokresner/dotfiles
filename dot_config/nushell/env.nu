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
def --env apply_mise_env [mise_bin: string] {
    let vars = (
        ^$mise_bin hook-env -s nu
        | from csv --noheaders --no-infer
        | rename 'op' 'name' 'value'
    )

    for var in $vars {
        if $var.op == "set" {
            if ($var.name | str uppercase) == "PATH" {
                $env.PATH = ($var.value | split row (char esep))
            } else {
                load-env {($var.name): $var.value}
            }
        } else if $var.op == "hide" and $var.name in $env {
            hide-env -i $var.name
        }
    }
}

def --env add-hook [field: cell-path new_hook: any] {
    let field = $field | split cell-path | update optional true | into cell-path
    let old_config = $env.config? | default {}
    let old_hooks = $old_config | get $field | default []
    $env.config = ($old_config | upsert $field ($old_hooks ++ [$new_hook]))
}

let mise_candidates = if ($nu.os-info.name == "macos") {
    ["/opt/homebrew/bin/mise" "~/.local/bin/mise" "mise"]
} else {
    ["~/.local/bin/mise" "/home/linuxbrew/.linuxbrew/bin/mise" "mise"]
}

let mise_bin = (
    $mise_candidates
    | each {|candidate|
        if $candidate == "mise" {
            if (which mise | is-empty) { null } else { "mise" }
        } else {
            let expanded = ($candidate | path expand)
            if ($expanded | path exists) { $expanded } else { null }
        }
    }
    | compact
    | get 0?
)

if $mise_bin != null {
    $env.MISE_SHELL = "nu"
    apply_mise_env $mise_bin
    let mise_hook = {
        condition: { "MISE_SHELL" in $env }
        code: { apply_mise_env $mise_bin }
    }
    add-hook hooks.pre_prompt $mise_hook
    add-hook hooks.env_change.PWD $mise_hook
}
