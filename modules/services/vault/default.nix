{
  pkgs,
  lib,
  config,
  terranix,
  system,
  ...
}: let
  cfg = config.megacorp.services.vault;

  inherit
    (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    ;
in {
  imports = [
    (import ./pki {
      inherit config lib pkgs terranix system;
    })
  ];

  options.megacorp.services.vault = {
    enable = mkEnableOption "Whether to enable Hashicorp Vault";

    logo = mkEnableOption "Whether to show vault logo on shell startup";

    gui = mkEnableOption "Whether to enable Vault web GUI inteface";

    open-firewall = mkEnableOption "Whether to open the firewall ports";

    vault-token = mkOption {
      type = types.str;
      default = "/run/secrets/vault-root-token";
      description = "The path to the file containing the vault token";
    };

    backend = mkOption {
      type = types.str;
      default = "file";
      description = ''
        Which backend storage to use

        See services.vault.storageBackend for possible options
      '';
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "What address vault will listen on";
    };

    tls = {
      enable = mkEnableOption "Whether to enable TLS on vault instance";

      cert-key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the TLS certificate private key file";
      };

      cert-file = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the TLS certificate file";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.tls.enable || (cfg.tls.cert-key != null);
        message = ''
          If vault.tls.enable is true then vault.tls.cert-key must be set.
        '';
      }
      {
        assertion = !cfg.tls.enable || (cfg.tls.cert-file != null);
        message = ''
          If vault.tls.enable is true then vault.tls.cert-file must be set.
        '';
      }
    ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings =
        if cfg.tls.enable
        then true
        else false;
      virtualHosts."${cfg.address}" = {
        forceSSL =
          if cfg.tls.enable
          then true
          else false;
        sslCertificate =
          if cfg.tls.enable
          then cfg.tls.cert-file
          else null;
        sslCertificateKey =
          if cfg.tls.enable
          then cfg.tls.cert-key
          else null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8200";
        };
      };
    };

    services.vault = {
      enable = true;
      package =
        if cfg.gui
        then pkgs.vault-bin
        else pkgs.vault;
      storageBackend = cfg.backend;
      address = "127.0.0.1:8200";
      extraConfig = ''
        ${
          if cfg.gui
          then "ui = true"
          else ""
        }
      '';
    };

    environment.systemPackages = [
      pkgs.vault
    ];

    networking.firewall.allowedTCPPorts =
      (
        if cfg.open-firewall
        then [
          80
        ]
        else []
      )
      ++ (
        if (cfg.open-firewall && cfg.tls.enable)
        then [
          443
        ]
        else []
      );
  };
}
