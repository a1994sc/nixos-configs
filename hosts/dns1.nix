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
      allowedUDPPorts              = [
        53                         # DNS
      ];
      allowedTCPPorts              = [
        22                         # SSH
        53                         # DNS
        443                        # Step-CA
        3306                       # MYSQL
        8443                       # PowerDNS API
      ];
    };
  };
}
