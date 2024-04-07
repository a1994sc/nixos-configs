{ config, pkgs, lib, ... }:
let

in {
  imports = [
    ./.
    /etc/nixos/modules/compose/pihole.nix
  ];

  sops.secrets = {
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

  virtualisation.oci-containers.containers."pihole-sync-sender" = {
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
    dependsOn = [
      "pihole"
    ];
  };
}
