{ config, lib, pkgs, ... }: let
  path = "/etc/nixos";
in {
  imports = [
    "${path}/modules/main-config.nix"
    "${path}/modules/bare.nix"
    "${path}/modules/blocky.nix"
  ];

  nix.gc.dates = "Mon 02:00";

  system.autoUpgrade.dates = "Mon 04:00";

  networking = {
    hostName = "dns1";
    defaultGateway = {
      address = "10.2.1.1";
      interface = "eth0";
    };
    interfaces.eth0 = {
      useDHCP = pkgs.lib.mkForce false;
      ipv4.addresses = [ {
        address = "10.2.1.6";
        prefixLength = 24;
      } ]; 
    };
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
