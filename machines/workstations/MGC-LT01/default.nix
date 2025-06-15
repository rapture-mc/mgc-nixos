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
        MGC-DRW-VLT01 Intermediate CA
        ==============================

        -----BEGIN CERTIFICATE-----
        MIIDojCCAoqgAwIBAgIUb8gfjio47OS2CCqgX9cboTRvmCUwDQYJKoZIhvcNAQEL
        BQAwHjEcMBoGA1UEAxMTbWVnYWNvcnAuaW5kdXN0cmllczAeFw0yNTA2MTUwMzI0
        MDhaFw0yNTEyMTEwNzI0MzhaMBsxGTAXBgNVBAMMEG5ld19pbnRlcm1lZGlhdGUw
        ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDj70T+ZC59PKiNFTfWaHsO
        sljRpUpJFQnnVTplzpIdog9e32+tOAT8vs07uAElyBZJ8KrmADqDXo4RFmZsocQb
        JIpwNnkCsE6gl7kOPmb/JX6ksZMe+JEau8ETT1QOWHjYRlx3/i6hQFSINX73YYvT
        xkGio1Fh5chpOuGmvDUne6JzxhVZAqk58eEHl/caNHmX/r7j7XHULlEzXlNNBrjp
        EGJC5x8VW7rcnV5D/24EcXGV5/t9wxjcjij4xxLX3avAVoGDzP9VOBxfFQRUEslp
        9ujL+3YZnhO4ArstXVNm7zTe2dwo7Msc1WLyLYui2BXl2kJiZlCEQk+mxkLaBzgP
        AgMBAAGjgdowgdcwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYD
        VR0OBBYEFK27wVoXxOiHNDBSmTEXpRH3ksPLMB8GA1UdIwQYMBaAFMlFeVt1Ha+V
        d+Irl5FtBYrgVhHdMD4GCCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAoYiaHR0cDov
        LzE5Mi4xNjguMS40MTo4MjAwL3YxL3BraS9jYTA0BgNVHR8ELTArMCmgJ6AlhiNo
        dHRwOi8vMTkyLjE2OC4xLjQxOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsF
        AAOCAQEANU3HTK/ExfGWtFb7qT+zEZGBiqLgYS0t7bsitLKcjIXppc0a9AjLaWUR
        QOPoQw+EZp2q9kU8dNkZsv7o8XJJDoExGsQ2HcAk29qwaTni4SC/QmOGxARAKVIo
        hgTMkSVI0M+NRbwlLoKv/IgvTcpNYsNcnZdyC+AkFwdQiAx3ZeSpFbgh1cF7fkWw
        fCsrOdieoxA8jWWQKFNL1CmW0lBL/OC32IIQ2V+RXN3Tnh96bA91WoqKr4HLpUMc
        IsWfaXpjYXHAnTF4xKoRcTaZpU98Chk0+xi7FKTd4gNy/AGCsPKR4ivV9PNR1jiA
        C9YiuX3RyG9FTo3C87D4bAn1X8x/wg==
        -----END CERTIFICATE-----
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
