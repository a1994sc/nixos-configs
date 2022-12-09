{ config, pkgs, lib, ... }:

{
  # sops.example = {
  #   example = {
  #     sopsFile = /etc/nixos/secrets/example.yaml;
  #     mode = "0644";
  #   };
  # };

  systemd.services."docker-compose@" = {
    enabled = false;
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
