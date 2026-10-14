{ config, pkgs, ... }:
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Bluetooth support
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable XDG portal for screen sharing and other features
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard # Clipboard for Wayland
    wl-clip-persist # Keep clipboard after app closes
    cliphist # Clipboard manager for Wayland

    # Screenshots and screen recording
    grim # Screenshot utility
    slurp # Screen area selection
    swappy # Screenshot editor
    wf-recorder # Screen recorder

    # Notifications
    dunst # Notification daemon
    libnotify # For notify-send

    # File managers
    thunar # GUI file manager
    thunar-archive-plugin
    thunar-volman

    # Image viewer and wallpaper
    imv # Wayland image viewer
    swww # Wallpaper daemon for Wayland

    # Application launchers
    rofi # Rofi (includes Wayland support)

    # Audio/Media control
    pavucontrol # Audio control GUI
    playerctl # Media player control
    pamixer # Audio mixer

    # Brightness control
    brightnessctl

    # Network management
    networkmanagerapplet

    # System monitoring
    btop # Beautiful system monitor

    # Polkit agent for authentication
    polkit_gnome

    # Screen locker
    swaylock-effects # Beautiful lock screen

    # Idle manager
    swayidle # Auto-lock and sleep

    # Additional utilities
    killall
    wget
    curl
    wev # Wayland event viewer (for testing keys)

    # Cursor themes
    bibata-cursors # Beautiful modern cursor theme
    catppuccin-cursors.mochaDark # Matches our color scheme
  ];

  # Enable polkit
  security.polkit.enable = true;

  # Auto-mount USB drives
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Fonts for better display
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    material-design-icons
  ];

  # Enable dconf for GTK applications
  programs.dconf.enable = true;

  # Set environment variables for Hyprland
  environment.sessionVariables = {
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";

    # Firefox Wayland
    MOZ_ENABLE_WAYLAND = "1";

    # Qt Wayland
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # SDL Wayland
    SDL_VIDEODRIVER = "wayland";

    # Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # XDG
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
