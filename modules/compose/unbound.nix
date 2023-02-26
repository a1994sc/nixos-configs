{ config, pkgs, lib, ... }: let
  ip = let eth = __elemAt config.networking.interfaces.eth0.ipv4.addresses 0; in eth.address;
  unboundConf = pkgs.writeText "unbound.conf"
    ''
    server:
      log-queries: yes
      verbosity: 2
      interface: 0.0.0.0
      port: 5335
      do-ip4: yes
      do-udp: yes
      do-tcp: yes
      do-ip6: no
      prefer-ip6: no
      root-hints: "/var/lib/unbound/root.hints"
      harden-glue: yes
      harden-dnssec-stripped: yes
      use-caps-for-id: no
      edns-buffer-size: 1232
      prefetch: yes
      num-threads: 1
      so-rcvbuf: 1m
      private-address: 192.168.0.0/16
      private-address: 169.254.0.0/16
      private-address: 172.16.0.0/12
      private-address: 10.0.0.0/8
      private-address: fd00::/8
      private-address: fe80::/10
    '';
  roots-sh-script = pkgs.writeShellScriptBin "roots-certs.sh" ''
    ${pkgs.coreutils-full}/bin/mkdir -p /var/lib/unbound/
    ${pkgs.wget}/bin/wget https://www.internic.net/domain/named.root -qO- | ${pkgs.coreutils-full}/bin/tee /var/lib/unbound/root.hints
    ${pkgs.coreutils-full}/bin/chown 0444 /var/lib/unbound/root.hints
    ${pkgs.coreutils-full}/bin/cp ${unboundConf} /mnt/docker/unbound/unbound.conf
  '';
in {
  imports = [ 
    /etc/nixos/modules/compose/docker.nix
  ];

  virtualisation.oci-containers.containers."unbound" = {
    image = "alpinelinux/unbound:latest";
    ports = [
      "5335:5335/tcp"
      "5335:5335/udp"
    ];
    volumes = [
      "/var/lib/unbound/root.hints:/var/lib/unbound/root.hints"
      "/mnt/docker/unbound/:/etc/unbound/"
    ];
    autoStart = true;
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--pull=always"
      "--privileged"
    ];
  };

  systemd.services.unbound-root-sh = {
    serviceConfig.Type = "oneshot";
    script = "${roots-sh-script}/bin/roots-certs.sh";
  };

  systemd.timers.unbound-root-sh = {
    enable = true;
    wantedBy = [ "timers.target" ];
    partOf = [ "unbound-root-sh.service" ];
    timerConfig = {
      OnBootSec = "1min";
      OnCalendar = "*-*-01 02:00:00";
      Unit = "unbound-root-sh.service";
    };
  };
}
