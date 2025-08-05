{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.megacorp.config.system.ad-domain;

  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    mkForce
    mkDefault
    toUpper
    types
    ;
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

    local-auth = {
      # WARNING: These options use experimental PAM options that are potentially subject to change!
      # Set any of these options to false to force authentication for that service through Active Directory instead

      login = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow login access using local Unix authentication";
      };

      sudo = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow sudo access using local Unix authentication";
      };

      sshd = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow sshd access using local Unix authentication";
      };

      xrdp = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow xrdp access using local Unix authentication";
      };
    };
  };

  config = mkIf cfg.enable {
    security = {
      pam.services = {
        login = {
          rules.auth = mkIf (!cfg.local-auth.login) {
            unix.enable = mkForce false;

            sss = {
              control = mkForce "sufficient";
              args = mkForce [
                "likeauth"
                "try_first_pass"
              ];
              order = config.security.pam.services.login.rules.auth.unix.order - 100;
            };
          };
        };

        sudo.rules.auth = mkIf (!cfg.local-auth.sudo) {
          unix.enable = mkForce false;

          sss = {
            control = mkForce "sufficient";
            args = mkForce [
              "likeauth"
              "try_first_pass"
            ];
            order = config.security.pam.services.sudo.rules.auth.unix.order - 100;
          };
        };

        sshd = {
          makeHomeDir = true;

          rules.auth = mkIf (!cfg.local-auth.sshd) {
            unix.enable = mkForce false;

            sss = {
              control = mkForce "sufficient";
              args = mkForce [
                "likeauth"
                "try_first_pass"
              ];
              order = config.security.pam.services.sshd.rules.auth.unix.order - 100;
            };
          };
        };

        xrdp-sesman.rules.auth = mkIf (!cfg.local-auth.xrdp) {
          unix.enable = mkForce false;

          sss = {
            control = mkForce "sufficient";
            args = mkForce [
              "likeauth"
              "try_first_pass"
            ];
            order = config.security.pam.services.xrdp-sesman.rules.auth.unix.order - 100;
          };
        };
      };

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
        # nologin default shell ensures only users that already exist locally are allowed into the system
        default_shell = /run/current-system/sw/bin/nologin
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
    environment.systemPackages = [pkgs.samba4Full];
    systemd.services.samba-smbd.enable = mkDefault false;
    services.samba = {
      enable = true;
      enableNmbd = mkDefault false;
      enableWinbindd = mkDefault false;
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
