{ inputs, ... }:
let
  snippetFiles = {
    "global.json" = ./nvim/snippets/global.json;
    "python.json" = ./nvim/snippets/python.json;
    "go.json"     = ./nvim/snippets/go.json;
  };
in
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./fzf.nix
    ./nvim/nvim.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  # `nix-locate` + command-not-found handler, backed by the prebuilt database
  programs.nix-index.enable = true;
  # `, <cmd>` runs any nixpkgs program without installing it
  programs.nix-index-database.comma.enable = true;

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Suppress SSH default config warning
  programs.ssh.enableDefaultConfig = false;

  programs = {
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "DarkNeon";
      };
    };
    btop.enable = true;
    eza.enable  = true;
    jq.enable   = true;
    ssh.enable  = true;
  };

  home.file = builtins.foldl'
    (acc: key:
      acc // {
        ".config/nvim/snippets/${key}" = {
          source = builtins.toPath snippetFiles.${key};
          recursive = true;
        };
      }
    )
    { }
    (builtins.attrNames snippetFiles);
}
