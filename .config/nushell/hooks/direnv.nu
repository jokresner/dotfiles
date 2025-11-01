# Source this file once to install the .env-on-cd hook.
#   source ~/.config/nushell/dotenv_pwd_hook.nu

# Define a hook entry (use underscores in var names)
let dotenv_pwd_hook = {
  # This closure gets the previous and new PWD values
  condition: {|before, after|
    ($before != $after) and ($after | path join ".env" | path exists)
  }
  # Keep the code in a single string (hooks expect strings here)
  code: "open .env
    | lines
    | where ($it | str trim | is-not-empty)                # drop empty lines
    | where not ($it | str trim | str starts-with '#')     # drop comments
    | parse -r '^(?P<k>[A-Za-z_][A-Za-z0-9_]*)=(?P<v>.*)$' # KEY=VALUE
    | reduce -f {} {|row, acc|
        let val = ($row.v | str trim | str trim -c '\"' | str trim -c \"'\")
        $acc | upsert $row.k $val
      }
    | load-env"
}

# Append to the existing PWD hook list (create it if missing)
$env.config.hooks.env_change.PWD = (
  ($env.config.hooks.env_change.PWD | default [])
  | append $dotenv_pwd_hook
)

