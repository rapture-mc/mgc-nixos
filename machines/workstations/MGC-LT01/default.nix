{
  nixpkgs,
  self,
  vars,
  pkgs,
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

      networking.hostName = "MGC-LT01";

      system.stateVersion = "24.05";

      environment.systemPackages = with pkgs; [
        awscli2
        discord
        flameshot
        hello
        hledger
        hugo
        qbittorrent
        spotify
        sioyek
      ];

      virtualisation.docker.enable = true;

      services.nginx = {
        enable = true;
        virtualHosts."localhost" = {
          root = "/var/www/doco";
        };
      };

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

        MGC-DRW-VLT02 Root Certificate
        -----BEGIN CERTIFICATE-----
        MIIDxTCCAq2gAwIBAgIUbHTOkk9PR59r2ZptLgm+oCxbvIowDQYJKoZIhvcNAQEL
        BQAwHjEcMBoGA1UEAxMTbWVnYWNvcnAuaW5kdXN0cmllczAeFw0yNTA2MTYwMzAy
        NTNaFw0zNTA2MTQwMzAzMjNaMB4xHDAaBgNVBAMTE21lZ2Fjb3JwLmluZHVzdHJp
        ZXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCy8bCzJx7DDr5/Pkxd
        oL74OzoS6Hnv1zT9VYYNAXRohTZRRFcp5NsKo2Z4tWNYzgMDc4FWKf2CZnQ10QvS
        poetI/XtC9ybWCN9SbB4X/nAeaJ7+nXeiC8X4NtQURDRV2YUNbT+LyL6oyeCoLm9
        nfCZzO+N0foK7Mt4VYSpyoMose4z61fRGNkupvmGcL7PGlEBwi5oN0RkYB9kMSmq
        +7zlRx7xt2eA//qjYwkG5qy8C2lF9AK/6Ab41TnRFeCI7t1WYe/Ef0QO5XP2x9Ie
        vCCoTs7U8QCgwHB3RsBHBgrweUdJdFgcDSYDxHrPHym8jkQLWWTQ0LyCn0qadtHe
        /AYpAgMBAAGjgfowgfcwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8w
        HQYDVR0OBBYEFDsR3IjnAxBvwBZnGLc+3S0MOSwSMB8GA1UdIwQYMBaAFDsR3Ijn
        AxBvwBZnGLc+3S0MOSwSMD4GCCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAoYiaHR0
        cDovLzE5Mi4xNjguMS40Mjo4MjAwL3YxL3BraS9jYTAeBgNVHREEFzAVghNtZWdh
        Y29ycC5pbmR1c3RyaWVzMDQGA1UdHwQtMCswKaAnoCWGI2h0dHA6Ly8xOTIuMTY4
        LjEuNDI6ODIwMC92MS9wa2kvY3JsMA0GCSqGSIb3DQEBCwUAA4IBAQCpy/4snrvF
        Osm1N5+h04KXuiCYtgE3k0AKuh1iHeLgPjZMjhTloCvhvtj5F4uuJDiKOXI2H68l
        myn4oayJVFHgviCFo+wBryMZO+jHjTGpQsC0Z6MyQT96sLEDADy81WxZNAfzcN9b
        SDO1ik6+bvG+nbdzJR6nvrssPc/3DBsuprWf6Oqeeg6dX14UeZD+LiaY63tqjDV2
        O7QAdtr61Vt8In41nIp9xJAcqtX5wIRfjTxC8ES3r8L4y6ymgFMaaLcgsFSJUEPL
        Akg+QwgM/FZ3hlLVLQd0AVKqepJ8uhgM2FYOJ5Vy3yAKjsRyTNtV2wwy/HW7+62i
        eni7T57qvQg2
        -----END CERTIFICATE-----
        ''
      ];

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };

          desktop.enable = true;
        };

        programs.pass.enable = true;

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
