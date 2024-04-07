{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/sops.nix
    ];

  networking.hostName = "acorn";

  nix.gc.dates = "Thu 02:00";

  system.autoUpgrade = {
    dates = "Thu 04:00";
    allowReboot = pkgs.lib.mkForce false;
  };

  networking.interfaces.eth0.ipv4.addresses = [{
    address = "10.2.1.8";
    prefixLength = 24;
  }];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

}
