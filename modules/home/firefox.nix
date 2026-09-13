{ pkgs, inputs, ... }:

let
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.firefox = {
    enable = true;

    # nixpkgs has no Firefox build for darwin, so home-manager only manages the
    # profile here. Install Firefox.app itself from Mozilla or Homebrew.
    package = null;

    profiles.default = {
      isDefault = true;

      # Side-loaded add-ons are disabled by default; 0 auto-enables them.
      settings."extensions.autoDisableScopes" = 0;

      extensions.packages = with addons; [
        ublock-origin
        bitwarden
        privacy-badger
        duckduckgo-privacy-essentials
        french-dictionary
        french-language-pack
      ];
    };
  };
}
