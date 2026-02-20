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
        env`
    }
    | split row '<ENV_CAPTURE_EVAL_FENCE>'
    | {
        before: ($in | first | str trim | lines)
        after: ($in | last | str trim | lines)
    }

    # Unfortunate Assumption:
    # No changed env var contains newlines (not cleanly parseable)
    $env_out.after
    | where { |line| $line not-in $env_out.before } # Only get changed lines
    | parse "{key}={value}"
    | where key not-in [ "_" "SHLVL" "_AST_FEATURES" ] # Filter out shell internal vars
    | transpose --header-row --as-record
    | if $in == [] { {} } else { $in }
}

def --env y [...args] {
	let tmp = ($nu.temp-path | path join $"yazi-cwd.(random chars).txt")
	touch $tmp
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

def man [topic: string] {
    ^man $topic | bat -l man -p
}

