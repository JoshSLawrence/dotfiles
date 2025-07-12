source ~/.exports
source ~/.aliases
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_custom.omp.json)"
eval "$(zoxide init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fortune | cowsay
