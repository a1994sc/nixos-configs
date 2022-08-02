{ config, pkgs, lib, ... }: let
  watchdogConfig = pkgs.writeText "watchdog.conf"
    ''
      watchdog-device = /dev/watchdog
      watchdog-timeout = 15
      max-load-1 = 24
    '';
  watchdogEnv = pkgs.writeText "watchdog.env"
    ''
      # Start watchdog at boot time? 0 or 1
      run_watchdog=1
      # Start wd_keepalive after stopping watchdog? 0 or 1
      run_wd_keepalive=1
      # Load module before starting watchdog
      watchdog_module="none"
      # Specify additional watchdog options here (see manpage).
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

  systemd.services = {
    watchdog = {
      # Unit
      description = "watchdog daemon";
      wantedBy = [ "multi-user.target" ];
      # Service
      serviceConfig = {
        Type = "forking";
        EnvironmentFile= "${watchdogEnv}";
        ExecStartPre="/bin/sh -c '[ -z \"\$\{watchdog_module\}\" ] || [ \"\$\{watchdog_module\}\" = \"none\" ] || /sbin/modprobe $watchdog_module'";
        ExecStart="/bin/sh -c '[ $run_watchdog != 1 ] || exec ${pkgs.watchdog}/usr/sbin/watchdog $watchdog_options -c ${watchdogConfig}'";
        ExecStopPost="/bin/sh -c '[ $run_wd_keepalive != 1 ] || false'";
      };
    };
    wd_keepalive = {
      # Unit
      description = "watchdog keepalive daemon";
      # Service
      serviceConfig = {
        Type = "forking";
        EnvironmentFile= "${watchdogEnv}";
        ExecStartPre="/bin/sh -c '[ -z \"\$\{watchdog_module\}\" ] || [ \"\$\{watchdog_module\}\" = \"none\" ] || /sbin/modprobe $watchdog_module'";
        ExecStart="/usr/sbin/wd_keepalive $watchdog_options";
        ExecStartPost="/bin/sh -c 'ln -s /var/run/wd_keepalive.pid /run/sendsigs.omit.d/wd_keepalive.pid'";
        ExecStopPost="/bin/sh -c 'rm -f /run/sendsigs.omit.d/wd_keepalive.pid'";
      };
    };
  };
}

/*
[Unit]
Description=watchdog daemon
Conflicts=wd_keepalive.service
After=multi-user.target
OnFailure=wd_keepalive.service

[Service]
Type=forking
EnvironmentFile=/etc/default/watchdog
ExecStartPre=/bin/sh -c '[ -z "${watchdog_module}" ] || [ "${watchdog_module}" = "none" ] || /sbin/modprobe $watchdog_module'
ExecStart=/bin/sh -c '[ $run_watchdog != 1 ] || exec /usr/sbin/watchdog $watchdog_options'
ExecStopPost=/bin/sh -c '[ $run_wd_keepalive != 1 ] || false'

[Install]
WantedBy=default.target
=============================================================================================================================
[Unit]
Description=watchdog keepalive daemon
Before=watchdog.service shutdown.target
Conflicts=watchdog.service shutdown.target

[Service]
Type=forking
EnvironmentFile=/etc/default/watchdog
ExecStartPre=/bin/sh -c '[ -z "${watchdog_module}" ] || [ "${watchdog_module}" = "none" ] || /sbin/modprobe $watchdog_module'
ExecStartPre=-/bin/systemctl reset-failed watchdog.service
ExecStart=/usr/sbin/wd_keepalive $watchdog_options
ExecStartPost=/bin/sh -c 'ln -s /var/run/wd_keepalive.pid /run/sendsigs.omit.d/wd_keepalive.pid'
ExecStopPost=/bin/sh -c 'rm -f /run/sendsigs.omit.d/wd_keepalive.pid'
*/