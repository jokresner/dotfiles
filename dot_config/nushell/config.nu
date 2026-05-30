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

#------------
# Alias setup
#------------

alias ll = ls -l
alias la = ls -la
alias lm = ls -l | sort-by modified
alias lsd = ls -l | where type == dir
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

source $"($nu.cache-dir)/starship.nu"
source $"($nu.cache-dir)/carapace.nu"
source $"($nu.cache-dir)/zoxide.nu"
source $"($nu.cache-dir)/atuin.nu"
source $"($nu.cache-dir)/mise.nu"

#--------
# Scripts
# -------

overlay use ~/.config/nushell/scripts/git/mod.nu
overlay use ~/.config/nushell/scripts/alias-finder.nu

source ~/.config/nushell/scripts/commands.nu

#source ~/.config/nushell/vendor/autoload/wt.nu

#-----------------
# Completion files
#-----------------

source ~/.config/nushell/completions/pm.nu

#----------------
# Custom Banner
#----------------

def banner [] {
    # Catppuccin Mocha Palette Mappings (assuming terminal theme is set, otherwise approximations)
    let rosewater = (ansi -e '38;2;245;224;220m')
    let flamingo  = (ansi -e '38;2;242;205;205m')
    let pink      = (ansi -e '38;2;245;194;231m')
    let mauve     = (ansi -e '38;2;203;166;247m')
    let red       = (ansi -e '38;2;243;139;168m')
    let maroon    = (ansi -e '38;2;235;160;172m')
    let peach     = (ansi -e '38;2;250;179;135m')
    let yellow    = (ansi -e '38;2;249;226;175m')
    let green     = (ansi -e '38;2;166;227;161m')
    let teal      = (ansi -e '38;2;148;226;213m')
    let sky       = (ansi -e '38;2;137;220;235m')
    let sapphire  = (ansi -e '38;2;116;199;236m')
    let blue      = (ansi -e '38;2;137;180;250m')
    let lavender  = (ansi -e '38;2;180;190;254m')
    let text      = (ansi -e '38;2;205;214;244m')
    let overlay1  = (ansi -e '38;2;127;132;156m')
    let overlay0  = (ansi -e '38;2;108;112;134m')
    let reset     = (ansi reset)

    # Dynamic accent choice
    let accent = ([$mauve, $pink, $sapphire, $green, $peach] | shuffle | first)
    
    let sys_info = (sys host)
    let uptime = $sys_info.uptime
    let kernel = $sys_info.kernel_version
    # Calculate config load time (env.nu + config.nu execution)
    let startup = ((date now) - ($env.__NU_START_TIME? | default (date now)))
    let version = (version | get version)
    
    # Styling elements
    let pipe = $"($overlay0)│($reset)"
    let sep = $"($overlay1)::($reset)"
    let header_line = $"($overlay0)──────────────────────────────────($reset)"
    
    print ""
    print $" ($overlay0)╭──($reset) ($accent)SYSTEM_READY($reset) ($header_line)"
    print $" ($pipe)"
    print $" ($pipe)  ($lavender)HOST_ID($reset)    ($sep) ($text)($sys_info.hostname)($reset)"
    print $" ($pipe)  ($lavender)KERNEL_VER($reset) ($sep) ($text)($kernel)($reset)"
    print $" ($pipe)  ($lavender)UPTIME_DUR($reset) ($sep) ($text)($uptime)($reset)"
    print $" ($pipe)"
    print $" ($pipe)  ($lavender)SHELL_ENV($reset)  ($sep) ($text)nu ($version)($reset)"
    print $" ($pipe)  ($lavender)LOAD_TIME($reset)  ($sep) ($accent)($startup)($reset)"
    print $" ($pipe)"
    print $" ($overlay0)╰──($reset) ($header_line) ($accent)[OK]($reset)"
    print ""
}
banner
