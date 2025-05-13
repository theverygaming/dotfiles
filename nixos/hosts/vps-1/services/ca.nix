{
  config,
  flakeInputs,
  pkgs,
  ...
}:

{
  custom.wg_mesh.firewall.allowedTCPPorts = [
    8443
  ];

  sops.secrets.ca_password = {
    key = "password";
    sopsFile = flakeInputs.secrets + "/hosts/${config.networking.hostName}/ca.yaml";
    owner = config.users.users.step-ca.name;
    group = config.users.users.step-ca.group;
  };

  sops.secrets.ca_intermediate_key = {
    key = "intermediate_ca_key";
    sopsFile = flakeInputs.secrets + "/hosts/${config.networking.hostName}/ca.yaml";
    owner = config.users.users.step-ca.name;
    group = config.users.users.step-ca.group;
  };

  services.step-ca = {
    enable = true;
    openFirewall = false;
    address = "10.13.12.1";
    port = 8443;
    intermediatePasswordFile = config.sops.secrets.ca_password.path;
    settings = {
      root = pkgs.writeText "root_ca.crt" ''
        -----BEGIN CERTIFICATE-----
        MIIBjDCCATKgAwIBAgIRAIrIXrNg6iv7fMPaZWa8YI4wCgYIKoZIzj0EAwIwJDEM
        MAoGA1UEChMDdXd1MRQwEgYDVQQDEwt1d3UgUm9vdCBDQTAeFw0yNTA1MTMxOTIy
        MzJaFw0zNTA1MTExOTIyMzJaMCQxDDAKBgNVBAoTA3V3dTEUMBIGA1UEAxMLdXd1
        IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQO00kuubBlg3tIUYZT
        gZY81dty01zM/k/wkHXS6oLz13kaKWZqzdFAfqm7KHz7A8oQXfbwQBQjrg1BS6Lr
        NLDCo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNV
        HQ4EFgQUNdvO5aYqgKAW/rX1SKntAZmZqs4wCgYIKoZIzj0EAwIDSAAwRQIgAjfg
        RVAzzrtG1ZoS5u97DlGKCHlzYTP5+ay1NOxneswCIQDxs7mDc+7umJ/nOBMiAiI9
        cSUW5KcgaacjuytC5X3Ddw==
        -----END CERTIFICATE-----
      '';
      federatedRoots = null;
      crt = pkgs.writeText "intermediate_ca.crt" ''
        -----BEGIN CERTIFICATE-----
        MIIBtDCCAVqgAwIBAgIQbQRYztYVUP892V0/1qdvKTAKBggqhkjOPQQDAjAkMQww
        CgYDVQQKEwN1d3UxFDASBgNVBAMTC3V3dSBSb290IENBMB4XDTI1MDUxMzE5MjIz
        M1oXDTM1MDUxMTE5MjIzM1owLDEMMAoGA1UEChMDdXd1MRwwGgYDVQQDExN1d3Ug
        SW50ZXJtZWRpYXRlIENBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEmtgQsiiT
        lTvYp0PWGFTY8Ec+CWngRRULbm3MaCX3fyoWctVaReQymxicTujgChNyaZ30hRC0
        XO5R/s1mq/W6w6NmMGQwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8C
        AQAwHQYDVR0OBBYEFBMqeqhiSMuYeQvnNspEdfowUzsTMB8GA1UdIwQYMBaAFDXb
        zuWmKoCgFv619Uip7QGZmarOMAoGCCqGSM49BAMCA0gAMEUCICYIfUVQBfWxMXet
        vfseugtoyPvZSq9zJuSolB+E+9oAAiEAg0LLFJB+a/ARHUSFoZKBe0sHJrAjouW5
        FzgMx7hoiLY=
        -----END CERTIFICATE-----
      '';
      key = config.sops.secrets.ca_intermediate_key.path;
      dnsNames = [
        "ca.local.services.theverygaming.furrypri.de"
      ];
      logger = {
        format = "text";
      };
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority = {
        provisioners = [
          {
            type = "JWK";
            name = "meee@theverygaming.furrypri.de";
            key = {
              use = "sig";
              kty = "EC";
              kid = "Rh6ShumNKe5vLlpHNWXOLNlIYBgdHiuWA-Gv_WYbARk";
              crv = "P-256";
              alg = "ES256";
              x = "dXv4AJkESQ9Vydq4g2s_eH737SA2vnuvKCa0Z83rB0E";
              y = "E5nnzJLv-MjXhegY3uxKjGzC0SEDkQVytu1S8B7UxVs";
            };
            # having this public is.. probably fine? :tm:
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiQllpcEE3X09aeFUzeDRueGs5dE1LQSJ9.c7rP9d1PeHDfHKGwlL5qwYubP5UH1PFfuVoSkpjKGISq41Wx8Ei7ug.L3oFJCYpgnJFqazc.jRtlg6ehHnnh1E_W6p4jX_f-iGG4JCmoeiDhsMMvZMx-1efds-fkioQxl6Mx4SV-Ki9gs_E-eASPCcl5OcxsF99UZQljJw1mNSRPiKgoA2UM6QzqIhotig4A0J7kCYKhbESMP_MO--ImnVyYLV9VnwPOxNt2fMfOa9jrsVinjUUJFkTg6t73WSMgKUPFwDl7dxEnnWC1OHrfkRTTL5-SrMjb_NrsAqItnlFbqRbMrRqE4sHJqF8HKUsugirQx1rkip3_9DjrdEiaH1FN65n30KzZbAIHyc9aKEfRpMpC7g7N_zu9c4nOotdJUWoxGdnToKI6AKOvwXPuMS49umo.T8etacRhhpPcOEPj7C4PoQ";
          }
          {
            type = "ACME";
            name = "acme";
            claims = {
              enableSSHCA = true;
              disableRenewal = false;
              allowRenewalAfterExpiry = false;
              disableSmallstepExtensions = false;
            };
            options = {
              x509 = { };
              ssh = { };
            };
          }
        ];
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
