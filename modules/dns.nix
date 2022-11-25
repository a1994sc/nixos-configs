{ config, pkgs, lib, ... }:

{
  services.powerdns.enable = true;

  sops.secrets = {
    powerdns = {
      owner = config.systemd.services.powerdns-admin.serviceConfig.User;
      group = config.systemd.services.powerdns-admin.serviceConfig.Group;
      sopsFile = /etc/nixos/secrets/powerdns.yaml;
      mode = "0600";
    };
    powerdnssalt = {
      owner = config.systemd.services.powerdns-admin.serviceConfig.User;
      group = config.systemd.services.powerdns-admin.serviceConfig.Group;
      sopsFile = /etc/nixos/secrets/powerdnssalt.yaml;
      mode = "0600";
    };
  };

  services.powerdns-admin = {
    enable = true;
    saltFile = "/run/secrets/powerdnssalt";
    secretKeyFile = "/run/secrets/powerdns";
    config = ''
      PORT = 9191
    '';
  };

  networking.networkmanager.insertNameservers = [ "127.0.0.1" ];
}