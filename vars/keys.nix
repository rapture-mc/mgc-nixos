{
  # The following keys are permitted to connect to the bastion server over SSH
  authorizedBastionPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhKBbO3gu8cbKQYOopVAA9gkSHHChkjMYPgfW2NIBrN benny@MGC-LT01"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkw50I9jIQ89A9l4E+AiZtZzD+gGoya6u0br3FOxfT6 DWN-STZLR-PC10"
  ];

  # The bastion public key
  bastionPubKey = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzlYmoWjZYFeCNdMBCHBXmqpzK1IBmRiB3hNlsgEtre benny@MGC-DRW-BST01"
  ];

  # The following keys are permitted to connect to the Restic server to upload backups
  resticPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtoZpA5PAW7Ofpu2bQt6leqV++raEMX0tH7P6HOgNIT root@MGC-DRW-PWS01"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIF4qf0OthXgzD4gh2PiVpeRkEmAG7R5nKdl1ueypCY/ root@MGC-DRW-FBR01"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwErc2Z0OV1ngHR04nAS5w0H3lcFisfQZpiDwe3BMFb root@MGC-DRW-BST01"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmPP8QGT8FbY2iJFIgJJH7lVMkIZmeyDJeMf2lwQ+Lw root@MGC-DRW-HVS01"
  ];

  # Hosts whose public SSH key should be trusted when client receives incoming SSH connections
  knownHosts = {
    MGC-DRW-RST01.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISU8bYvbLOkCv2WXHHgYRTLp4XKAqf6V/yg4rc3yhJB";
  };
}
