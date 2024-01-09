{ pkgs, ... }:
let
  # tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin {
  #   pluginName = "tmux-super-fingers";
  #   version = "unstable-2023-01-06";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "artemave";
  #     repo = "tmux_super_fingers";
  #     rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
  #     sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
  #   };
  # };
in {
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    keyMode = "vi";
    # address vim mode switching delay
    # https://superuser.com/a/252717/65504
    escapeTime = 0;
    # start window number counting from 1 (instead of 0)
    baseIndex = 1;
    plugins = with pkgs;
      [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
set -g @catppuccin_flavour 'mocha'

set -g @catppuccin_window_left_separator "█"
set -g @catppuccin_window_right_separator "█"
set -g @catppuccin_window_number_position "left"
set -g @catppuccin_window_middle_separator "█ "

set -g @catppuccin_status_modules_right "host date_time"
set -g @catppuccin_status_left_separator  ""
set -g @catppuccin_status_right_separator " "
set -g @catppuccin_status_right_separator_inverse "yes"
set -g @catppuccin_status_fill "all"
set -g @catppuccin_status_connect_separator "no"
set -g @catppuccin_date_time_text "%H:%M:%S"
          '';
        }
      ];
    extraConfig = ''
# do not notify me about any activity
set -g monitor-activity off
# focus events enabled for terminals that support them
set -g focus-events on
# tmux messages are displayed for 3 seconds
set -g display-time 3000
set -g status on
set -g set-titles on
# interval for refreshing statusline
set -g status-interval 5
set -g visual-activity on
set -g status-position bottom
# renumber windows when some was deleted
set -g renumber-windows on
# terminal window name
set -g set-titles-string '#{b:pane_current_path}'
# upgrading current terminal
set -g terminal-overrides ",xterm-256color:Tc"
# no spaces between windows in statusline
set -g window-status-separator ""
# automatically set current window's name to current directory
set -g status-interval 1
set -g automatic-rename on
set -g automatic-rename-format '#(basename "$(git -C #{pane_current_path} rev-parse --show-toplevel 2>/dev/null || echo "#{pane_current_path}")")'

# unbinding unused keys
unbind &
unbind .
unbind ,
unbind C-b
unbind C-n
unbind C-p
unbind z
unbind x
unbind c

# prefix is C-t
set -g prefix C-t

# navigating across panes via hjkl
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# resizing panes via shift+hjkl
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# zoom pane
bind e resize-pane -Z

# killing current pane with c-k
bind C-k kill-pane

# new window
bind c new-window

# move window
bind M command-prompt "move-window -t '%%'"

# rename window
bind R command-prompt -I "rename-window #W"

# c-v/c-h to split horizontally/vertically
bind C-v split-window -h -c "#{pane_current_path}"
bind C-h split-window -v -c "#{pane_current_path}"

# n/p to move next/previous
bind n next-window
bind p previous-window

# inner tmux session prefix
bind -n C-a send-prefix

# reload tmux configuration
bind C-e source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded"
    '';
  };
}
