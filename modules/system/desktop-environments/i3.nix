{ config, pkgs, ... }:
{
  services.blueman.enable = true;
  # X11 configuration for i3
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
      options = "compose:ralt";
    };

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      # i3-specific display configuration
      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2256x1504_60.00"  287.00  2256 2424 2664 3072  1504 1507 1517 1559 -hsync +vsync
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual1 2256x1504_60.00
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual1 --mode 2256x1504_60.00
      '';
    };

    monitorSection = ''
      DisplaySize 344 229
    '';

    # 2.8k screen configuration
    #displayManager = {
    ## i3-specific display configuration for 2.8K screen
    #setupCommands = ''
    #${pkgs.xorg.xrandr}/bin/xrandr --newmode "2880x1800_60.00"  369.00  2880 3096 3408 3936  1800 1803 1813 1862 -hsync +vsync
    #${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual1 2880x1800_60.00
    #${pkgs.xorg.xrandr}/bin/xrandr --output Virtual1 --mode 2880x1800_60.00
    #'';
    #};

    #monitorSection = ''
    #DisplaySize 406 254
    #'';
    # i3 window manager
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        # Add i3-specific packages here
        rofi
        polybar
        nitrogen
        scrot
      ];
    };
  };

  # Display manager configuration
  services.displayManager = {
    defaultSession = "none+i3";
    autoLogin = {
      enable = true;
      user = "nader";
    };
  };

  # i3-specific packages
  environment.systemPackages = with pkgs; [
    # i3 essential packages
    dmenu
    i3status
    i3lock
    i3blocks

    # Clipboard manager for i3
    copyq
    clipmenu

    # Additional i3 utilities
    feh # image viewer and wallpaper setter
    arandr # GUI for xrandr
    pavucontrol # audio control
    networkmanagerapplet
  ];

  # Enable compositor for i3
  services.picom = {
    enable = true;
    fade = true;
    shadow = true;
    fadeDelta = 4;
  };
}
