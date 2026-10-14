{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi; # Rofi now includes Wayland support

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];

    font = "Iosevka 20"; # Larger for HiDPI
    terminal = "${pkgs.ghostty}/bin/ghostty";
    theme = "catppuccin-mocha"; # Use our custom theme

    extraConfig = {
      modi = "drun,run,window,filebrowser";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " Apps";
      display-run = " Run";
      display-window = "󰖯 Windows";
      display-filebrowser = " Files";
      drun-display-format = "{name}";
      window-format = "{w}  {c}  {t}";
      window-thumbnail = true;

      # Vim-style keybindings
      kb-row-up = "Up,Control+k,Alt+k";
      kb-row-down = "Down,Control+j,Alt+j";
      kb-accept-entry = "Return,KP_Enter";
      kb-remove-to-eol = "";
      kb-mode-next = "Shift+Right,Control+Tab";
      kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab";
      kb-remove-char-back = "BackSpace";
    };
  };

  # Rofi theme configuration
  home.file.".config/rofi/catppuccin-mocha.rasi".text = ''
    * {
      bg: #1e1e2e;
      bg-alt: #313244;
      bg-selected: #45475a;
      fg: #cdd6f4;
      fg-alt: #bac2de;
      border-color: #89b4fa;
      selected-color: #89b4fa;

      background-color: @bg;
      text-color: @fg;
      border: 0;
      margin: 0;
      padding: 0;
      spacing: 0;
    }

    window {
      width: 40%;
      background-color: @bg;
      border: 3px;
      border-color: @border-color;
      border-radius: 16px;
      padding: 20px;
    }

    mainbox {
      background-color: transparent;
      children: [inputbar, listview];
    }

    inputbar {
      background-color: @bg-alt;
      children: [prompt, entry];
      border-radius: 12px;
      padding: 12px;
      margin: 0 0 15px 0;
    }

    prompt {
      background-color: transparent;
      text-color: @selected-color;
      padding: 0 10px 0 0;
      font: "Iosevka Bold 20";
    }

    entry {
      background-color: transparent;
      text-color: @fg;
      placeholder: "Search...";
      placeholder-color: @fg-alt;
      padding: 0;
    }

    listview {
      background-color: transparent;
      padding: 0;
      lines: 8;
      columns: 1;
      scrollbar: false;
    }

    element {
      padding: 12px;
      border-radius: 10px;
      background-color: transparent;
      text-color: @fg-alt;
      margin: 2px 0;
    }

    element selected {
      background-color: @bg-selected;
      text-color: @fg;
    }

    element selected active {
      background-color: @selected-color;
      text-color: @bg;
    }

    element-icon {
      size: 2.5em;
      padding: 0 10px 0 0;
      background-color: transparent;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
      vertical-align: 0.5;
    }
  '';

  # Rofi scripts for WiFi and Bluetooth
  home.file.".local/bin/rofi-wifi-menu" = {
    source = ./rofi-wifi-menu.sh;
    executable = true;
  };

  home.file.".local/bin/rofi-bluetooth" = {
    source = ./rofi-bluetooth.sh;
    executable = true;
  };

  # Add to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Additional rofi tools
  home.packages = with pkgs; [
    xdotool # For emoji insertion (works with XWayland)
    wtype # Wayland typing tool (alternative)
    rofimoji # Emoji picker
    networkmanager # For nmcli command
  ];
}
