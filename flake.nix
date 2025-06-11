{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, terranix, nixos-generators, ... }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
    vars = import ./vars;

    # Helper function for importing different nixosConfigurations
    importMachineConfig = machineType: machineName: configType:
      import ./machines/${machineType}/${machineName} {
        inherit self vars nixpkgs pkgs terranix system;
      };
  in {
    nixosConfigurations = import ./machines {
      inherit importMachineConfig;
    };

    nixosModules.default = { config, ... }: {
      imports = [
        (import ./modules {
          inherit config terranix lib pkgs system;
        })
      ];
    };

    # For generating Megacorp NixOS VM images
    # Build with "nix build .#<image-type>"
    packages.${system} = import ./nixos-images.nix {
      inherit system nixos-generators vars;
    };
  };
}
