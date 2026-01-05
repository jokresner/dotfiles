#-----------------
# History Settings
#-----------------

$env.config.history.file_format = "sqlite"

$env.config.history.max_size = 5_000_000

#-----------------------
# Miscellaneous Settings
#-----------------------

$env.config.show_banner = false

#-----------------------------
# Command Line Editor Settings
#-----------------------------

$env.config.edit_mode = "vi"

$env.config.buffer_editor = "nvim"

$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

#---------------------
# Completions Settings
#---------------------

$env.config.completions.algorithm = "fuzzy"

$env.config.completions.sort = "smart"

$env.config.completions.partial = true

$env.config.completions.use_ls_colors = true

let external_completer = {|spans|
	let carapace_completer = {|spans|
		carapace $spans.0 nushell ...$spans
		| from json
		| if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
	}
	let zoxide_completer = {|spans|
		$spans | skip 1 | zoxide query -l $in | lines | where {|x| $x != $env.PWD}
	}

	let expanded_alias = scope aliases | where name == $spans.0 | get -o 0 | get -o expansion
	let spans = if $expanded_alias != null  {
		$spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
	} else {
		$spans
	}

	match $spans.0 {
		__zoxide_z | __zoxide_zi => $zoxide_completer,
		_ => $carapace_completer
	} | do $in $spans
}

$env.config.completions.external = {
    enable: true,
    max_results: 50,
    completer: $external_completer
}

#---------------------
# External Completions
#---------------------

$env.config.completions.external.enable = true

$env.config.completions.external.max_results = 50

#------------------
# Terminal Settings
#------------------

$env.config.use_kitty_protocol = true

#----------------
# Datetime Format
#----------------

$env.config.datetime_format.table = "%d-%m-%Y %H:%M:%S"

$env.config.datetime_format.normal = "%d-%m-%Y %H:%M:%S"

#-----------------
# Filesize Display
#-----------------

$env.config.filesize.unit = "metric"

#-----------
# Asdf Shims
#-----------

let shims_dir = (
  if ( $env | get -o ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )

#------------
# Alias setup
#------------

alias ll = ls -l
alias la = ls -la
alias lg = lazygit
alias cocker = docker compose
alias ff = fastfetch
alias lj = lazyjj
alias vi = nvim
alias vim = nvim
alias v = nvim
alias vd = chezmoi edit # edit dotfiles
alias t = task
alias ag = ast-grep
alias zdev = zellij --layout yazineo
alias zterm = zellij --layout terminal

if ( which task | is-empty ) {
	alias task = go tool task
}

if ($nu.os-info.name == 'macos') {
	alias tailscale = /Applications/Tailscale.app/Contents/MacOS/Tailscale
}

#----------------------
# Environment Variables
#----------------------

$env.GCM_CREDENTIAL_STORE = "gpg"
$env.GPG_TTY = (tty)
$env.EDITOR = "nvim"

#----------------------
# External Dependencies
#----------------------

source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
source ~/.cache/atuin/init.nu

#----------------
# Nix Setup MacOS
#----------------

if ($nu.os-info.name == 'macos') {
  load-env (open /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | capture-foreign-env err> /dev/null)
}

#------
# Hooks
#------

source ~/.config/nushell/hooks/direnv.nu

#--------
# Scripts
# -------

source ~/.config/nushell/scripts/git/mod.nu

#----------
# Functions
#----------

# Returns a record of changed env variables after running a non-nushell script's contents (passed via stdin), e.g. a bash script you want to "source"
def capture-foreign-env [
    --shell (-s): string = /bin/sh
    # The shell to run the script in
    # (has to support '-c' argument and POSIX 'env', 'echo', 'eval' commands)
    --arguments (-a): list<string> = []
    # Additional command line arguments to pass to the foreign shell
] {
    let script_contents = $in;
    let env_out = with-env { SCRIPT_TO_SOURCE: $script_contents } {
        ^$shell ...$arguments -c `
        env
        echo '<ENV_CAPTURE_EVAL_FENCE>'
        eval "$SCRIPT_TO_SOURCE"
        echo '<ENV_CAPTURE_EVAL_FENCE>'
        env -0 -u _ -u _AST_FEATURES -u SHLVL` # Filter out known changing variables
    }
    | split row '<ENV_CAPTURE_EVAL_FENCE>'
    | {
        before: ($in | first | str trim | lines)
        after: ($in | last | str trim | split row (char --integer 0))
    }

    # Unfortunate Assumption:
    # No changed env var contains newlines (not cleanly parseable)
    $env_out.after
    | where { |line| $line not-in $env_out.before } # Only get changed lines
    | parse "{key}={value}"
    | transpose --header-row --as-record
    | if $in == [] { {} } else { $in }
}

def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

# zj: "Smart Zellij"
# 1. If argument provided: cd there, then open zellij
# 2. If no argument: open zellij in current dir
def --env zj [path?: string] {
    if ($path != null) {
        cd $path
    }
    let session_name = ($env.PWD | path basename)
    
    # Use -c to attach if exists (including EXITED) or create if it doesn't
    zellij attach -c $session_name
}

