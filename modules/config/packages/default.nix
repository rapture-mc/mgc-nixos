{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.packages;

  inherit
    (lib)
    mkIf
    mkEnableOption
    optionals
    ;
in {
  imports = [
    ./bash-scripts.nix
    ./desktop.nix
  ];

  options.megacorp.config.packages = {
    enable = mkEnableOption "Whether to enable Megacorp packages.";

    ninja-cli.enable = mkEnableOption "Whether to install pentesting cli tools too (makes you a internet ninja!)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        alejandra
        age
        bat
        dig
        file
        gcc
        git
        jq
        lazygit
        lshw
        gnumake
        ncdu
        nh
        ripgrep
        screen
        sops
        ssh-to-age
        sshpass
        speedtest-cli
        traceroute
        tree
        tldr
        unzip
        viddy
        vim
        wget
      ]
      ++ optionals cfg.ninja-cli.enable [
        monero-cli
        mullvad
        nuclei
        subfinder
      ];
  };
}
