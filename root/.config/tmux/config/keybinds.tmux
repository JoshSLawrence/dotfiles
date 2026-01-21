# Set prefix
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Shift Alt vim keys to switch windows
bind -n M-H previous-window
bind -n M-L next-window

# Open lazygit in a popup window
bind g display-popup -E -d "#{pane_current_path}" -h 90% -w 90% lazygit

# Make copy mode like visual selection mode in vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
