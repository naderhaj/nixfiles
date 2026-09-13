{ inputs, ... }:
{
  # `pkgs.unstable.<name>` — newer versions from nixos-unstable, available
  # alongside the stable package set. Use at call sites that need a fresher
  # version than the main nixpkgs pin provides.
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
  ];
}
