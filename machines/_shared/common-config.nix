{vars, ...}: {
  megacorp = {
    config = {
      system.enable = true;

      users = {
        enable = true;
        admin-user = vars.adminUser;
      };

      packages.enable = true;
    };

    programs.nixvim.enable = true;

    services = {
      prometheus = {
        enable = true;
        node-exporter.enable = true;
      };

      comin = {
        enable = true;
        repo = "https://github.com/rapture-mc/mgc-nixos";
      };
    };
  };

  security.pki.certificates = [
    "${vars.keys.root-cert}"
  ];
}
