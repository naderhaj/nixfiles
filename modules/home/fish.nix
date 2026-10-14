{
  config,
  pkgs,
  libs,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellAliases = { };
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = [ ];
  };

  home.packages = with pkgs; [
    ## fish related
    fishPlugins.done
    fishPlugins.fzf-fish
    #   fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
  ];

}
