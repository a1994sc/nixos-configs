{ config, pkgs, lib, ... }: let
  db_user = "powerdns-rep";
  db_tabl = "powerdns";
  pd_mast = "10.3.10.5";
in {
  sops.secrets.replica-env = {
    owner = "${config.services.mysql.user}";
    sopsFile = /etc/nixos/secrets/dns/powerdns-replica.yml;
    mode = "0600";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialDatabases = [
      {
        name = "${db_tabl}";
        schema = /etc/nixos/modules/database/powerdns.sql;
      }
    ];
    ensureUsers = [
      {
        name = "${db_user}";
        ensurePermissions = {
          "${db_user}.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.mysql.before = [ "pdns.service" ];

  services.powerdns = {
    enable = true;
    secretFile = "/run/secrets/replica-env";
    extraConfig = ''
      launch=gmysql
      gmysql-host=localhost
      gmysql-port=3306
      gmysql-user=${db_user}
      gmysql-dbname=${db_user}
      gmysql-password=$POWERDNS_MYSQL_PASS
      master=no
      slave=yes
      slave-cycle-interval=60
      default-ttl=1500
      allow-notify-from=0.0.0.0
      allow-axfr-ips=${pd_mast}/32
      local-port=8154
    '';
  };
}
