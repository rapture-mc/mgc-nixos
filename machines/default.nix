{importMachineConfig, ...}: {
  # Servers
  MGC-DRW-APS01 = importMachineConfig "servers" "MGC-DRW-APS01";
  MGC-DRW-BKS01 = importMachineConfig "servers" "MGC-DRW-BKS01";
  MGC-DRW-BST01 = importMachineConfig "servers" "MGC-DRW-BST01";
  MGC-DRW-CLD01 = importMachineConfig "servers" "MGC-DRW-CLD01";
  MGC-DRW-DGW01 = importMachineConfig "servers" "MGC-DRW-DGW01";
  MGC-DRW-DMC01 = importMachineConfig "servers" "MGC-DRW-DMC01";
  MGC-DRW-DMC02 = importMachineConfig "servers" "MGC-DRW-DMC02";
  MGC-DRW-FBR01 = importMachineConfig "servers" "MGC-DRW-FBR01";
  MGC-DRW-GIT01 = importMachineConfig "servers" "MGC-DRW-GIT01";
  MGC-DRW-MON01 = importMachineConfig "servers" "MGC-DRW-MON01";
  MGC-DRW-NBX01 = importMachineConfig "servers" "MGC-DRW-NBX01";
  MGC-DRW-NXC01 = importMachineConfig "servers" "MGC-DRW-NXC01";
  MGC-DRW-RST01 = importMachineConfig "servers" "MGC-DRW-RST01";
  MGC-DRW-RVP01 = importMachineConfig "servers" "MGC-DRW-RVP01";
  MGC-DRW-SEM01 = importMachineConfig "servers" "MGC-DRW-SEM01";
  MGC-DRW-VLT01 = importMachineConfig "servers" "MGC-DRW-VLT01";
  test-machine = importMachineConfig "servers" "test-machine";

  # Hypervisors
  MGC-DRW-HVS01 = importMachineConfig "hypervisors" "MGC-DRW-HVS01";
  MGC-DRW-HVS02 = importMachineConfig "hypervisors" "MGC-DRW-HVS02";
  MGC-DRW-HVS03 = importMachineConfig "hypervisors" "MGC-DRW-HVS03";
  MGC-DRW-HVS04 = importMachineConfig "hypervisors" "MGC-DRW-HVS04";

  # Workstations
  MGC-LT01 = importMachineConfig "workstations" "MGC-LT01";
  MGC-LT02 = importMachineConfig "workstations" "MGC-LT02";
}
