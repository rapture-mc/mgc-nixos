{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    megacorp = {
      url = "github:rapture-mc/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    vars = import ./vars;
  in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      snowfall = {
        namespace = "megacorp";
      };

      systems.modules.nixos = with inputs; [
        megacorp.nixosModules.default
      ];

      systems.hosts.nixos-dev.specialArgs = {
        vars = vars;
      };
    };
}
