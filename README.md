# nixfiles

Nix flakes configuration managing system and home environments across multiple machines.

| Host | Platform | Type |
|------|----------|------|
| `mbp2023` | macOS (Apple Silicon) | nix-darwin + home-manager |
| `zeus` | NixOS (x86_64) | NixOS + home-manager |


## Structure

```
hosts/          # system-level config per machine
home/           # home-manager config per machine
modules/
├── system/     # shared NixOS/Darwin system modules
└── home/       # shared home-manager modules
overlays/       # custom package overlays
scripts/        # build/activation scripts
```

## Usage

```bash
make mbp-switch   # build + switch macOS
make zeus-switch  # build + switch zeus (run on zeus)
make mbp-build    # dry-run macOS build
make zeus-build   # dry-run zeus build
make check        # validate flake
make update       # update all inputs
make gc           # garbage collect old generations
```

## Setup

### macOS

1. Install [Nix](https://determinate.systems/posts/determinate-nix-installer) via Determinate Systems installer
2. Run `make mbp-switch`

### NixOS

```bash
sudo nixos-rebuild switch --flake .#zeus
```

## Updating nixpkgs pins

Two nixpkgs inputs:

- `nixpkgs` — tracks a stable release branch (currently `nixos-26.05`). Default package set.
- `nixpkgs-unstable` — tracks `nixos-unstable`. Exposed at call sites as `pkgs.unstable.<name>` for packages that need to be fresher than the stable pin (e.g. `pkgs.unstable.claude-code`).

```bash
# Bump only fresh-track packages (e.g. claude-code)
nix flake update nixpkgs-unstable

# Bump the stable pin (backports on the same release branch)
nix flake update nixpkgs

# Bump everything
make update
```

After any update, run `make mbp-build` (or `make zeus-build`) before switching.
