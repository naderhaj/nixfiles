{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    ignores = [
      "**/.metals/"
      "**/project/metals.sbt"
      "**/.idea/"
      "**/.vscode/settings.json"
      "**/.bloop/"
      "**/.bsp/"
      "**/.scala-build/"
      "**/.direnv/"
      "**/.DS_Store"
    ];

    signing.format = null;

    settings = {
      user.name = "Nader Hajlaoui";
      alias = { };
      pull.rebase = true;
      init.defaultBranch = "main";
      github.user = "naderhaj";

      push.autoSetupRemote = true;
      push.followTags = true; # push tags when pushing branches

      core.editor = "nvim";
      core.fileMode = false;
      core.ignorecase = false;
      column.ui = "auto";
      branch.sort = "-committerdate"; # sort branches by last commit date
      tag.sort = "version:refname"; # sort tags by version number
      diff.algorithm = "histogram";
      diff.colorMoved = "plain"; # don't color moved lines
      diff.mnemonicprefix = true; # use mnemonic prefixes in diffs
      diff.renames = true; # detect renames
      # fetch
      fetch.prune = true; # prune deleted branches
      fetch.pruneTags = true; # prune deleted tags
      fetch.all = true; # fetch all branches
      # commit
      commit.verbose = true; # show diff in commit message
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      #syntax-theme = "solarized-dark";
      side-by-side = true;
    };
  };
}
