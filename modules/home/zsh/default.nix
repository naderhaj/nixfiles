{ pkgs, lib, config, machine, ... }:
{

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Multi-shell, multi-command completion engine: provides zsh completions for
  # hundreds of CLI tools (aws, git, docker, gh, npm, cargo, ...) out of the box,
  # so most tools don't need a hand-written completion block like kubectl below.
  programs.carapace.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "z" "virtualenv"];
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.2.0";
          sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
        };
      }
    ];

    localVariables = {
      POWERLEVEL9K_MODE = "awesome-patched";
      HYPHEN_INSENSITIVE = "true";
      COMPLETION_WAITING_DOTS = "true";
      ZSH_HIGHLIGHT_MAXLENGTH = "20";
      JK_MACHINE_NAME = "nh-shell";
    };

    shellAliases = { };

    initContent = ''
      # powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./p10k.zsh}

      # kubectl completion (also applies to the `k` alias)
      if command -v kubectl >/dev/null 2>&1; then
        source <(kubectl completion zsh)
        compdef k=kubectl
      fi
    '';

    history = {
      size = 100000;
    };

  };

}
