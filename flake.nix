{
  description = "Blockchain HPC app running on Xnode!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (
        system: f {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );
    in
    {
      packages = eachSystem ({ pkgs, ... }: {
        default = pkgs.callPackage ./nix/package.nix { };
        xnode-blockchain-hpc = pkgs.callPackage ./nix/package.nix { };  # Add this line
      });

      # Keep your existing apps configuration
      apps = eachSystem ({ system, ... }: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/xnode-blockchain-hpc";
        };
        reset-testnet = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/reset-testnet";
        };
      });

      checks = eachSystem ({ pkgs, system, ... }: {
        package = self.packages.${system}.default;
        nixos-module = pkgs.callPackage ./nix/nixos-test.nix { };
      });

      nixosModules.default = ./nix/nixos-module.nix;
    };
}