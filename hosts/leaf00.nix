{ config, lib, pkgs, ... }:

{
  imports =
    [
#      /etc/nixos/modules/k3s/arm64/agent.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/modules/watchdog.nix
    ];

  networking.hostName = "leaf00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

}
