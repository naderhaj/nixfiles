{ lib, pkgs, ... }:
let
  tmuxConf = lib.readFile ./default.conf;
in
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 100000;
    mouse = true;
    focusEvents = true; # lets nvim's autoread notice files changed on disk
    shortcut = "a";

    extraConfig = tmuxConf;
    plugins = with pkgs.tmuxPlugins; [
      cpu
      yank
      {
        plugin = dracula;
        # available plugins: battery, cpu-usage, git, gpu-usage, ram-usage, tmux-ram-usage, network, network-bandwidth, network-ping, ssh-session, attached-clients, network-vpn, weather, time, mpc, spotify-tui, kubernetes-context, synchronize-panes
        extraConfig = ''
          set -g @dracula-time-format "%d/%m/%Y %H:%M"
          set -g @dracula-plugins " time cpu-usage ram-usage battery"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
  };
}
