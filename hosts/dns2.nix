{ config, lib, pkgs, ... }: let
  path = "/etc/nixos";
in {
  imports = [
    "${path}/modules/main-config.nix"
    "${path}/modules/sops.nix"
    "${path}/modules/bare.nix"
    "${path}/modules/blocky.nix"
    "${path}/modules/powerdns-replica.nix"
  ];

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  networking = {
    hostName = "dns2";
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable = pkgs.lib.mkForce true;
    firewall.interfaces.eth0 = {
      allowedUDPPorts = [
        53
      ];
      allowedTCPPorts = [
        22
        53
        3306
      ];
    };
  };
}