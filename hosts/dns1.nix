{ config, lib, pkgs, ... }: let
  path                             = "/etc/nixos";
in {
  imports                          = [
    "${path}/modules/main-config.nix"
    "${path}/modules/sops.nix"
    "${path}/modules/bare.nix"
    "${path}/modules/blocky.nix"
    "${path}/modules/step-ca.nix"
    "${path}/modules/powerdns-primary.nix"
  ];

  nix.gc.dates                     = "Mon 02:00";
  system.autoUpgrade.dates         = "Mon 04:00";
  boot.kernelPackages              = pkgs.linuxKernel.packages.linux_5_15;
  networking                       = {
    hostName                       = "dns1";
    nameservers                    = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable                = pkgs.lib.mkForce true;
    firewall.interfaces.eth0       = {
      allowedUDPPorts              = [ 53 ];
      allowedTCPPorts              = [
        22
        53
        80
        443
        3306
        8443
      ];
    };
  };
}
