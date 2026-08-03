.PHONY: mbp-switch mbp-build ondorse-switch ondorse-build zeus-switch zeus-build check update gc generations

# Build and switch macOS (Darwin) configuration
mbp-switch:
	./scripts/darwin.sh

# Dry-run macOS build without switching
mbp-build:
	darwin-rebuild build --flake .#mbp2023 --dry-run

# Build and switch work macOS (ondorse)
ondorse-switch:
	./scripts/darwin.sh ondorse

# Dry-run work macOS build without switching
ondorse-build:
	darwin-rebuild build --flake .#ondorse --dry-run

# Build and switch zeus (NixOS)
zeus-switch:
	sudo nixos-rebuild switch --flake .#zeus

# Dry-run zeus build without switching
zeus-build:
	nix build .#nixosConfigurations.zeus.config.system.build.toplevel --dry-run

# Check flake evaluates without errors
check:
	nix flake check

# Update all flake inputs
update:
	nix flake update

# Garbage collect old generations and free disk space
gc:
	./scripts/gc.sh

# Show current system generations
generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
