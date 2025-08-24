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
    (import ./services/bookstack {
      inherit config lib pkgs;
    })
    (import ./services/guacamole {
      inherit config lib pkgs;
    })
    (import ./services/vault {
      inherit config lib pkgs terranix system;
    })
    (import ./virtualisation/libvirt {
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
    ./services/comin
    ./services/dnsmasq
    ./services/openldap
    ./services/file-browser
    ./services/gitea
    ./services/grafana
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
    ./services/tailscale/client.nix
    ./services/tailscale/server.nix
    ./services/wireguard/server.nix
    ./services/wireguard/client.nix
    ./services/zabbix/agent.nix
    ./services/zabbix/server.nix
    ./virtualisation/whonix
  ];
}
