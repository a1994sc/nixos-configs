{ config, pkgs, lib, ... }:

{
  sops.secrets.env = {
    owner = "${config.services.mysql.user}";
    sopsFile = /etc/nixos/secrets/dns/powerdns.yml;
    mode = "0600";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialDatabases = [
      {
        name = "powerdns";
        schema = /etc/nixos/modules/database/powerdns.sql;
      }
    ];
    ensureUsers = [
      {
        name = "powerdns";
        ensurePermissions = {
          "powerdns.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.mysql.before = [ "pdns.service" ];

  services.powerdns = {
    enable = true;
    secretFile = "/run/secrets/env";
    extraConfig = ''
      launch=gmysql
      gmysql-host=localhost
      gmysql-port=3306
      gmysql-user=powerdns
      gmysql-dbname=powerdns
      gmysql-password=$POWERDNS_MYSQL_PASS
      master=yes
      api=yes
      api-key=$POWERDNS_API_PASS
      webserver=yes
      webserver-allow-from=127.0.0.1,10.0.0.0/8
      webserver-address=0.0.0.0
      webserver-password=$POWERDNS_WEB_PASS
      version-string=anonymous
      default-ttl=1500
      allow-notify-from=0.0.0.0
      allow-axfr-ips=127.0.0.1
      local-port=8154
    '';
  };
}
