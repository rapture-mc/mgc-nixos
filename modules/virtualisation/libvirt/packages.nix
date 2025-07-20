{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.megacorp.virtualisation.libvirt.hypervisor;

  inherit
    (lib)
    mkIf
    ;

  generateWinImage = pkgs.writeShellScriptBin "generateWinImage" ''
    echo -e "This script will build a Windows image with packer based on your selection.\n"

    echo ""

    while true; do
      echo -e "Which Windows Image?\n--------------------\n1. Server 2022 GUI\n2. Server 2019 GUI\n3. Server 2022 Core\n4. Server 2019 Core\n5. Windows 11\n6. Windows 10\n"
      read -p "Your selection: " response_image
      case $response_image in
        1 )
          packer_file="win2022.pkr.hcl"
          packer_command=$packer_file
          name="Windows-Server-2022-GUI"
          break;;
        2 )
          packer_file="win2019.pkr.hcl"
          packer_command=$packer_file
          name="Windows-Server-2019-GUI"
          break;;
        3 )
          packer_file="win2022.pkr.hcl"
          packer_command="-var autounattend=answer_files/2022-core/Autounattend.xml $packer_file"
          name="Windows-Server-2022-Core"
          break;;
        4 )
          packer_file="win2019.pkr.hcl"
          packer_command="-var autounattend=answer_files/2019-core/Autounattend.xml $packer_file"
          name="Windows-Server-2019-Core"
          break;;
        5 )
          packer_file="win11_23h2.pkr.hcl"
          packer_command=$packer_file
          name="Windows-11"
          break;;
        6 )
          packer_file="win10_22h2.pkr.hcl"
          packer_command=$packer_file
          name="Windows-10"
          break;;
        * ) echo -e "Please enter either 1, 2, 3, 4, 5 or 6\n\n";;
      esac
    done

    while true; do
      echo ""
      echo -e "I'll now download the $name image from the internet and output the image to the packer-windows/output-$name directory (relative to where this command was run)\n"
      read -p "Continue? (y/n)" response_continue
      case $response_continue in
        [Yy]* )
          if [ ! -d packer-windows ]; then
            git clone --quiet https://github.com/rapture-mc/packer-windows.git
          fi

          if [ ! -d packer-windows/output-$name ]; then
            cd packer-windows

            echo -e "Initializing and building $name image for QCOW2..."

            packer init $packer_file

            packer build $packer_command
          else
            echo "Packer output directory $name already exists... Skipping build creation"
          fi

          echo  "Done!"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
      esac
    done
  '';
in {
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libxslt
      opentofu
      packer
      virt-manager
      generateWinImage
    ];
  };
}
