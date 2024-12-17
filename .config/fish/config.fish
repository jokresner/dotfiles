function fish_greeting
    fastfetch 
end

set -U fish_path $HOME/.config/fish

if status is-interactive
    # pyenv
    set -Ux PYENV_ROOT $HOME/.pyenv
    set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths

    # pnpm
    set -gx PNPM_HOME "/home/johannes/.local/share/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
    end
end

source $fish_path/plugins.fish
source $fish_path/aliases.fish
source $fish_path/env.fish

if command -q fzf
    fzf --fish | source
end

if command -q starship
    starship init fish | source
    enable_transience
else
    curl -sS https://starship.rs/install.sh | sh
end

if command -q pyenv
    pyenv init - | source
end

if functions -q nvm
    nvm use latest --silent
end

if command -q zoxide
    zoxide init --cmd cd fish | source
end

if command -q carapace
    mkdir -p ~/.config/fish/completions
    carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish
    carapace _carapace | source
end
