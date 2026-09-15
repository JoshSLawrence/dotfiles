source ~/.exports
source ~/.aliases

# mise handles oh-my-posh on PATH must be for prompt setup
eval "$(~/.local/bin/mise activate zsh)"

# ── System light/dark theme integration ─────────────────────────────────────
# Ghostty, Neovim, and herdr follow the OS appearance on their own. The tools
# below can't hot-swap, so they pick their theme here at shell start based on
# ~/.config/theme/theme-detect.sh (cross-platform: macOS, WSL, Linux).
THEME_DIR="$HOME/.config/theme"
THEME_MODE="$("$THEME_DIR/theme-detect.sh" 2>/dev/null || echo dark)"

# Prompt setup: tokyonight-night for dark, catppuccin latte for light.
if [[ "$THEME_MODE" == "light" ]]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_latte_custom.omp.json)"
else
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/tokyonight-night.omp.json)"
fi

# lazygit: layer the matching theme overlay on top of the base config.
if [[ "$THEME_MODE" == "light" ]]; then
  export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-latte.yml"
else
  export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-tokyonight.yml"
fi

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

# pnpm
export PNPM_HOME="/Users/josh/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
