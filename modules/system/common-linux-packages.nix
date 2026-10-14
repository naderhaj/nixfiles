{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.vim # text editor
    pkgs.libnotify # notification daemon
    pkgs.home-manager # Home Manager for user configuration
    pkgs.flameshot # screenshot utility
    pkgs.cheese # webcam utility
    pkgs.vlc # media player
    pkgs.feh # image viewer
    pkgs.smile # emoji picker
    pkgs.powertop # power management tool
    pkgs.krita # digital painting
    pkgs.gnumake

    #pkgs.appimage-run
    # set when darwin gets updated, and ghostty is no more marked as broken
    #pkgs.ghostty
  ];

  # allow dynamic linked packages to be used
  programs.nix-ld.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # register AppImage support
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [
      "ghostty.desktop"
    ];
  };
}
