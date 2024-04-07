{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/modules/k3s/amd64/agent.nix
      /etc/nixos/modules/qemu.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "leaf10";

  nix.gc.dates = "Thu 02:00";

  system.autoUpgrade.dates = "Thu 04:00";

}
