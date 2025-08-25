{lib}: let
  users = {
    "ben.harris" = {
      sudo = true;
      authorized-ssh-keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzlYmoWjZYFeCNdMBCHBXmqpzK1IBmRiB3hNlsgEtre benny@MGC-DRW-BST01"
      ];
    };
  };

  # Allows the name attribute to be referenced like vars.users."john.smith".name in configurations
  finalUsers = lib.mapAttrs (name: value:
    value
    // {
      name = name;
    })
  users;
in
  finalUsers
