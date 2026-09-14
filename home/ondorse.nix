{ pkgs, inputs, ... }:

{
  imports = [
    ../modules/home/home-manager.nix
    ../modules/home/common.nix
    ../modules/home/zsh
    #../modules/home/fish.nix
    ../modules/home/git.nix
    ../modules/home/tmux
    ../modules/home/ghostty
    ../modules/home/firefox.nix

  ];

  home.homeDirectory = "/Users/naderh";
  home.username = "naderh";

  programs.htop.enable = true;

  # Pin nix registry so `nix search` / `nix shell` use our locked nixpkgs
  # (also pinned system-wide via nix-darwin; kept here as belt-and-suspenders)
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  programs.git.settings.user.email = "hajlaoui.nader@gmail.com";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/default.nix
    # nerdfonts
    #bitwarden-cli # it causes an error
    mise
    uv
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

}
