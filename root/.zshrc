source ~/.exports
source ~/.aliases

# Sensitive exports - in .gitignore
if [ -f "~/.exports_ignored" ]; then
  source ~/.exports_ignored
fi

# mise handles oh-my-posh on PATH must be for prompt setup
eval "$(~/.local/bin/mise activate zsh)"

# Prompt setup
# - Mocha
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_mocha_custom.omp.json)"
# - Latte
# eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_latte_custom.omp.json)"

# zoxide should always be setup after exports, aliases, prompt
eval "$(zoxide init zsh)"

# Use emacs mode for line editing (override tmux vi mode)
bindkey -e

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
