{
  defaultGateway = "192.168.1.99";
  privateLANSubnet = "192.168.1.0/24";
  nameServers = ["192.168.1.7"];
  megacorpPrimaryPublicIP = "123.243.147.17";

  hostsAddr = {
    MGC-DRW-BKS01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.42";
    };

    MGC-DRW-BST01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.45";
    };

    MGC-DRW-CLD01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.50";
    };

    MGC-DRW-DGW01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.33";
    };

    MGC-DRW-DMC01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.5";
    };

    MGC-DRW-DNS01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.6";
    };

    MGC-DRW-FBR01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.40";
    };

    MGC-DRW-HVS01.eth = {
      name = "eno1";
      ipv4 = "192.168.1.17";
    };

    MGC-DRW-HVS02.eth = {
      name = "eno1";
      ipv4 = "192.168.1.16";
    };

    MGC-DRW-HVS03.eth = {
      name = "enp6s0";
      ipv4 = "192.168.1.15";
    };

    MGC-DRW-HVS04.eth = {
      name = "enp87s0";
      ipv4 = "192.168.1.18";
    };

    MGC-DRW-GIT01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.44";
    };

    MGC-DRW-MON01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.46";
    };

    MGC-DRW-NBX01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.47";
    };

    MGC-DRW-NXC01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.48";
    };

    MGC-DRW-RST01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.36";
    };

    MGC-DRW-RVP01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.32";
    };

    MGC-DRW-SEM01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.43";
    };

    MGC-DRW-TMS01.eth.ipv4 = "192.168.1.7";

    MGC-DRW-VLT01.eth = {
      name = "ens3";
      ipv4 = "192.168.1.41";
    };
  };
}
