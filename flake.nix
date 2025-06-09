{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    megacorp = {
      url = "github:rapture-mc/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, megacorp, terranix, ... }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nixos-dev = nixpkgs.lib.nixosSystem {
      modules = [
        megacorp.nixosModules.default
        self.nixosModules.default
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };

    nixosModules.default = { config, ... }: {
      imports = [
        (import ./modules {inherit config terranix lib pkgs system;})
      ];
    };
  };
}
