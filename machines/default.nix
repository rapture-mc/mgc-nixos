{importMachineConfig, ...}: {
  # Servers
  MGC-DRW-BST01 = importMachineConfig "servers" "MGC-DRW-BST01";
  MGC-DRW-DMC01 = importMachineConfig "servers" "MGC-DRW-DMC01";
  MGC-DRW-RST01 = importMachineConfig "servers" "MGC-DRW-RST01";
  MGC-DRW-RVP01 = importMachineConfig "servers" "MGC-DRW-RVP01";
  MGC-DRW-DGW01 = importMachineConfig "servers" "MGC-DRW-DGW01";
  MGC-DRW-FBR01 = importMachineConfig "servers" "MGC-DRW-FBR01";

  # Hypervisors
  MGC-DRW-HVS01 = importMachineConfig "hypervisors" "MGC-DRW-HVS01";
  MGC-DRW-HVS02 = importMachineConfig "hypervisors" "MGC-DRW-HVS02";
  MGC-DRW-HVS03 = importMachineConfig "hypervisors" "MGC-DRW-HVS03";

  # Workstations
  MGC-LT01 = importMachineConfig "workstations" "MGC-LT01";
  MGC-LT02 = importMachineConfig "workstations" "MGC-LT02";
}
