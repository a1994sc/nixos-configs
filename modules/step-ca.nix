{ config, lib, pkgs, ... }: let
  step-path = "/var/lib/step-ca";
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
      dnsNames = [ "10.2.1.9" ];
      root = "/etc/nixos/certs/root_ca.crt";
      crt = "/etc/nixos/certs/intermediate_ca.crt";
      key = "${step-path}/ca.key";
      db = {
        type = "badgerV2";
        dataSource = "/var/lib/step-ca/db";
      };
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "168h";
          defaultTLSCertDuration = "192h";
        };
        provisioners = [{
          type = "ACME";
          name = "acme";
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
    "d /var/lib/step-ca 700 step-ca step-ca"
    "Z /var/lib/step-ca 700 step-ca step-ca"
  ];

  systemd.services."step-ca" = {
    serviceConfig = {
      WorkingDirectory = lib.mkForce "/var/lib/step-ca";
      Environment = lib.mkForce "Home=/var/lib/step-ca";
      User = "step-ca";
      Group = "step-ca";
      DynamicUser = lib.mkForce false;
    };
  };
}