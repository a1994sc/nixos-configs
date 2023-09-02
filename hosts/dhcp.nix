{ config, lib, pkgs, ... }: let
  path                             = "/etc/nixos";
in {
  imports                          = [
    "${path}/modules/main-config.nix"
    "${path}/modules/sops.nix"
    "${path}/modules/bare.nix"
    "${path}/modules/matchbox.nix"
  ];

  nix.gc.dates                     = "Wed 02:00";
  system.autoUpgrade.dates         = "Wed 04:00";
  boot.kernelPackages              = pkgs.linuxKernel.packages.linux_5_15;
  networking                       = {
    hostName                       = "dhcp";
    nameservers                    = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable                = pkgs.lib.mkForce true;
    firewall.interfaces.eth0       = {
      allowedUDPPorts              = [
        53                         # DNS
        67                         # DHCP
        69                         # TFTP
      ];
      allowedTCPPorts              = [
        22                         # SSH
        53                         # DNS
        8080                       # Matchbox
        8443                       # Matchbox
      ];
    };
  };
}
