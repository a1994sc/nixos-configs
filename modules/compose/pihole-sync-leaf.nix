{ config, pkgs, lib, ... }:

{
  sops.secrets = {
    pihole = {
      sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
      mode = "0644";
    };
    sync = {
      sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
      mode = "0700";
    };
  };

  systemd.services."docker-compose@pihole-sync-leaf" = {
    enable = true;
    unitConfig = {
      Description = "%i service with docker compose";
      PartOf = "docker.service";
      After = "docker.service";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/nixos/compose/%i";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
  };
}