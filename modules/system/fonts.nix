{ pkgs, ... }:

# Fonts shared by every host. `fonts.packages` is spelled the same way in
# NixOS and nix-darwin, so this module works unmodified on zeus and the Macs.
#
# Iosevka Nerd Font is the terminal font selected in
# modules/home/ghostty/ghostty.conf — keep it installed here so the ghostty
# config resolves on every machine.
{
  fonts.packages = [
    pkgs.inter
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.iosevka
  ];
}
