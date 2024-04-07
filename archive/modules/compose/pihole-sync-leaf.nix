{ config, pkgs, lib, ... }:
let

in {
  imports = [
    ./.
    /etc/nixos/modules/compose/pihole.nix
  ];

  sops.secrets."id_ed25519.pub" = {
    sopsFile = /etc/nixos/modules/compose/secrets/seedling/pihole.yaml;
    mode = "0644";
    key = "sync-pub";
  };

  virtualisation.oci-containers.containers."pihole-sync-receiver" = {
    image = "shirom/pihole-sync:latest";
    ports = [
      "22222:22"
    ];
    environment = {
      NODE = "receiver";
    };
    volumes = [
      "/mnt/docker/piholesync/root:/root"
      "/mnt/docker/piholesync/etc-ssh:/etc/ssh"
      "/mnt/docker/pihole/etc-pihole:/mnt/etc-pihole"
      "/run/secrets/id_ed25519.pub:/root/.ssh/authorized_keys:ro"
    ];
    autoStart = true;
    dependsOn = [
      "pihole"
    ];
  };
}
