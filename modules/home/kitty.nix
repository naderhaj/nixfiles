{ pkgs, specialArgs, ... }:
{

  programs.kitty = {
    enable = true;

    extraConfig = ''
      font_size 12.0

      font_family      Iosevka 
      bold_font        Iosevka Bold
      italic_font      Iosevka Italic
      bold_italic_font Iosevka Bold Italic


      copy_on_select yes

      # Set transparency
      background_opacity 0.8

    '';

  };

}
