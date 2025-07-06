{
  lib,
  config,
  pkgs,
  terranix,
  system,
  ...
}: let
  cfg = config.megacorp.virtualisation.libvirt;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  imports = [
    (import ./packages.nix {
      inherit config lib pkgs;
    })
    ./guest.nix
    (import ./infra.nix {
      inherit config lib pkgs terranix system;
    })
  ];

  options.megacorp.virtualisation.libvirt = {
    enable = mkEnableOption ''
      Enable Libvirt hypervisor.

      Also setup a static IP and bridge interface with megacorp.config.networking.static-ip option.
    '';

    logo = mkEnableOption "Whether to show hypervisor logo on shell startup";

    libvirt-users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "A list of users who will have access to the libvirt API";
    };
  };

  config = mkIf cfg.enable {
    users.groups.libvirtd.members = cfg.libvirt-users;

    services.earlyoom.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };

    environment.sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };
}
