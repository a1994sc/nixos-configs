# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/k3s-agent.nix
      ./modules/raspberry-pi.nix
      ./modules/main-config.nix
    ];

  networking.hostName = "leaf00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";
}
