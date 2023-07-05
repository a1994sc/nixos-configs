{ config, lib, pkgs, ... }:
let
  path = "/etc/nixos";
in {
  imports = [
    "${path}/modules/main-config.nix"
    "${path}/modules/bare.nix"
    "${path}/hosts/addons/jump.nix"
  ];
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

  networking = {
    hostName = "jump";
    defaultGateway = {
      address = "10.2.1.1";
      interface = "eth0";
    };
    interfaces.eth0 = {
      useDHCP = pkgs.lib.mkForce false;
      ipv4.addresses = [ {
        address = "10.2.1.9";
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