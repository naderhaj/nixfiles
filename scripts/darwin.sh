#bin/sh
set -e

CONFIG="${1:-mbp2023}"
nix build ".#darwinConfigurations.${CONFIG}.system" && sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${CONFIG}"
