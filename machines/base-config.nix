{vars, ...}: {
  megacorp = {
    config = {
      system.enable = true;

      users = {
        enable = true;
        admin-user = vars.adminUser;
      };

      nixvim.enable = true;
      packages.enable = true;
    };

    services = {
      prometheus = {
        enable = true;
        node-exporter.enable = true;
      };
    };
  };
}
