{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # ./modules/home-manager.nix
    # ./modules/common.nix
    # ./modules/git.nix
  ];

  home.stateVersion = "23.05";

  home.username = "nha";
  # home.homeDirectory = "/home/nha";

  # home.packages = with pkgs; [
  #    (nerdfonts.override { fonts = [ "FiraCode"
  #         "FiraMono"
  #         "JetBrainsMono"
  #         "SourceCodePro" ]; })
  # ];

}
