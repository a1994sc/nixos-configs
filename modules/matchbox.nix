{ config, pkgs, lib, ... }: let
  path                             = "/etc/nixos";
  user                             = "matchbox";
  data-path                        = "/var/lib/matchbox";
in {

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

  services.atftpd                  = {
    enable                         = true;
    root                           = "/srv/tftp";
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
