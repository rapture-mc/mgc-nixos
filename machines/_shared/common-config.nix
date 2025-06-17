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
    ''
    MGC-DRW-VLT02 Intermediate Certificate
    ======================================
    -----BEGIN CERTIFICATE-----
    MIIDojCCAoqgAwIBAgIUN105jZhJ/mGDlOe3AcTXaltPwvswDQYJKoZIhvcNAQEL
    BQAwHjEcMBoGA1UEAxMTbWVnYWNvcnAuaW5kdXN0cmllczAeFw0yNTA2MTYwMzAy
    NTRaFw0yNTEyMTIwNzAzMjRaMBsxGTAXBgNVBAMMEG5ld19pbnRlcm1lZGlhdGUw
    ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCgM3zKjZCjlz3FKpkTiur9
    GTAauGfBahNsb2VNeF4R7vQwBB2VDfoH0EHmphCagDGSlBjAVyMt4mOUp9LyvJ7h
    JSddcz9QCzZ/OD/Tnf2Cx/cj8N2EeziupguPP4oD7+io1L3XVB4B5JbSFwfo5AjG
    3SdRFZ/KS7+kVOj0ccfG6t3Mj5ELvvtG79+a5Vjd9Puj1ziwknMcNAkPHs4z8m45
    RxOKTeqMjRgrVex/q7OOTelauzs2w4vkihwOHiWLWuGY/IIiCaTbSU3+9au2NmvT
    iIOoD+k8ppM1tC4cVQiSvi3fg+UlrZfnORaT/IjtTvX8dPmGS3dA+YZOYsiOLXDP
    AgMBAAGjgdowgdcwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYD
    VR0OBBYEFAhB3lyN0RII+XtBzRtBoqJJ2sZlMB8GA1UdIwQYMBaAFDsR3IjnAxBv
    wBZnGLc+3S0MOSwSMD4GCCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAoYiaHR0cDov
    LzE5Mi4xNjguMS40Mjo4MjAwL3YxL3BraS9jYTA0BgNVHR8ELTArMCmgJ6AlhiNo
    dHRwOi8vMTkyLjE2OC4xLjQyOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsF
    AAOCAQEArMLOPGDPWBhHy5kg87LI4z26lnDIOqsHqcHFiU4azx5sPChg0mGLHhr9
    unMpDgZwAd+2ov0/n2BY3j2jd2Z4RM2FUefIYLVd0JVACzY3J3aMOEvqS5+5w3OU
    8QWY0qBcLUi6rJKRk1C6tS+ieQ7YGVmqaO0b50vqSqC+HCw29oYS5Ep/b/BLNv6s
    Vdoziyr9nh2NCS4DJyy8gZ+8Km1hkte3mtzwl90J76JXaOR8W42QeDXilUXne5yf
    nfE2trjxApchLbOfzVBcuKp6hJMs5ta1nDWXi2QyfMP/K8Vtd9whyN2sU2qgTCeq
    cmvH4TxmtxGxmOKToyvHPYXZMlsxvA==
    -----END CERTIFICATE-----

    MGC-DRW-VLT02 Root Certificate
    ==============================
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
}
