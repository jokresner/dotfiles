let dotenv_pwd_hook = {
  if (which direnv | is-empty) {
    return
  }

  direnv export json | from json | default {} | load-env
}

# Append to the existing PWD hook list (create it if missing)
$env.config.hooks.env_change.PWD = (
  ($env.config.hooks.env_change.PWD | default [])
  | append $dotenv_pwd_hook
)

