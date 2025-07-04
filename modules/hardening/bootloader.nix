{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.megacorp.hardening.bootloader;
in {
  options.megacorp.hardening.bootloader = {
    enable = mkEnableOption ''
      Whether to enable bootloader hardening.

      This will lock down grub so that any operation except for selecting the default grub entry will require a password.
    '';

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The username for the grub account";
    };

    password-file = mkOption {
      type = types.str;
      default = "/run/secrets/grub-admin-password";
      description = ''
        The path to the hashed password file for the grub admin user.
        Password is hashed because /boot/grub/grub.cfg is readable by anyone.

        Use "grub-mkpasswd-pbkdf2" (available in the grub2 package) to generate the password.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.enable || (cfg.user != null);
        message = "${cfg.user} must be set if ${cfg.enable} is true";
      }
    ];

    boot.loader.grub.users.${cfg.user}.hashedPasswordFile = cfg.password-file;
  };
}
