# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/k3s/.
    ];

  networking.hostName = "jump-host";

  nix.gc.dates = "Wed 02:00";

  system.autoUpgrade.dates = "Wed 04:00";

  environment.systemPackages = with pkgs; [
    kubectl
    helm
  ];

  sops.secrets.jump = {
    owner = "ascii";
    path = "/home/ascii/.ssh/jump";
    sopsFile = /etc/nixos/secrets/;
    mode = 0600;
  };
}
