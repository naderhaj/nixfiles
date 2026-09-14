# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix flakes configuration repository managing system configurations and home
environments across multiple platforms. The flake exposes exactly three configurations:

- **macOS (Darwin)**, via nix-darwin:
  - `mbp2023` — personal MacBook Pro
  - `ondorse` — work MacBook (see `hosts/ondorse/README.md` for bootstrap steps)
- **NixOS**: `zeus`

Home Manager is not used standalone; it is wired into each of the three configurations as a
NixOS/Darwin module.

## Key Architecture

### Flake Structure
- **Root flake.nix**: Defines all configurations and input sources
- **Two nixpkgs inputs**: `nixpkgs` (stable release branch) and `nixpkgs-unstable` — see
  the pin update policy below
- **Outputs**: `darwinConfigurations.{mbp2023,ondorse}` and `nixosConfigurations.zeus`.
  There are **no** `homeConfigurations` outputs.
- **Platform-specific configurations**: Each system has dedicated configuration modules

### Configuration Hierarchy
```
hosts/
├── mbp2023/system.nix             # macOS system config
├── ondorse/
│   ├── system.nix                 # work macOS system config
│   └── README.md                  # fresh-machine bootstrap guide
└── zeus/
    ├── system.nix                 # entry point (imports the two below)
    ├── configuration.nix
    └── hardware-configuration.nix

home/
└── [hostname].nix                 # Per-machine home-manager configs

modules/
├── system/                        # Reusable NixOS/Darwin system modules
│   ├── common-packages.nix
│   ├── common-linux-packages.nix
│   ├── fonts.nix                  # shared font set (NixOS + Darwin)
│   ├── nixpkgs-overlays.nix       # provides pkgs.unstable.<name>
│   └── desktop-environments/
└── home/                          # Reusable home-manager modules (flat)
    ├── common.nix, git.nix, zsh/, nvim/, ...
    └── ghostty/, tmux/, hyprland/, firefox.nix, ...

scripts/                           # Build/activation scripts
```

### Unused files

`home/linux.nix`, `home/homepi.nix`, `scripts/activate.sh` and `scripts/homepi.sh` are dead
code — they refer to `homeConfigurations` outputs the flake no longer defines, so the
scripts fail if run. `home/linux.nix` additionally uses `nerdfonts.override`, an API removed
from nixpkgs. Leave them alone or delete them; do not treat them as live configuration.

## Common Development Commands

### Building and Switching

**macOS (Darwin)**:
```bash
# Build and switch (automated; defaults to mbp2023)
./scripts/darwin.sh
./scripts/darwin.sh ondorse

# Manual build and switch
nix build .#darwinConfigurations.mbp2023.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#mbp2023

# Dry run for testing
darwin-rebuild build --flake .#mbp2023 --dry-run
```

**NixOS Systems**:
```bash
# Build for zeus
nix build .#nixosConfigurations.zeus.config.system.build.toplevel

# Apply system configuration
sudo nixos-rebuild switch --flake .#zeus
```

### Flake Management

```bash
# Update all inputs
nix flake update

# Update a specific input
nix flake update nixpkgs-unstable

# Check that every configuration evaluates (evaluation only — no builds,
# so this works on macOS even though zeus is x86_64-linux)
nix flake check
```

### Using make

A `Makefile` is provided as a single entry point for common tasks:

```bash
make mbp-switch      # build + switch macOS (mbp2023)
make mbp-build       # dry-run macOS build
make ondorse-switch  # build + switch work macOS (ondorse)
make ondorse-build   # dry-run ondorse build
make zeus-switch     # build + switch zeus (NixOS)
make zeus-build      # dry-run zeus build
make check           # nix flake check
make update          # update all inputs
make gc              # garbage collect old generations
make generations     # list system generations
```

### nixpkgs Pin Update Policy

The flake has two nixpkgs inputs:

- **`nixpkgs`** — pinned to a release branch (e.g. `nixos-26.05`). The default package set used everywhere. Bumping the branch HEAD pulls in backports without changing release. Bumping to the next release (e.g. `nixos-26.11`) is a larger upgrade.
- **`nixpkgs-unstable`** — tracks `nixos-unstable`. Exposed as `pkgs.unstable.<name>` via an overlay in `modules/system/nixpkgs-overlays.nix`. Use it at the call site when a specific package needs to be fresher than what the stable pin provides (e.g. `pkgs.unstable.claude-code`).

