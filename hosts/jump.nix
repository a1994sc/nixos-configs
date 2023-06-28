# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let

in {
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/modules/step-ca.nix
      /etc/nixos/modules/wireguard.nix
    ];

  networking.hostName = "jump";

  nix.gc.dates = "Wed 02:00";

  system.autoUpgrade.dates = "Wed 04:00";

  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    terraform
    ansible
  ];

  programs.ssh.startAgent = true;

  sops.secrets.ascii = {
    owner = "ascii";
    path = "/home/ascii/.ssh/jump";
    sopsFile = /etc/nixos/secrets/ascii.yaml;
    mode = "0600";
  };

  sops.secrets.vault = {
    owner = "ascii";
    path = "/home/ascii/.ssh/vault";
    sopsFile = /etc/nixos/secrets/vault.yaml;
    mode = "0600";
  };

  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "10.2.1.9";
    prefixLength = 24;
  } ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}