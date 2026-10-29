#!/usr/bin/env bash
# Headless smoke test of a host's Neovim: the wrapped nvim and generated
# init.lua from the flake, the Lua config from this checkout, and the host's
# home packages on PATH. Usage: ./scripts/nvim-test.sh [host] (default mbp2023)
set -euo pipefail

host="${1:-mbp2023}"
case "$host" in
zeus) hm=".#nixosConfigurations.zeus.config.home-manager.users.zeus" ;;
mbp2023 | ondorse) hm=".#darwinConfigurations.$host.config.home-manager.users.naderh" ;;
*)
  echo "unknown host: $host" >&2
  exit 2
  ;;
esac

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

build() { nix build --no-link --print-out-paths "$hm.$1"; }
nvim="$(build programs.neovim.finalPackage)/bin/nvim"
# The files home-manager would link into $HOME: generated init.lua, plugins.
files="$(build home-files)"
profile="$(build home.path)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/config/nvim" "$tmp/data/nvim/site/pack"
ln -s "$files/.config/nvim/init.lua" "$tmp/config/nvim/init.lua"
ln -s "$root/modules/home/nvim/lua" "$tmp/config/nvim/lua"
ln -s "$files/.local/share/nvim/site/pack/hm" "$tmp/data/nvim/site/pack/hm"

# Throwaway XDG dirs, so the test neither reads nor clobbers real nvim state.
XDG_CONFIG_HOME="$tmp/config" \
  XDG_DATA_HOME="$tmp/data" \
  XDG_STATE_HOME="$tmp/state" \
  XDG_CACHE_HOME="$tmp/cache" \
  PATH="$profile/bin:$PATH" \
  NVIM_TEST_ROOT="$root" \
  "$nvim" --headless --cmd "luafile $root/modules/home/nvim/test/smoke.lua"
