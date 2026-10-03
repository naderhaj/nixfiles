{ ... }:
{
  home.sessionVariables = {
    DISPLAY = ":0";
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
  };

  home.shellAliases = {
    lsd = "eza --long --header --git --all";
    dps = "docker ps --all";
    stopanddeleteallcontainers = "docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)";
    deleteallvolumes = "docker volume rm $(docker volume ls -q)";
    zshreload = "source ~/.zshrc";
    zshrc = "nvim ~/projects/nixfiles/modules/home/zsh/default.nix";
    c = "clear";
    # git
    gs = "git status";
    gd = "git diff";
    gc = "git commit -v";
    # editor
    v = "nvim";
    installedpackages = "nix-store --query --requisites /run/current-system";
    installedpackagespretty = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq";
    # kubectl
    k = "kubectl";
  };
}
