{ config, pkgs, lib, ... }: let
  piholeResolv = pkgs.writeText "resolv.conf"
    ''
      nameserver 127.0.0.1
    '';
in {
  sops.secrets = {
    pihole = {
      sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
      mode = "0644";
    };
    "id_ed25519" = {
      sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
      mode = "0600";
      key = "sync";
    };
    "id_ed25519.pub" = {
      sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
      mode = "0644";
      key = "sync-pub";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "pihole" = {
        image = "pihole/pihole:latest";
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "8080:80/tcp"
        ];
        environment = {
          TZ = "America/New_York";
          WEBPASSWORD_FILE = "/run/secrets/pihole";
        };
        volumes = [
          "/mnt/docker/pihole/etc-pihole:/etc/pihole"
          "/run/secrets/pihole:/run/secrets/pihole:ro"
          "${piholeResolv}:/etc/resolv.conf:ro"
        ];
        autoStart = true;
        extraOptions = [
          "--cap-add=NET_ADMIN"
        ];
      };
      "pihole-sync-sender" = {
        image = "shirom/pihole-sync:latest";
        environment = {
          NODE = "sender";
          REM_HOST = "10.2.1.7";
          REM_SSH_PORT = "22222";
        };
        volumes = [
          "/mnt/docker/piholesync/root:/root"
          "/mnt/docker/pihole/etc-pihole:/mnt/etc-pihole:ro"
          "/mnt/docker/pihole/etc-dnsmasq.d:/mnt/etc-dnsmasq.d:ro"
          "/run/secrets/id_ed25519:/root/.ssh/id_ed25519:ro"
          "/run/secrets/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro"
        ];
        autoStart = true;
        # extraOptions = [
        #   "--restart always"
        # ];
        dependsOn = [
          "pihole"
        ];
      };
    };
  };
}