{pkgs, ...}: let
  generateAgeKey = pkgs.writeShellScriptBin "generateAgeKey" ''
    mkdir -p ~/.config/sops/age
    if [ "$(id -u)" -ne 0 ]; then
      echo "Error: This command must be run with sudo... Exiting!"
      exit 1
    elif [ -f /home/$SUDO_USER/.config/sops/age/keys.txt ]; then
      echo "Age keyfile already exists... Skipping"
      exit 1
    else
      echo "Generating age private key from this hosts SSH ed25519 key and outputting to ~/.config/sops/age/keys.txt"
      mkdir -p /home/$SUDO_USER/.config/sops/age
      sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /home/$SUDO_USER/.config/sops/age/keys.txt
      echo -e "Done!\n"

      echo "Setting correct ownership permissions on newly created ssh key..."
      sudo chown $SUDO_USER:users /home/$SUDO_USER/.config/sops/age/keys.txt
      echo -e "Done!\n"

      echo "Age public key is: $(cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age)"
    fi
  '';

  firstTimeSetup = pkgs.writeShellScriptBin "firstTimeSetup" ''
    if [ $# -ne 1 ]; then
      echo "You must supply at least one argument (the hostname)"
      exit 1
    fi

    echo "Cloning git directory to /tmp/mgc-nixos"
    git clone https://github.com/rapture-mc/mgc-nixos /tmp/mgc-nixos

    cd /tmp/mgc-nixos

    echo "Running nh os switch..."
    nh os switch . -H $1
  '';
in {
  environment.systemPackages = [
    generateAgeKey
    firstTimeSetup
  ];
}
