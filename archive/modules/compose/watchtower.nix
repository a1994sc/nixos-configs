{ config, pkgs, lib, ... }: let

in {
  imports = [ 
    /etc/nixos/modules/compose/docker.nix
  ];

  virtualisation.oci-containers.containers."watchtower" = {
    image = "containrrr/watchtower";
    environment = {
      WATCHTOWER_CLEANUP = "true";
      WATCHTOWER_INCLUDE_RESTARTING = "true";
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/etc/timezone:/etc/timezone:ro"
    ];
    autoStart = true;
  };
}
