{
  description = "home-manager configuration for linux, mac and raspberry pi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; # pinned 2026-05-30

    # Unstable channel, exposed in the package set as `pkgs.unstable.<name>`.
    # Use for packages where you want a newer version than what's in the
    # stable nixpkgs pin. Update with: nix flake update nixpkgs-unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, ... }:
    {

      nixosConfigurations = {
        zeus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/zeus/system.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zeus = import ./home/zeus.nix;
            }
          ];
        };

      };

      darwinConfigurations = {
        mbp2023 = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/mbp2023/system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.naderh = import ./home/mbp2023.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
            }
          ];
        };

        ondorse = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/ondorse/system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.naderh = import ./home/ondorse.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
            }
          ];
        };
      };

    };

}
