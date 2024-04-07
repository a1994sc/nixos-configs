{ config, pkgs, lib, ... }:
let
  db_user = "powerdns";
  db_tabl = "powerdns";
  pd_mast = "10.3.10.5";
  db_rep_user = "powerdns_rep";
in
{
  sops.secrets = {
    rep-user = {
      sopsFile = /etc/nixos/secrets/dns/powerdns-primary.yml;
      mode = "0600";
    };
    replica-env = {
      sopsFile = /etc/nixos/secrets/dns/powerdns-replica.yml;
      mode = "0600";
    };
  };

  # https://www.cherryservers.com/blog/how-to-set-up-postgresql-database-replication
  services.postgresql = {
    enable = true;
    port = 3306;
    package = pkgs.postgresql_15;
    dataDir = "/var/lib/postgresql";
  };

  systemd.services.postgresql = {
    before = [ "pdns.service" ];
  };

  services.powerdns = {
    enable = true;
    secretFile = "/run/secrets/replica-env";
    extraConfig = ''
      launch=gpgsql
      gpgsql-host=localhost
      gpgsql-port=3306
      gpgsql-user=${db_user}
      gpgsql-dbname=${db_user}
      gpgsql-password=$POWERDNS_MYSQL_PASS
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
