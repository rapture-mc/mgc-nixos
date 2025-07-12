{vars, ...}: {
  megacorp = {
    config = {
      system.enable = true;
      openssh.enable = true;
      packages.enable = true;
      users = {
        ${vars.adminUser} = {
          sudo = true;
          authorized-ssh-keys = vars.keys.bastionPubKey;
        };
      };
    };

    programs.nixvim.enable = true;

    services.comin = {
      enable = true;
      repo = "https://github.com/rapture-mc/mgc-nixos";
    };
  };

  security.pki.certificates = [
    "${vars.keys.rootCert}"
  ];
}
