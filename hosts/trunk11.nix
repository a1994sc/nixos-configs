# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/k3s/amd64-server.nix
      /etc/nixos/modules/qemu.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "trunk11";

  nix.gc.dates = "Tue 02:00";

  system.autoUpgrade.dates = "Tue 04:00";

}
