{osConfig, ...}: let
  cfg = osConfig.megacorp;
in {
  programs.fastfetch.enable = true;

  home.file.fastFetchLogo = {
    enable = true;
    source = (
      if cfg.config.openssh.bastion.logo
      then ./bastion-logo
      else if cfg.services.openldap.logo
      then ./controller-logo
      else if cfg.virtualisation.libvirt.hypervisor.logo
      then ./hypervisor-logo
      else if cfg.services.nginx.logo
      then ./nginx-logo
      else if cfg.services.grafana.logo
      then ./grafana-logo
      else if cfg.services.nextcloud.logo
      then ./nextcloud-logo
      else if cfg.services.guacamole.logo
      then ./guacamole-logo
      else if cfg.services.gitea.logo
      then ./gitea-logo
      else if cfg.services.k3s.logo
      then ./k3s-logo
      else if cfg.services.vault.logo
      then ./vault-logo
      else if cfg.services.wireguard.server.logo
      then ./wireguard-logo
      else if cfg.services.restic.sftp-server.logo
      then ./restic-logo
      else if cfg.services.bookstack.logo
      then ./bookstack-logo
      else ./megacorp-logo
    );
    target = ".config/fastfetch/logo";
  };

  home.file.fastFetchConfig = {
    enable = true;
    source = ./config.jsonc;
    target = ".config/fastfetch/config.jsonc";
  };
}
