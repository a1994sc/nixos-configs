{ config, pkgs, lib, ... }: let
  watchdogConfig = pkgs.writeText "watchdog.conf"
    ''
      watchdog-device = /dev/watchdog
      watchdog-timeout = 15
      max-load-1 = 24
    '';
in {
  nixpkgs.overlays = [
    (self: super: {
      watchdog = super.callPackage /etc/nixos/pkgs/build/watchdog.nix {};
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
      User = "root";
      Group = "root";
      ExecStart = toString [
        "${pkgs.watchdog}/usr/sbin/watchdog"
        "-c=${watchdogConfig}"
      ];
    };
  };
}