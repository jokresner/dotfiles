alias cocker='docker compose'

if command -v lazygit > /dev/null
    alias lg=lazygit
end

if command -v nvim > /dev/null
    alias vim=nvim
    alias vi=nvim
end

if command -v fastfetch > /dev/null
    alias fetch=fastfetch
    alias ff=fastfetch
end

if command -v eza > /dev/null
    alias ls='eza --icons -F -H --group-directories-first --git -1'
    alias ll='ls -alF'
    alias la='ls -la'
    alias lt='ls -T'
    alias l='eza -l --git'
end

if command -v batcat > /dev/null
    alias bat=batcat
end

if command -v bat > /dev/null
    alias cat=bat
end

if command -v go-task > /dev/null
    alias task=go-task
end
