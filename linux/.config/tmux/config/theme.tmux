set-option -g status-position bottom


set -ogq @catppuccin_flavour 'mocha'
set -ogq @catppuccin_window_status_style "basic"

set -ogq @catppuccin_window_current_text ""
set -ogq @catppuccin_window_text " #W | #I"
set -ogq @catppuccin_window_current_number "#W | #I "
set -ogq @catppuccin_window_number ""
set -g @catppuccin_date_time_color "#{@thm_blue}"
set -g @catppuccin_user_color "#{@thm_blue}"

set -g @catppuccin_window_number_position "right"
set -g @catppuccin_window_current_text_color ""
set -g @catppuccin_window_current_number_color "#fab387"
set -g @catppuccin_window_text_color "#313244"
set -g @catppuccin_window_number_color ""

set -g @catppuccin_status_left_separator "█"
set -g @catppuccin_status_right_separator "█"

set -g @catppuccin_window_status_style "custom"
set -g @catppuccin_window_right_separator ""
set -g @catppuccin_window_left_separator ""

set -g @catppuccin_date_time_text " %b %d %l:%M %p"
set -g @catppuccin_status_background "none"

# Enable catppuccin and built-in status moduels (run MUST be first)
run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux

set -g status-right-length 100
set -g status-right "#{E:@catppuccin_status_user}#{E:@catppuccin_status_date_time}"
set -g status-left ""
