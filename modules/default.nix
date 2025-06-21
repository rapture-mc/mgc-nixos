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
    (import ./services/bookstack {
      inherit config lib pkgs;
    })
    ./services/comin
    ./services/dnsmasq.nix
    ./services/openldap
    ./services/file-browser
    ./services/gitea
    ./services/grafana
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
      inherit config lib pkgs terranix system;
    })
    ./services/wireguard-server.nix
    ./services/wireguard-client.nix
    ./services/zabbix/agent.nix
    ./services/zabbix/server.nix
    (import ./virtualisation/aws {
      inherit config lib pkgs terranix system;
    })
    (import ./virtualisation/libvirt {
      inherit config lib pkgs terranix system;
    })
    ./virtualisation/whonix
  ];
}
