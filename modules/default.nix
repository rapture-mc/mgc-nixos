{
  lib,
  config,
  pkgs,
  terranix,
  system,
  ...
}: {
  imports = [
    (import ./cloud/aws/route53.nix {
      inherit config lib pkgs terranix system;
    })
    (import ./cloud/aws/ec2.nix {
      inherit config lib pkgs terranix system;
    })
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
    ./services/bloodhound
    (import ./services/bookstack {
      inherit config lib pkgs;
    })
    ./services/comin
    ./services/dnsmasq
    ./services/openldap
    ./services/file-browser
    ./services/gitea
    ./services/grafana
    (import ./services/guacamole {
      inherit config lib pkgs;
    })
    ./services/k3s
    ./services/lldap
    ./services/netbox
    ./services/nextcloud
    ./services/nginx/default.nix
    ./services/prometheus
    ./services/restic
    ./services/semaphore
    ./services/snipe-it
    ./services/syncthing
    (import ./services/vault {
      inherit config lib pkgs terranix system;
    })
    ./services/wireguard/server.nix
    ./services/wireguard/client.nix
    ./services/zabbix/agent.nix
    ./services/zabbix/server.nix
    (import ./virtualisation/libvirt {
      inherit config lib pkgs terranix system;
    })
    ./virtualisation/whonix
  ];
}
