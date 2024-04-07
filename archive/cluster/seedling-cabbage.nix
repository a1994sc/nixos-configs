{ config, lib, pkgs, ... }:
let

in {
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/tailscale.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/modules/acme.nix
      /etc/nixos/modules/docker.nix
      /etc/nixos/modules/compose/pihole-sync-leaf.nix
    ];

  networking.hostName = "seedling-cabbage";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  networking.interfaces.eth0.ipv4.addresses = [{
    address = "10.2.1.7";
    prefixLength = 24;
  }];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  virtualisation.oci-containers.containers."pihole".extraOptions = pkgs.lib.mkForce [
    "--cap-add=NET_ADMIN"
    "--hostname=pihole-secondary"
  ];

  networking.nameservers = [
    "1.1.1.2"
    "1.0.0.2"
  ];
}
