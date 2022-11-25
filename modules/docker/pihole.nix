{ config, pkgs, lib, ... }:

{
  sops.secrets = {
    pihole = {
      sopsFile = /etc/nixos/secrets/pihole.yaml;
      mode = "0644";
    };
  };

  systemd.services."docker-compose@pihole" = {
    enable = true;
  };
}