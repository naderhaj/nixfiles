{ inputs, pkgs, ... }:

{
  # OpenSSH reads this; HM never touches it
  programs.ssh.includes = [ "~/.ssh/config.local" ];

  programs.ssh.matchBlocks."*" = {
    serverAliveInterval = 30;
    serverAliveCountMax = 3;
  };

  home.packages = with pkgs; [
    unstable.postgresql
    unstable.k9s
    unstable.kubernetes-helm
  ];

}
