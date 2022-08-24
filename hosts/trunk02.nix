{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/arm64/server.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "trunk02";

  nix.gc.dates = "Sun 02:00";

  system.autoUpgrade.dates = "Sun 04:00";

}
