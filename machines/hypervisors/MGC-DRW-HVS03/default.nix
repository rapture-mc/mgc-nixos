{
  nixpkgs,
  pkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ./hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      nixpkgs.config.allowUnfree = true;

      networking.hostName = "MGC-DRW-HVS03";

      system.stateVersion = "24.05";

      environment.systemPackages = with pkgs; [
        devenv
        direnv
        hugo
      ];

      services.xserver.enable = true;

      security.pki.certificates = [
        ''
        MGC-DRW-VLT01 Root Certificate
        ==============================
        -----BEGIN CERTIFICATE-----
        MIIDTzCCAjegAwIBAgIUIOB3FtWwJB6HUgbGaOmXhL5U0wMwDQYJKoZIhvcNAQEL
        BQAwHjEcMBoGA1UEAxMTbWVnYWNvcnAuaW5kdXN0cmllczAeFw0yNTA2MTQxMDMz
        NTNaFw0zNTA2MTIxMDM0MjNaMB4xHDAaBgNVBAMTE21lZ2Fjb3JwLmluZHVzdHJp
        ZXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTzfNaQsJt6ahmaOoO
        PHzjBVSYw2NLcge3Li5JDhk/xoOexSf4YrIRSDFgHJUBpxy+9iXiz28RSooqcgQv
        NWhMG1iwEAGBiMte7AjspSobk4vYWcWVT2jb6waZ78oo2Odp9lgeDBuAN5EhwqNh
        R7cbaM8drZxiuGAqW1YLnv2pIJYZ1w92QfYHc10+6ITaWHoj3lEtyQJghKZMHA9H
        vJ5SUtKsajY9ZO4rKKyKKOmVD8h0rV5ymCQC/XDlDT2ZWCoe8NqNAk2TIcTpQ+a9
        8oShY/QMMP85/bgvutnHE8Gpj62n7WZXAel4YjCT5hxzJBOY1olgwrvepNzjM0+5
        W5oZAgMBAAGjgYQwgYEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8w
        HQYDVR0OBBYEFMlFeVt1Ha+Vd+Irl5FtBYrgVhHdMB8GA1UdIwQYMBaAFMlFeVt1
        Ha+Vd+Irl5FtBYrgVhHdMB4GA1UdEQQXMBWCE21lZ2Fjb3JwLmluZHVzdHJpZXMw
        DQYJKoZIhvcNAQELBQADggEBALglBMrVv3ty6ViyTGNvOa7wo1P5lLPF4ohv2dfp
        Id+yyRI1p2G+T9VAYsxXoCtpG3rg+msFb+3eyffUJlozSf9OqxOdIEZB813sirin
        ol+NddmO9i6VMJiBM5PPZEWO2aIA02xQUs2DhoyUY66zSu+NGndw6NNsiqZuMj+j
        etazpTl6sUOcF79+WyUgNRFQEL2Lqhw0XGO9j5hwZCFjmYbaxSfG06i2Ozqjazgb
        mouwe3PEK3k4TqcfihsdGnhj7RYjE22cLaAjO0BnqtVKK7+7zgtswKAfuEm3S3DZ
        M++BDsTUu47+h7ly/lRaK0DkMNtNIVwCI4r9feY8Zh20d78=
        -----END CERTIFICATE-----
        ''
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.networking.internalDomain;
            };
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };

          desktop = {
            enable = true;
            xrdp = true;
          };
        };

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };
        };

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
