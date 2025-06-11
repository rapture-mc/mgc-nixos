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
    };
  };
}
