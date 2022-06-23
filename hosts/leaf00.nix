# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/modules/k3s/arm64-agent.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "leaf00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

  sops.secrets.password.sopsFile = ./user/leaf00.yaml;
  sops.secrets.password.neededForUsers = true;
#  users.users.ascii.passwordFile = config.sops.secrets.password.path;
}
