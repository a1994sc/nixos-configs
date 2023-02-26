{ config, pkgs, lib, ... }: let
  piholeResolv = pkgs.writeText "resolv.conf"
    ''
      nameserver 127.0.0.1
    '';
in {
  imports = [ 
    /etc/nixos/modules/compose/docker.nix
  ];

  sops.secrets.pihole = {
    sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
    mode = "0644";
  };

  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "127.0.0.1:8080:80/tcp"
    ];
    environment = {
      TZ = "America/New_York";
      WEBPASSWORD_FILE = "/run/secrets/pihole";
      # PIHOLE_DNS_ = "10.2.1.6#5053;10.2.1.7#5053";
    };
    volumes = [
      "/mnt/docker/pihole/etc-pihole:/etc/pihole"
      "/run/secrets/pihole:/run/secrets/pihole:ro"
      "${piholeResolv}:/etc/resolv.conf:ro"
    ];
    autoStart = true;
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--pull=always"
    ];
  };
}