`flake.nix` carries a `# last bumped <date>` comment on each of the two inputs. These are
hand-maintained and go stale silently; `nix flake metadata` prints the authoritative dates.

```bash
# Bump only fresh-track packages
nix flake update nixpkgs-unstable

# Bump the stable pin (picks up backports on the same release branch)
nix flake update nixpkgs

# Bump both
make update
```

After any input update, run `make mbp-build` to verify the macOS config still evaluates.

### Package Management

```bash
# Search for packages
nix search nixpkgs <package-name>

# Enter development shell with packages
nix shell nixpkgs#<package>
```

### Debugging and Development

```bash
# Start nix repl for debugging
nix repl
> :lf .    # load current flake

# Build specific configuration without switching
nix build .#darwinConfigurations.mbp2023.system
nix build .#darwinConfigurations.ondorse.system
```

**Beware the flake evaluation cache.** `nix build` may serve a cached evaluation and skip
re-running module code, which hides evaluation warnings. Pass `--no-eval-cache` when
checking for warnings or confirming a change took effect.

**Derivation hashes cannot be used to verify refactors here.** The flake source tree is
embedded in the system derivation, so editing any unrelated file (even a README) changes the
top-level `.drv` hash. To prove a refactor is a no-op, compare evaluated option values
instead, e.g. `nix eval .#darwinConfigurations.mbp2023.config.fonts.packages`.

## Important Configuration Details

### Neovim Configuration
- Comprehensive Neovim setup in `modules/home/nvim/`
- Uses both stable and unstable packages for different plugins
- Lua configuration files are embedded directly in the Nix configuration
- LSP, formatters, and telescope configurations are modularized

### Firefox
- `modules/home/firefox.nix` declares the profile and add-ons, imported by `home/ondorse.nix` only.
- Add-ons come from the `firefox-addons` flake input (rycee's NUR expressions), which follows
  `nixpkgs-unstable`. Bump add-on versions with `nix flake update firefox-addons`.
- `programs.firefox.package = null` — nixpkgs has no Firefox build for Darwin, so the app is
  installed manually and home-manager manages only the profile.
- `mbp2023` deliberately does **not** import this module: it has three pre-existing Firefox
  profiles, and home-manager generates `profiles.ini` wholesale from declared profiles only.

### Fonts
- `modules/system/fonts.nix` is the single source of truth, imported by all three hosts.
  `fonts.packages` is spelled identically in NixOS and nix-darwin.
- Iosevka Nerd Font is the terminal font selected in `modules/home/ghostty/ghostty.conf`.

### User Email Configuration
Git email is set directly per-machine in each `home/<hostname>.nix` via
`programs.git.settings.user.email` (there is no `gitEmail` specialArg):

- `mbp2023`, `zeus`, and `ondorse`: hajlaoui.nader@gmail.com

### Platform-Specific Notes
- **macOS**: Includes system defaults, fonts, and TouchID authentication
- **macOS keyboard**: The Fn ↔ left Control swap is set by hand in System Settings, *not* in
  the flake. nix-darwin's `system.keyboard.swapLeftCtrlAndFn` applies mappings via
  `hidutil property --set`, which is runtime-only and lost on reboot. See
  `hosts/ondorse/README.md` section 6.
- **Home Manager**: Manages user-level configurations across all platforms

## Testing Changes

Always test configuration changes before switching:
1. Use dry-run options when available
2. Build configurations without switching first
3. For macOS: `make mbp-build` / `make ondorse-build`
4. For NixOS: `nixos-rebuild build --flake .#zeus`
5. `make check` evaluates all three configurations and works from any platform

Note that `nix build` needs new files to be `git add`ed before it can see them — an untracked
module produces a confusing "Path ... is not tracked by Git" evaluation error.

## Architecture Principles

- **Modular Design**: Shared modules in `modules/` for reusability
- **Per-Machine Customization**: Each machine imports common modules and adds specific configs
- **Two nixpkgs pins**: a stable release branch by default, with `pkgs.unstable.<name>`
  available at call sites that need fresher packages
- **Git Integration**: Each environment has appropriate git email configuration
- **Platform Abstraction**: Common patterns abstracted into reusable modules
