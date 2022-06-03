# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ../modules/k3s-server.nix
      ../modules/raspberry-pi.nix
      ../modules/main-config.nix
    ];

  networking.hostName = "trunk01";

  nix.gc.dates = "Sat 02:00";

  system.autoUpgrade.dates = "Sat 04:00";
}
