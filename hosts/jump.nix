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
    ];

  networking.hostName = "jump-host";

  nix.gc.dates = "Wed 02:00";

  system.autoUpgrade.dates = "Wed 04:00";

  environment.systemPackages = with pkgs; [
    kubectl
    helm
  ];

  users.users.jump = {
    isNormalUser = true;
    extraGroups  = [];
    openssh.authorizedKeys.keys =  [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVflfgY9+i0jlwcHlVvONUIFyDN3ynU0sEF0nv4nFrw phone@adrp.xyz"
    ];
  };

  sops.secrets.jump = {
    owner = "ascii";
    format = "binary";
    path = "/home/ascii/.ssh/jump";
    sopsFile = /etc/nixos/secrets/jump.yaml;
    mode = "0600";
  };

  sops.secrets."jump-jump" = {
    owner = "jump";
    format = "binary";
    path = "/home/jump/.ssh/jump";
    sopsFile = /etc/nixos/secrets/jump.yaml;
    mode = "0600";
  };
}
