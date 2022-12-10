{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/tailscale.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/modules/docker.nix
      /etc/nixos/modules/compose/watchtower.nix
      /etc/nixos/modules/compose/pihole-sync-leaf.nix
    ];

  networking.hostName = "seedling01";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "10.2.1.7";
    prefixLength = 24;
  } ];

}
