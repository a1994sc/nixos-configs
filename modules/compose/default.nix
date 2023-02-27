{ config, pkgs, lib, ... }: let
  docker-clear-sh-script = pkgs.writeShellScriptBin "clean-up.sh" ''
    ${pkgs.docker}/bin/docker system prune --force --all
  '';
in {
  virtualisation.oci-containers.backend = "docker";

  systemd.services.docker-clear-sh = {
    serviceConfig.Type = "oneshot";
    script = "${docker-clear-sh-script}/bin/clean-up.sh";
  };

  systemd.timers.docker-clear-sh = {
    enable = true;
    wantedBy = [ "timers.target" ];
    partOf = [ "docker-clear-sh.service" ];
    timerConfig = {
      OnBootSec = "1min";
      Unit = "docker-clear-sh.service";
    };
  };
}