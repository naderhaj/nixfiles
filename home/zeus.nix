{ pkgs, config, ... }: {
  imports = [
    ../modules/home/home-manager.nix
    ../modules/home/common.nix
    ../modules/home/zsh
    ../modules/home/git.nix
    #../modules/home/hyprland
    ../modules/home/rofi
    ../modules/home/waybar
    ../modules/home/kitty.nix
    ../modules/home/tmux
    ../modules/home/ghostty
    ../modules/home/dunst.nix
    ../modules/home/personal.nix
  ];

  programs.git.settings.user.email = "hajlaoui.nader@gmail.com";

  home.stateVersion = "23.11";

  home.username = "zeus";
  home.homeDirectory = "/home/zeus";

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    home-manager
    networkmanagerapplet
    spotify
    #nerdfonts
    iosevka
    copyq
    bitwarden-cli
  ];

  # Cursor theme configuration
  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 32;
  };

  # GTK theme for better integration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 32;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.shellAliases = {
    open = "xdg-open";
    generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
  };

}
