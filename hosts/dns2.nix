{ config, lib, pkgs, ... }: let
  path = "/etc/nixos";
in {
  imports = [
    "${path}/modules/main-config.nix"
    "${path}/modules/bare.nix"
    "${path}/modules/blocky.nix"
  ];

  networking.hostName = "dns2";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  networking.interfaces.eth0 = {
    useDHCP = pkgs.lib.mkForce false;
    ipv4.addresses = [ {
      address = "10.2.1.7";
      prefixLength = 24;
    } ]; 
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.nameservers = [
    "1.1.1.2"
    "1.0.0.2"
  ];
}
