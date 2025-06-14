{
  lib,
  config,
  pkgs,
  terranix,
  system,
  ...
}: {
  imports = [
    ./config/bootloader
    ./config/desktop
    ./config/packages
    ./config/networking
    ./config/openssh
    ./config/system
    ./config/users
    ./hardening/bootloader.nix
    ./programs/nixvim
    ./programs/pass
    ./services/bookstack
    ./services/comin
    ./services/dnsmasq.nix
    ./services/openldap
    ./services/file-browser.nix
    ./services/gitea.nix
    ./services/gitea-runner.nix
    ./services/grafana.nix
    ./services/guacamole.nix
    ./services/jenkins.nix
    ./services/k3s.nix
    ./services/netbox.nix
    ./services/nextcloud.nix
    ./services/nginx/default.nix
    ./services/prometheus.nix
    ./services/restic.nix
    ./services/semaphore
    ./services/syncthing
    (import ./services/vault {
      inherit config lib pkgs;
    })
    ./services/wireguard-server.nix
    ./services/wireguard-client.nix
    ./services/zabbix.nix
    (import ./virtualisation/aws {
      inherit config lib pkgs terranix system;
    })
    (import ./virtualisation/libvirt {
      inherit config lib pkgs terranix system;
    })
    ./virtualisation/whonix
  ];
}
