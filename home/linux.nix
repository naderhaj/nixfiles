{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    ./modules/zsh
    ./modules/git.nix
  ];

  home.stateVersion = "23.05";

  home.username = "nhajlaoui";
  home.homeDirectory = "/home/nhajlaoui";

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "Iosevka"
        "FiraMono"
        "JetBrainsMono"
        "SourceCodePro"
      ];
    })
  ];

}
