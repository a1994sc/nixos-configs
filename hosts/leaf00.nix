# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
#      ../modules/k3s/arm64-agent.nix
      ../modules/raspberry-pi.nix
      ../modules/main-config.nix
      ../modules/sops.nix
    ];

  networking.hostName = "leaf00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";
}
