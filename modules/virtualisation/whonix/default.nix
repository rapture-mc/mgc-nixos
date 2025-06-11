{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.virtualisation.whonix;

  whonixVersion = "17.3.9.9";

  pname = "UnstoppableSwap";
  version = "1.0.0-rc.11";

  src = pkgs.fetchurl {
    url = "https://github.com/UnstoppableSwap/core/releases/download/${version}/${pname}_${version}_amd64.AppImage";
    hash = "sha256-ot9yHm2mUaFJL9G80T6VhzYrpRmoSR9wUL79tnZiuyA=";
  };

  startWhonix = pkgs.writeShellScriptBin "startWhonix" ''
    VBoxManage startvm Whonix-Gateway-Xfce --type headless

    sleep 1

    VBoxManage startvm Whonix-Workstation-Xfce
  '';

  stopWhonix = pkgs.writeShellScriptBin "stopWhonix" ''
    VBoxManage controlvm Whonix-Workstation-Xfce poweroff

    VBoxManage controlvm Whonix-Gateway-Xfce poweroff
  '';

  installWhonix = pkgs.writeShellScriptBin "installWhonix" ''
    echo -e "This script will check for the existence of Whonix and if not found download Whonix from the internet and import it into VirtualBox"

    while true; do
      read -p "Continue? (y/n)" response
      case $response in
        [Yy]* )
          if ! VBoxManage list vms | grep -q "Whonix" && [ -e /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova ]; then
            echo "Whonix VMs don't exist, importing..."

            VBoxManage import /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova --vsys 0 --eula accept --vsys 1 --eula accept

          elif ! VBoxManage list vms | grep -q "Whonix" && [ ! -e /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova ]; then
            echo "Whonix VMs don't exist and Whonix OVA file doesn't exist, downloading OVA file..."

            wget https://download.whonix.org/ova/${whonixVersion}/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova -O /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova

            VBoxManage import /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova --vsys 0 --eula accept --vsys 1 --eula accept

            echo -e "Import successful!\n Cleaning up OVA file from /tmp folder..."

            rm /tmp/Whonix-Xfce-${whonixVersion}.Intel_AMD64.ova

          else
            echo "Whonix VMs already exist, skipping..."

            exit 1

          fi

          echo  "Done!"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
      esac
    done
  '';

  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.megacorp.virtualisation.whonix = {
    enable = mkEnableOption "Enable Whonix Gateway and Workstation VMs along with bash helper scripts";
  };

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;

    # See https://github.com/NixOS/nixpkgs/issues/363887 for details
    boot.kernelParams = ["kvm.enable_virt_at_load=0"];

    environment.systemPackages = with pkgs; [
      (appimageTools.wrapType2 {
        inherit pname version src;
      })
      electrum
      monero-gui
      installWhonix
      startWhonix
      stopWhonix
    ];
  };
}
