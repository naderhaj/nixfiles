{ inputs, ... }:

{
  # OpenSSH reads this; HM never touches it
  programs.ssh.includes = [ "~/.ssh/config.local" ];
}
