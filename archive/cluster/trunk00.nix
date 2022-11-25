{ config, lib, pkgs, ... }: let 

in {
  imports =
    [ 
      /etc/nixos/modules/k3s/arm64/server.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/hosts/home/manager.nix
    ];

  networking.hostName = "trunk00";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  systemd.services.k3s-server.serviceConfig.ExecStart = pkgs.lib.mkForce "${config.systemd.services.k3s-args.description} --cluster-init";
}
