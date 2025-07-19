{vars, ...}: {
  megacorp = {
    config = {
      system.enable = true;
      openssh.enable = true;
      packages.enable = true;
      users = vars.users;
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
