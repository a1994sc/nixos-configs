# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../modules/k3s/arm64-agent.nix
      ../modules/raspberry-pi.nix
      ../modules/main-config.nix
      ../modules/sops.nix
    ];

  networking.hostName = "leaf00";

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

  sops.secrets.k3s-server-token.sopsFile = ./user/leaf00.yaml;
  sops.secrets.my-password.neededForUsers = true;

  users.users.test = {
    isNormalUser = true;
    extraGroups  = [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN"
    ];
    passwordFile = config.sops.secrets.password.path;
  };


#  users.users.ascii.passwordFile = config.sops.secrets.my-password.path;
}
