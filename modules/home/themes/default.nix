{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    pop-gtk-theme
    pop-icon-theme
  ];

  gtk = {
    enable = true;
    font.name = "JetBrainsMono 11";
    theme = {
      name = "Pop";
    };
    cursorTheme = {
      name = "popc";
      size = 24;
    };
    iconTheme.name = "Pop";
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Pop";
    XCURSOR_SIZE = "24";
  };
}
