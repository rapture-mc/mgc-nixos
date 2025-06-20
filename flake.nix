{
  description = "NixOS infrastrucure for Megacorp Industries";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-25.05";
      rev = "88331c17ba434359491e8d5889cce872464052c2"; # 2025-06-20
    };

    nixpkgs24-11 = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-24.11";
      rev = "c5d77df613e70b94eededdc43d89827067baeb14"; # 2025-06-20
    };

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
    nixpkgs24-11,
    ...
  }: let
    # Define system architecture, make lib more accessible and apply overlays to pkgs variable
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (import ./overlays/freerdp.nix)
        (import ./overlays/guacamole-server.nix)
        (import ./overlays/bookstack.nix {
          inherit nixpkgs24-11;
        })
      ];
    };

    # Import custom variables
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
    nixosModules.default = {config, ...}: {
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
