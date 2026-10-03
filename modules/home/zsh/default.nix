{ pkgs, lib, config, machine, ... }:
{

  # Multi-shell, multi-command completion engine: provides zsh completions for
  # hundreds of CLI tools (aws, git, docker, gh, kubectl, npm, cargo, ...) out of
  # the box, so most tools don't need a hand-written completion block.
  programs.carapace.enable = true;

  # Frecency-based `cd` replacement: `z foo` jumps, `zi` picks interactively.
  programs.zoxide.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.3.0";
          sha256 = "sha256-8atbysoOyCBW2OYKmdc91x9V/Mk3eyg3hvzvhJpQ32w=";
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
      JK_MACHINE_NAME = "nh-shell";
    };

    # type a directory name (e.g. `..`) to cd into it
    autocd = true;

    # allow `# comments` in typed/pasted commands
    setOptions = [ "INTERACTIVE_COMMENTS" ];

    # type a prefix, then ↑/↓ cycles through history entries containing it
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[A" "^[OA" ];
      searchDownKey = [ "^[[B" "^[OB" ];
    };

    shellAliases = {
      "-" = "cd -";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    initContent = lib.mkMerge [
      # Load the direnv environment before the instant prompt so its output
      # doesn't trigger p10k's "console output during initialization" warning.
      # The regular direnv hook (added by programs.direnv) still runs later.
      (lib.mkOrder 400 ''
        emulate zsh -c "$(${lib.getExe config.programs.direnv.package} export zsh)"
      '')

      # powerlevel10k instant prompt; must stay at the very top of .zshrc.
      # Anything that needs console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block.
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
        # powerlevel10k
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${./p10k.zsh}

        # fzf-tab: preview directory contents when completing cd / z
        zstyle ':fzf-tab:complete:(cd|__zoxide_z):*' fzf-preview 'eza -1 --color=always $realpath'
        # group headers ([files], [directories], ...); switch groups with < and >
        zstyle ':completion:*:descriptions' format '[%d]'
        # case-insensitive completion; also treats - and _ as interchangeable
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'

        # Ctrl-X Ctrl-E: edit the current command line in $EDITOR
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^X^E' edit-command-line

        # colorized man pages (via less termcap overrides)
        export LESS_TERMCAP_mb=$'\e[1;31m'     # begin blink
        export LESS_TERMCAP_md=$'\e[1;36m'     # begin bold (headings, options) → cyan
        export LESS_TERMCAP_me=$'\e[0m'        # end bold/blink
        export LESS_TERMCAP_so=$'\e[01;33m'    # begin standout (status bar, search hits) → yellow
        export LESS_TERMCAP_se=$'\e[0m'        # end standout
        export LESS_TERMCAP_us=$'\e[1;32m'     # begin underline (arguments) → green
        export LESS_TERMCAP_ue=$'\e[0m'        # end underline
        export GROFF_NO_SGR=1                  # needed on some distros (Fedora, Arch, newer Debian) or colors won't show
      ''

      # let the `k` alias reuse kubectl's completion; runs after carapace has
      # registered its completers
      (lib.mkAfter ''
        compdef k=kubectl
      '')
    ];

    history = {
      size = 100000;
      save = 100000;
      extended = true;
      expireDuplicatesFirst = true;
    };

  };

}
