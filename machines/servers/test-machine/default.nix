{
  nixpkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/virtualisation/qemu-vm.nix"
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      services.getty.autologinUser = vars.adminUser;

      virtualisation.graphics = false;

      system.stateVersion = "25.05";

      networking.hostName = "test-machine";
    })
  ];
}
