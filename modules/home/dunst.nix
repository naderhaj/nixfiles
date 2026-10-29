{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;

    # home-manager derives settings.global.icon_path from this (all icon
    # categories, with hicolor as fallback).
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      size = "48x48";
    };

    settings = {
      global = {
        # Display
        monitor = 0;
        follow = "mouse";

        # Geometry
        width = "(300, 400)";
        height = 300;
        origin = "top-right";
        offset = "20x50";

        # Progress bar
        progress_bar = true;
        progress_bar_height = 14;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 300;
        progress_bar_max_width = 400;
        progress_bar_corner_radius = 5;

        # Appearance
        transparency = 10;
        separator_height = 2;
        padding = 20;
        horizontal_padding = 20;
        text_icon_padding = 20;
        frame_width = 2;
        frame_color = "#89b4fa";
        separator_color = "frame";
        sort = true;

        # Font
        font = "Iosevka 14";
        line_height = 4;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        # Icons
        icon_position = "left";
        min_icon_size = 48;
        max_icon_size = 64;

        # History
        sticky_history = true;
        history_length = 20;

        # Misc
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
        browser = "${pkgs.firefox}/bin/firefox";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 16;
        ignore_dbusclose = false;

        # Mouse
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
      };

      # Urgency levels
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#89b4fa";
        timeout = 4;
      };

      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#89b4fa";
        timeout = 8;
      };

      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#f38ba8";
        frame_color = "#f38ba8";
        timeout = 0;
      };

      # Custom rules for specific notifications
      volume = {
        appname = "audio";
        history_ignore = true;
        timeout = 2;
      };

      brightness = {
        appname = "brightness";
        history_ignore = true;
        timeout = 2;
      };

      media = {
        appname = "media";
        history_ignore = true;
        timeout = 3;
      };
    };
  };

  # Make sure icon theme is available
  home.packages = with pkgs; [
    papirus-icon-theme
  ];
}
