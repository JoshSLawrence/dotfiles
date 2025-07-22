source ~/.exports
source ~/.aliases

# Prompt setup
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_custom.omp.json)"

# zoxide should always be setup after exports, aliases, prompt
eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"

# Completion should always be configured after exports, aliases, prompt, and misc evals
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# zsh-syntax-highlighting should always be sourced last
if [[ "$(uname)" == "Darwin" ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "$(uname)" == "Linux" ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Something fun
fortune | cowsay
