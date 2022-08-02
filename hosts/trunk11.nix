{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/amd64/server.nix
      /etc/nixos/modules/qemu.nix
      /etc/nixos/modules/main-config.nix
    ];

  networking.hostName = "trunk11";

  nix.gc.dates = "Tue 02:00";

  system.autoUpgrade.dates = "Tue 04:00";

}
