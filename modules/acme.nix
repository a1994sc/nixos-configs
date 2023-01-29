{ config, pkgs, lib, ... }: let
  ip = let eth = __elemAt config.networking.interfaces.eth0.ipv4.addresses 0; in eth.address;
  server = "10.2.1.9";
  key = "key.pem";
  cert = "cert.pem";
  fullchain = "fullchain.pem";
  port = "8081";

  acme-sh-script = pkgs.writeShellScriptBin "acme-certs.sh" ''
    ${pkgs.acme-sh}/bin/acme.sh --issue --standalone -d ${ip}.nip.io -d ${ip} --server https://${server}/acme/acme/directory --ca-bundle /etc/nixos/certs/derpy.crt --fullchain-file ${config.users.users.acme.home}/${fullchain} --cert-file ${config.users.users.acme.home}/${cert} --key-file ${config.users.users.acme.home}/${key} --httpport ${port} --force
    /run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl reload nginx
  '';
in {

  users.groups.acme = { };

  users.users.acme = {
    isSystemUser = true;
    group = "acme";
    home = pkgs.lib.mkForce "/etc/acme-sh";
    createHome = true;
  };

  environment.systemPackages = with pkgs; [
    acme-sh
  ];

  security.sudo.extraConfig = ''
    Cmnd_Alias GAME_CMDS = ${pkgs.systemd}/bin/systemctl reload nginx
    ${config.users.users.acme.name} ALL=(ALL) NOPASSWD: GAME_CMDS
  '';

  services.nginx = {
    enable = true;
    user = "acme";
    group = "acme";
    virtualHosts = let
      SSL = {
        addSSL = true;
        sslTrustedCertificate = "${config.users.users.acme.home}/${fullchain}";
        sslCertificateKey = "${config.users.users.acme.home}/${key}";
        sslCertificate = "${config.users.users.acme.home}/${cert}";
        listen = [{port = 443;  addr="0.0.0.0"; ssl=true;}];
      }; in {
        "proxy" = (SSL // {
          serverName = "${ip}";
          locations."/".proxyPass = "http://127.0.0.1:8080/";
        });
        "acme" = {
          serverName = "${ip}";
          listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
          locations."/".proxyPass = "http://127.0.0.1:${port}/";
        };
        "nip" = {
          serverName = "${ip}.nip.io";
          listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
          locations."/".proxyPass = "http://127.0.0.1:${port}/";
        };
      };
  };

  systemd.services.acme-sh= {
    serviceConfig = {
      Type = "oneshot";
      User = "${config.users.users.acme.name}";
    };
    path = with pkgs; [ acme-sh ];
    script = "${acme-sh-script}/bin/acme-certs.sh";
  };

  systemd.timers.acme-sh = {
    wantedBy = [ "timers.target" ];
    partOf = [ "acme-sh.service" ];
    timerConfig = {
      OnCalendar = "48hr";
      Unit = "acme-sh.service";
    };
  };
}
