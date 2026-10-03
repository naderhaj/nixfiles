.PHONY: mbp-switch mbp-build ondorse-switch ondorse-build zeus-switch zeus-build check update gc generations

# Build and switch macOS (Darwin) configuration
mbp-switch:
	nh darwin switch -H mbp2023 .

# Build macOS without switching (shows package diff)
mbp-build:
	nh darwin build -H mbp2023 .

# Build and switch work macOS (ondorse)
ondorse-switch:
	nh darwin switch -H ondorse .

# Build work macOS without switching (shows package diff)
ondorse-build:
	nh darwin build -H ondorse .

# Build and switch zeus (NixOS)
zeus-switch:
	nh os switch -H zeus .

# Build zeus without switching (shows package diff)
zeus-build:
	nh os build -H zeus .

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
