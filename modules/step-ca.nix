{ config, lib, pkgs, ... }: let
  step-path = "/var/lib/step-ca";
  ip = let eth = __elemAt config.networking.interfaces.eth0.ipv4.addresses 0; in eth.address;
in {
  sops.secrets = {
    pass = {
      sopsFile = /etc/nixos/secrets/step-ca.yaml;
      mode = "0600";
      owner = "step-ca";
      group = "step-ca";
      path = "${step-path}/pass";
    };
    ca = {
      sopsFile = /etc/nixos/secrets/step-ca.yaml;
      mode = "0600";
      owner = "step-ca";
      group = "step-ca";
      path = "${step-path}/ca.key";
    };
  };

  services.step-ca = {
    enable = true;
    openFirewall = false;
    port = 443;
    intermediatePasswordFile = "${step-path}/pass";
    address = "0.0.0.0";
    settings = {
      dnsNames = [ "${ip}" ];
      root = "/etc/nixos/certs/derpy.crt";
      crt = "/etc/nixos/certs/derpy-jump.crt";
      key = "${step-path}/ca.key";
      db = {
        type = "badgerV2";
        dataSource = "${step-path}/db";
      };
      logger.format = "text";
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          defaultTLSCertDuration = "168h";
          maxTLSCertDuration = "192h";
        };
        provisioners = [{
          type = "ACME";
          name = "acme";
        }
        {
          type = "JWK";
          name = "ca@conlon.dev";
          encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiMGxHeHZCenp5NENtbmxEazFsSnphdyJ9.Lu9aGOWwelk3-kdYG9074YKQvl9GeLJ2oI7iX9kTzYxs8JznTbTSXw.X4IOfMajiUqV6Hd8.vtbgEs3N8C857RTGkqV5QM4IWpFfVr3sjwEeYr4sw1wHMdrG7GhdjBHWvoBfrKDsa5WaG9G3GZXLLnPd2eeXphxUBa9y6KpDORw2Uwtjm700dnt6DBlJShqcBkgvJt7SYQhySJ9ajQX4ZBRz5W12sprKShmpvwIvQLW-0Z1bRwHvbiusWCxfLVQShzkrryeRkGSHoGC-uFW2Y4899U7c0juNgqtVQXaE5SdiBWK0209f4LPmjRUKeaPDE03_2wEL3iv3mhbKEmEldqY7Rpj7lCKxTbt9_o5L-eMChV31LuoaxvkUI0iHyhwMaFj1TBBhrO7NiQ_QOp4ViKEfp8A.GKv5ZkgKl2Mu8aoGD_NIeg";
          key = {
            use = "sig";
            kty = "EC";
            crv = "P-256";
            alg = "ES256";
            kid = "ZteIoNH1VzfhfCwgb8pYd7E72LR5-a1i2VmN-tmVnho";
            x = "Ipkyt1hJ0a5jpdFvkm97mQTF3m5JPg78izuK8XyILaE";
            y = "lgQ4iOHfIaEElyy9GOOq0BsQGYx4MCLiQqjWbrM4eTw";
          };
        }
        {
          type = "JWK";
          name = "kube@adrp.xyz";
          encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiUENBN011djZmMVF6TVBVOEpwS2FYdyJ9.aAuxNbFJCxPEbfRwDMJxmQGQRhzVUh7KWwimuzDrr6k-dY1_3-_AVQ.-Qjts0c27pA0g9Yn.2aI-1HPGWFL8VxC0I8WVMHd6nHjkavI0aN99aZWA7Q02oR81aeMIU8v8Dm68PPWvn8no5LiD9abbGY_lQM96qfZOQoyU6jMmyAbWYNUcMi2gqJNZU-ckjrUDnTVzNTCZ8ARDj8j79ZoMM-g9n2qVW1PnSUhk1FzvXeRtMZBIXtmLNunPu8vmuvPpKcBfHagIeVVUCEeJmBodjB9m8doOly-jMbAagT5cB2tOFvpmMfj0N7CrzHUr7nicW5kgmTKpM-GAcyVTPI2bvDVwfjMcekwKhn66kMpeys5XTJRqikUK-Pxr45R-HzhyDcYrdsnii6hIoKhjNB5XQah3kyo.C_jjxBwZyD-jD8FHk9eIPw";
          key = {
            use = "sig";
            kty = "EC";
            kid = "p2-tlIQtHRJdfwu2TzaPrQcY0o7oZYqTXi-194stWhE";
            crv = "P-256";
            alg = "ES256";
            x = "iFfNBs_UasvrNs050b4DqlRqE79XmB70mWpZbrS4kas";
            y = "zc7u6gfL3-xpNzM7jzsn7BCOTLOlvAhAJheY72uy4Sg";
          };
        }];
      };
    };
  };

  users.users.step-ca = {
    extraGroups = [ "secrets" ];
    group = "step-ca";
    isSystemUser = true;
  };
  users.groups.step-ca = { };

  systemd.tmpfiles.rules = [
    "d ${step-path} 700 step-ca step-ca"
    "Z ${step-path} 700 step-ca step-ca"
  ];

  systemd.services."step-ca" = {
    serviceConfig = {
      WorkingDirectory = lib.mkForce "${step-path}";
      Environment = lib.mkForce "Home=${step-path}";
      User = "step-ca";
      Group = "step-ca";
      DynamicUser = lib.mkForce false;
    };
  };
}
