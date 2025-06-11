{
  nixos-generators,
  system,
  vars,
  self,
}: let
  megacorp = self.nixosModules.default;

  common-config = {
    networking.hostName = "nixos";

    system.stateVersion = "24.11";

    megacorp = {
      config = {
        system.enable = true;
        bootloader.enable = false; # nixos-generator will handle bootloader configuration instead
        packages.enable = true;

        openssh = {
          enable = true;
          authorized-ssh-keys = vars.keys.bastionPubKey;
        };

        users = {
          enable = true;
          admin-user = "benny";
        };
      };

      programs.nixvim.enable = true;
    };
  };
in {
  qcow = nixos-generators.nixosGenerate {
    system = system;
    format = "qcow";
    modules = [
      common-config
      megacorp
      {
        megacorp.virtualisation.libvirt.guest.enable = true;
      }
    ];
  };

  amazon = nixos-generators.nixosGenerate {
    system = system;
    format = "amazon";
    modules = [
      common-config
      megacorp
      ({...}: {
        virtualisation.diskSize = 16 * 1024; # See https://github.com/nix-community/nixos-generators/issues/150
      })
    ];
  };
}
