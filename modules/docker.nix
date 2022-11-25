{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose  
  ];

  users.users.ascii.extraGroups = [ "docker" ];
}