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

	let expanded_alias = scope aliases | where name == $spans.0 | get -i 0 | get -i expansion
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

$env.config.filesize.metric = true

$env.config.filesize.format = "auto"

#--------------------------------
# Loading External Configurations
#--------------------------------

use ~/.config/nushell/aliases.nu

#-------------
# Load Plugins
#-------------

#plugin add ~/.cargo/bin/nu_plugin_file
#plugin add ~/.cargo/bin/nu_plugin_gstat
#plugin add ~/.cargo/bin/nu_plugin_highlight

#----------------------
# External Dependencies
#----------------------

use ~/.cache/starship/init.nu
