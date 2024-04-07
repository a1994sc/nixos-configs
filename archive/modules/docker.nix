{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker.logDriver = "journald";
  virtualisation.docker.storageDriver = "overlay2";

  users.users.ascii.extraGroups = [ "docker" ];

  systemd.services."docker-compose@" = {
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
