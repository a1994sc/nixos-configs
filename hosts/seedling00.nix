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
      /etc/nixos/modules/compose/pihole-sync-trunk.nix
    ];

  networking.hostName = "seedling00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "10.2.1.6";
    prefixLength = 24;
  } ];

}
