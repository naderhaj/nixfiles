{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/desktop-environments/gnome.nix # Enable Gnome
    ../../modules/system/binary-caches.nix
  ];

  nix.settings = {
    trusted-users = [ "zeus" ];
  };

}
