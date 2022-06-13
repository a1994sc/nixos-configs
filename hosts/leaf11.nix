# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ../modules/k3s/amd64-agent.nix
      ../modules/qemu.nix
      ../modules/main-config.nix
      ../modules/sops.nix
    ];

  networking.hostName = "leaf11";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";
}
