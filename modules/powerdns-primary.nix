{ config, pkgs, lib, ... }: let
  db_user                          = "powerdns";
  db_tabl                          = "powerdns";
  db_host                          = "10.3.10.5";
  db_rep_user                      = "powerdns-rep";
  db_rep_host                      = "10.3.10.6";
in {
  sops.secrets                     = {
    rep-user                       = {
      sopsFile                     = /etc/nixos/secrets/dns/powerdns-primary.yml;
      mode                         = "0600";
    };
    primary-env                    = {
      owner                        = "${config.services.mysql.user}";
      sopsFile                     = /etc/nixos/secrets/dns/powerdns-primary.yml;
      mode                         = "0600";
    };
    tls-crt                        = {
      owner                        = "${config.services.nginx.user}";
      group                        = "${config.services.nginx.group}";
      sopsFile                     = /etc/nixos/secrets/dns/dns1.yml;
      mode                         = "0600";
    };
    tls-key                        = {
      owner                        = "${config.services.nginx.user}";
      group                        = "${config.services.nginx.group}";
      sopsFile                     = /etc/nixos/secrets/dns/dns1.yml;
      mode                         = "0600";
    };
  };

  services.mysql                   = {
    enable                         = true;
    package                        = pkgs.mariadb;
    initialDatabases               = [{
      name                         = "${db_tabl}";
      schema                       = /etc/nixos/modules/database/powerdns.sql;
    }];
    # ensureUsers                    = [{
    #   name                         = "${db_user}";
    #   ensurePermissions            = {
    #     "${db_user}.*"             = "ALL PRIVILEGES";
    #   };
    # }
    # {
    #   name                         = "${db_rep_user}";
    #   ensurePermissions            = {
    #     "*.*"                      = "REPLICATION SLAVE";
    #   };
    # }];
    settings                       = {
      mysqld                       = {
        server_id                  = 1;
        log-basename               = "dns1";
        log-error                  = "/var/lib/mysql/mysql.err";
        log-bin                    = "/var/lib/mysql/mysql-replication.log";
        binlog-format              = "mixed";
      };
    };
  };

  systemd.services.mysql.before    = [ "pdns.service" ];

  services.powerdns                = {
    enable                         = true;
    secretFile                     = "/run/secrets/primary-env";
    extraConfig                    = ''
      launch=gmysql
      gmysql-host=localhost
      gmysql-port=3306
      gmysql-user=${db_user}
      gmysql-dbname=${db_user}
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

  services.nginx                   = {
    enable                         = true;
    virtualHosts                   = {
      "ip"                         = {
        addSSL                     = true;
        sslCertificate             = config.sops.secrets.tls-crt.path;
        sslCertificateKey          = config.sops.secrets.tls-key.path;
        serverName                 = "10.3.10.5";
        listen                     = [{port = 8443;  addr="0.0.0.0"; ssl=true;}];
        locations."/"              = {
          proxyPass                = "http://127.0.0.1:8081/";
        };
      };
      "dns1"                       = {
        addSSL                     = true;
        sslCertificate             = config.sops.secrets.tls-crt.path;
        sslCertificateKey          = config.sops.secrets.tls-key.path;
        serverName                 = "dns1.adrp.xyz";
        listen                     = [{port = 8443;  addr="0.0.0.0"; ssl=true;}];
        locations."/"              = {
          proxyPass                = "http://127.0.0.1:8081/";
        };
      };
    };
  };
}
