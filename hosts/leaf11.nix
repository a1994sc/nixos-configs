{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/amd64/agent.nix
      /etc/nixos/modules/qemu.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "leaf11";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

}
