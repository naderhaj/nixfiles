{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Copy all Hyprland configuration files to ~/.config/hypr/
  home.file = {
    ".config/hypr/hyprland.conf".source = ./hyprland.conf;
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/autostart.conf".source = ./autostart.conf;
    ".config/hypr/environment.conf".source = ./environment.conf;
    ".config/hypr/input.conf".source = ./input.conf;
    ".config/hypr/general.conf".source = ./general.conf;
    ".config/hypr/decoration.conf".source = ./decoration.conf;
    ".config/hypr/animations.conf".source = ./animations.conf;
    ".config/hypr/binds.conf".source = ./binds.conf;
    ".config/hypr/windowrules.conf".source = ./windowrules.conf;
  };

  # Additional Wayland-specific packages
  home.packages = with pkgs; [
    hyprpicker # Color picker for Hyprland
    hyprshot # Screenshot tool for Hyprland
    # Note: Using rofi window mode for Alt+Tab instead of separate switcher
  ];
}
