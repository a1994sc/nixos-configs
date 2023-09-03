{ config, pkgs, lib, ... }: let
  path                             = "/etc/nixos";
  user                             = "matchbox";
  data-path                        = "/var/lib/matchbox";
  tftp-path                        = "/var/lib/atftp";

  docker-clear-sh-script           = pkgs.writeShellScriptBin "clean-up.sh" ''
    ${pkgs.docker}/bin/docker system prune --force --all
  '';
in {

  imports                          = [
    "${path}/modules/scripts/matchbox.nix"
  ];

  nixpkgs.overlays                 = [
    (self: super: {
      matchbox = super.callPackage "${path}/pkgs/matchbox.nix" {};
    })
  ];

  environment.systemPackages       = with pkgs; [
    matchbox
  ];

  users = {
    groups.matchbox                = { };
    users.matchbox                 = {
      isSystemUser                 = true;
      group                        = "${user}";
      home                         = "${data-path}";
      createHome                   = true;
    };
  };

  sops.validateSopsFiles           = false;
  sops.secrets                     = {
    ca-crt                         = {
      owner                        = "${config.users.users.matchbox.name}";
      group                        = "${config.users.groups.matchbox.name}";
      sopsFile                     = "${path}/secrets/dns/dns2.yml";
      mode                         = "0600";
    };
    tls-crt                        = {
      owner                        = "${config.users.users.matchbox.name}";
      group                        = "${config.users.groups.matchbox.name}";
      sopsFile                     = "${path}/secrets/dns/dns2.yml";
      mode                         = "0600";
    };
    tls-key                        = {
      owner                        = "${config.users.users.matchbox.name}";
      group                        = "${config.users.groups.matchbox.name}";
      sopsFile                     = "${path}/secrets/dns/dns2.yml";
      mode                         = "0600";
    };
    env                            = {
      owner                        = "${config.users.users.matchbox.name}";
      group                        = "${config.users.groups.matchbox.name}";
      sopsFile                     = "${path}/secrets/dns/dns2.yml";
      mode                         = "0600";
    };
  };

  virtualisation.oci-containers    = {
    backend                        = "docker";
    containers."dnsmasq"           = {
      image                        = "quay.io/poseidon/dnsmasq";
      autoStart                    = true;
      extraOptions                 = [
        "--net=host"
        "--cap-add=NET_ADMIN"
      ];
      cmd                          = [
        "-d"
        "-q"
        "--dhcp-range=10.3.21.200,10.3.21.250,255.255.254.0,30m"
        "--enable-tftp"
        "--tftp-root=/var/lib/tftpboot"
        "--dhcp-match=set:bios,option:client-arch,0"
        "--dhcp-boot=tag:bios,undionly.kpxe"
        "--dhcp-match=set:efi32,option:client-arch,6"
        "--dhcp-boot=tag:efi32,ipxe.efi"
        "--dhcp-match=set:efibc,option:client-arch,7"
        "--dhcp-boot=tag:efibc,ipxe.efi"
        "--dhcp-match=set:efi64,option:client-arch,9"
        "--dhcp-boot=tag:efi64,ipxe.efi"
        "--dhcp-userclass=set:ipxe,iPXE"
        "--dhcp-boot=tag:ipxe,http://dns2.adrp.xyz:8080/boot.ipxe"
        "--address=/dns2.adrp.xyz/10.3.10.6"
        "--log-queries"
        "--log-dhcp"
        "--port=0"
        "--dhcp-option=6,10.3.10.5"
        "--dhcp-option=6,10.3.10.6"
        "--dhcp-option=3.10.3.20.1"
        "--log-queries"
        "--log-dhcp"
        "--listen-address=10.3.20.6"
        "--interface=vlan20"
      ];
    };
  };

  systemd.services.docker-clear-sh = {
    serviceConfig.Type             = "oneshot";
    script                         = "${docker-clear-sh-script}/bin/clean-up.sh";
  };

  systemd.timers.docker-clear-sh   = {
    enable                         = true;
    wantedBy                       = [ "timers.target" ];
    partOf                         = [ "docker-clear-sh.service" ];
    timerConfig                    = {
      OnBootSec                    = "1min";
      Unit                         = "docker-clear-sh.service";
    };
  };

  systemd.services.matchbox        = {
    description                    = "Matchbox Server";
    documentation                  = [ "https://github.com/poseidon/matchbox" ];
    wantedBy                       = [ "multi-user.target" ];
    environment                    = {
      MATCHBOX_ADDRESS             = "0.0.0.0:8080";
      MATCHBOX_RPC_ADDRESS         = "0.0.0.0:8443";
      MATCHBOX_DATA_PATH           = "${data-path}";
      MATCHBOX_ASSETS_PATH         = "${data-path}/assets";
      MATCHBOX_CA_FILE             = config.sops.secrets.ca-crt.path;
      MATCHBOX_CERT_FILE           = config.sops.secrets.tls-crt.path;
      MATCHBOX_KEY_FILE            = config.sops.secrets.tls-key.path;
      MATCHBOX_PASSPHRASE          = (builtins.readFile config.sops.secrets.env.path);
    };
    serviceConfig                  = {
      User                         = "${user}";
      Group                        = "${user}";
      ExecStart                    = "${pkgs.matchbox}/bin/matchbox";
      ProtectHome                  = "yes";
      ProtectSystem                = "full";
    };
  };
}
