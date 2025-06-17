{
  nixpkgs,
  pkgs,
  self,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
      ];

      system.stateVersion = "25.05";

      networking.hostName = "testbox01";

      time.timeZone = "Australia/Darwin";

      boot.loader.grub = {
        enable = true;
        device = "/dev/vda";
      };

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      megacorp = {
        config.users = {
          enable = true;
          admin-user = "megaman";
        };
        programs.nixvim.enable = true;
      };

      services.openssh.enable = true;

      users.users.benny = {
        isNormalUser = true;
        initialPassword = "changeme";
        extraGroups = [
          "wheel"
        ];
      };

      environment.systemPackages = with pkgs; [
        git
      ];
    }
  ];
}
