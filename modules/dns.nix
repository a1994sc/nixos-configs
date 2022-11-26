{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/modules/database.nix
  ];

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

  services.mysql.initialDatabases.powerdns.name = "powerdns";
  services.mysql.ensureUsers.powerdns = {
    name = "powerdns";
    ensurePermissions = {
      "${config.services.mysql.ensureUsers.powerdns.name}.*" = "ALL PRIVILEGES";
    };
  };

  services.powerdns-admin = {
    enable = true;
    saltFile = "/run/secrets/powerdnssalt";
    secretKeyFile = "/run/secrets/powerdns";
    config = ''
      PORT = 9191
      SQLALCHEMY_DATABASE_URI = 'mysql://{}:{}@{}/{}'.format(
         urllib.parse.quote_plus(${config.services.mysql.ensureUsers.powerdns.name}),
         urllib.parse.quote_plus(),
         127.0.0.1,
         ${config.services.mysql.initialDatabases.powerdns.name}
      )
    '';
  };

  networking.networkmanager.insertNameservers = [ "127.0.0.1" ];
}