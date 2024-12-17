if test -z "$FZF_DEFAULT_OPTS"
    set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
end

if test -z "$CARAPACE_BRIDGES"
    set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
end

if command -v nvim > /dev/null
    set -Ux MANPAGER "nvim +Man!"
end
