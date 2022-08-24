{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/amd64/server.nix
      /etc/nixos/modules/qemu.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "trunk10";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

}
