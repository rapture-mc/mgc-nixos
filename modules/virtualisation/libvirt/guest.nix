{
  config,
  lib,
  ...
}: let
  cfg = config.megacorp.virtualisation.libvirt.guest;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {

  options.megacorp.virtualisation.libvirt.guest = {
    enable = mkEnableOption "Enable qemu-guest components";
  };

  config = mkIf cfg.enable {
    boot = {
      kernelParams = ["console=ttyS0"];
      initrd = {
        availableKernelModules = [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "9p"
          "9pnet_virtio"
        ];

        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
          "virtio_gpu"
        ];
      };
    };
  };
}
