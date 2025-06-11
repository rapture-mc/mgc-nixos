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

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    nixpkgs,
    terranix,
    nixos-generators,
    sops-nix,
    home-manager,
    nixvim,
    arion,
    comin,
    plasma-manager,
    ...
  }: let
    # Define system, make lib and pkgs more accessible and import custom variables under "vars"
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
    vars = import ./vars;

    # Helper function for importing different nixosConfigurations
    importMachineConfig = machineType: machineName:
      import ./machines/${machineType}/${machineName} {
        inherit self vars nixpkgs pkgs terranix system sops-nix;
      };
  in {

    ##################
    # NIXOS MACHINES #
    ##################
    nixosConfigurations = import ./machines {
      inherit importMachineConfig;
    };


    #################
    # NIXOS MODULES #
    #################
    nixosModules.default = {
      config,
      ...
    }: {
      imports = [
        nixvim.nixosModules.nixvim
        home-manager.nixosModules.home-manager
        arion.nixosModules.arion
        comin.nixosModules.comin
        (import ./modules {
          inherit config terranix lib pkgs system;
        })
        {
          home-manager.sharedModules = [
            plasma-manager.homeManagerModules.plasma-manager
          ];
        }
      ];
    };


    ################
    # NIXOS IMAGES #
    ################

    # Build with "nix build .#<image-type>"
    packages.${system} = import ./nixos-images.nix {
      inherit self system nixos-generators vars;
    };
  };
}
