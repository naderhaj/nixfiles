{ inputs, pkgs, ... }:

{
  # OpenSSH reads this; HM never touches it
  programs.ssh.includes = [ "~/.ssh/config.local" ];

  home.packages = with pkgs; [
    unstable.postgresql
    unstable.k9s
    unstable.kubernetes-helm
  ];

}
