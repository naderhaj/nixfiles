#!/usr/bin/env bash
# Exercise 03: Outputs Schema
#
# Run: bash training/06-flakes/exercises/e03-outputs.sh
#
# Explore your flake's outputs and understand the schema.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

echo "═══ Exercise 1: Show flake outputs ═══"
echo ""
echo "Running: nix flake show (from repo root)"
echo ""
(cd "$REPO_ROOT" && nix flake show 2>/dev/null) || echo "(run from repo root)"
echo ""

echo "═══ Exercise 2: Evaluate specific outputs ═══"
echo ""
echo "Your flake exports darwinConfigurations and nixosConfigurations."
echo ""
echo "To inspect in nix repl:"
echo "  cd $REPO_ROOT"
echo "  nix repl"
echo "  :lf ."
echo ""
echo "Then try:"
echo "  darwinConfigurations.mbp2023.system"
echo "  nixosConfigurations.zeus.config.networking.hostName"
echo "  darwinConfigurations.mbp2023.config.home-manager.users.naderh.home.homeDirectory"
echo ""

echo "═══ Exercise 3: Add a check ═══"
echo ""
echo "TODO: Try adding a check to your flake.nix (don't commit — just experiment):"
echo ""
echo '  checks.aarch64-darwin.eval = let'
echo '    drv = self.darwinConfigurations.mbp2023.system;'
echo '  in drv;'
echo ""
echo "Then run: nix flake check"
echo "This verifies your darwin config evaluates without errors."
echo ""

echo "═══ Exercise 4: Add a devShell ═══"
echo ""
echo "TODO: Try adding a devShell to your flake.nix:"
echo ""
echo '  devShells.aarch64-darwin.default = nixpkgs-unstable.legacyPackages.aarch64-darwin.mkShell {'
echo '    packages = with nixpkgs-unstable.legacyPackages.aarch64-darwin; [ nil nixfmt-rfc-style ];'
echo '  };'
echo ""
echo "Then: nix develop"
echo "You'd get a shell with nix LSP and formatter."
echo ""

echo "═══ Exercise 5: Export an overlay ═══"
echo ""
echo "TODO: Try adding to your flake outputs:"
echo ""
echo '  overlays.direnv-fix = import ./overlays/direnv-overlay.nix;'
echo ""
echo "Then another flake could use it:"
echo '  inputs.nixfiles.url = "github:naderhaj/nixfiles";'
echo '  # and in their nixpkgs.overlays: [ inputs.nixfiles.overlays.direnv-fix ]'
echo ""

echo "═══ Exercise 6: Command → output mapping ═══"
echo ""
echo "Match each command to the output it reads:"
echo ""
echo "  nix build .                 → packages.<system>.default"
echo "  nix develop .               → devShells.<system>.default"
echo "  nix flake check             → checks.<system>.*"
echo "  darwin-rebuild --flake .    → darwinConfigurations.<name>"
echo "  nixos-rebuild --flake .     → nixosConfigurations.<name>"
echo "  home-manager --flake .      → homeConfigurations.<name>"
