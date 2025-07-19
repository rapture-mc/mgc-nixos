{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.megacorp.config.system.ad-domain;

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    toUpper
    types;
in {
  options.megacorp.config.system.ad-domain = {
    enable = mkEnableOption "Join Domain with SSSD";

    domain-name = mkOption {
      type = types.str;
      example = "example.com";
    };

    netbios-name = mkOption {
      type = types.str;
      example = "EXAMPLE";
    };
  };

  config = mkIf cfg.enable {
    security = {
      pam.services.sshd.makeHomeDir = true;

      krb5 = {
        enable = true;
        settings.libdefaults.default_realm = toUpper cfg.domain-name;
      };
    };

    services.sssd = {
      enable = true;
      sshAuthorizedKeysIntegration = true;
      config = ''
        [sssd]
        services = nss, pam, ssh
        config_file_version = 2
        domains = ${cfg.domain-name}
        
        [domain/${cfg.domain-name}]
        default_shell = /run/current-system/sw/bin/zsh
        id_provider = ad
        ldap_sasl_authid = ${builtins.substring 0 15 (toUpper config.networking.hostName)}
        cache_credentials = True
        krb5_real = ${toUpper cfg.domain-name}
        krb5_store_password_if_offline = True
        ldap_sasl_mech = gssapi
        access_provider = ad
        fallback_homedir = /home/%u.%d
        ad_gpo_access_control = permissive
        ad_gpo_ignore_unreadable = True
        ldap_user_extra_attrs = altSecurityIdentities:altSecurityIdentities
        ldap_user_ssh_public_key = altSecurityIdentities
        ldap_use_tokengroups = True
        use_fully_qualified_names = False
        ldap_id_mapping = True
        ad_domain = ${cfg.domain-name}
      '';
    };

    # Samba is configured, but just for the "net" command, to
    # join the domain. A better join method probably exists.
    # `net ads join -U Administrator`
    environment.systemPackages = [ pkgs.samba4Full ];
    systemd.services.samba-smbd.enable = lib.mkDefault false;
    services.samba = {
      enable = true;
      enableNmbd = lib.mkDefault false;
      enableWinbindd = lib.mkDefault false;
      package = pkgs.samba4Full;
      securityType = "ads";
      settings.global = {
        "realm" = "${toUpper cfg.domain-name}";
        "workgroup" = "${toUpper cfg.netbios-name}";
        "client use spnego" = "yes";
        "restrict anonymous" = 2;
        "server signing" = "mandatory";
        "client signing" = "mandatory";
        "kerberos method" = "secrets and keytab";
      };
    };
  };
}
