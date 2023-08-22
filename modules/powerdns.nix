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

  services.powerdns = {
    enable = true;
    extraConfig = ''
      launch=gmysql
      gmysql-host=127.0.0.1
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

      # gmysql_host=127.0.0.1
      # gmysql_port=3306
      # gmysql_user=powerdns
      # gmysql_dbname=powerdns
      # gmysql_password=$POWERDNS_MYSQL_PASS
