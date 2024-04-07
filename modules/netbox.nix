{ config, pkgs, lib, ... }:
let
  ip = let eth = __elemAt config.networking.interfaces.eth0.ipv4.addresses 0; in eth.address;
  server = "10.3.10.5";
  hostname = "${config.networking.fqdn}";
  key = "key.pem";
  cert = "cert.pem";
  fullchain = "fullchain.pem";
  port = "8081";

  acme-sh-script = pkgs.writeShellScriptBin "acme-certs.sh" ''
    ${pkgs.acme-sh}/bin/acme.sh --issue --standalone -d ${hostname} -d ${ip}.nip.io -d ${ip} --server https://${server}/acme/acme/directory --ca-bundle /etc/nixos/certs/derpy.crt --fullchain-file ${config.users.users.acme.home}/${fullchain} --cert-file ${config.users.users.acme.home}/${cert} --key-file ${config.users.users.acme.home}/${key} --httpport ${port} --force
    /run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl reload nginx
  '';

  acme-sh-script-init = pkgs.writeShellScriptBin "acme-certs.sh" ''
    ${pkgs.acme-sh}/bin/acme.sh --issue --standalone -d ${hostname} -d ${ip}.nip.io -d ${ip} --server https://${server}/acme/acme/directory --ca-bundle /etc/nixos/certs/derpy.crt --fullchain-file ${config.users.users.acme.home}/${fullchain} --cert-file ${config.users.users.acme.home}/${cert} --key-file ${config.users.users.acme.home}/${key} --force
    ${pkgs.coreutils-full}/bin/chown ${config.users.users.acme.name}:${config.users.users.acme.group} -R ${config.users.users.acme.home}
  '';
in
{
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

  # services.netbox                  = {
  #   enable                         = true;
  #   secretKeyFile                  = "${config.sops.secrets.netbox.path}";
  # };

  sops.secrets.netbox = {
    sopsFile = "/etc/nixos/secrets/dns/netbox.yml";
    mode = "0600";
    owner = "netbox";
    group = "netbox";
  };

  services.nginx = {
    enable = true;
    user = "acme";
    group = "acme";
    virtualHosts =
      let
        SSL = {
          addSSL = true;
          sslTrustedCertificate = "${config.users.users.acme.home}/${fullchain}";
          sslCertificateKey = "${config.users.users.acme.home}/${key}";
          sslCertificate = "${config.users.users.acme.home}/${cert}";
          listen = [{ port = 443; addr = "0.0.0.0"; ssl = true; }];
        };
      in
      {
        "proxy" = (SSL // {
          serverName = "${hostname}";
          locations."/".proxyPass = "http://127.0.0.1:8001";
          locations."/static/" = {
            alias = "${config.services.netbox.dataDir}/static/";
          };
        });
        "acme" = {
          serverName = "${ip}";
          listen = [{ port = 80; addr = "0.0.0.0"; ssl = false; }];
          locations."/".proxyPass = "http://127.0.0.1:${port}/";
        };
        "hostname" = {
          serverName = "${hostname}";
          listen = [{ port = 80; addr = "0.0.0.0"; ssl = false; }];
          locations."/".proxyPass = "http://127.0.0.1:${port}/";
        };
      };
  };

  systemd.services = {
    acme-sh = {
      serviceConfig = {
        Type = "oneshot";
        User = "${config.users.users.acme.name}";
      };
      path = with pkgs; [ acme-sh ];
      script = "${acme-sh-script}/bin/acme-certs.sh";
    };
    acme-sh-init = {
      serviceConfig = {
        Type = "oneshot";
      };
      path = with pkgs; [ acme-sh ];
      script = "${acme-sh-script-init}/bin/acme-certs.sh";
    };
  };

  systemd.timers.acme-sh = {
    enable = true;
    wantedBy = [ "timers.target" ];
    partOf = [ "acme-sh.service" ];
    timerConfig = {
      OnCalendar = "*-*-1,4,7,10,13,16,19,22,25,28 00:00:00";
      Unit = "acme-sh.service";
    };
  };
}
