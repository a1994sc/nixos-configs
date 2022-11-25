{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/arm64/agent.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "leaf01";

  nix.gc.dates = "Tue 02:00";

  system.autoUpgrade.dates = "Tue 04:00";

}
