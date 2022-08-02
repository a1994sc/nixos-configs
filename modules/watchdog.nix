{ config, pkgs, lib, ... }: let
  kubeletConfig = pkgs.writeText "k3s_kubelet.yaml"
    ''
      watchdog-device = /dev/watchdog
      watchdog-timeout = 15
      max-load-1 = 24
    '';
in {
  nixpkgs.overlays = [
    (self: super: {
      watchdog = super.callPackage /etc/nixos/pkgs/built/watchdog.nix {};
    })
  ];

  environment.systemPackages = with pkgs; [
    watchdog
  ];

  systemd.services.watchdog = {
    # Unit
    description = "Kernel Watchdog";
    wantedBy = [ "multi-user.target" ];
    # Service
    serviceConfig = {
      Type = "exec";
      RestartSec = "5s";
      ExecStart = toString [
        "${pkgs.watchdog}/usr/sbin/watchdog"
        "-c=${kubeletConfig}"
      ];
    };
  };
}