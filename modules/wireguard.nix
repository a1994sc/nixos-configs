{ config, pkgs, lib, ... }:

{
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  sops.secrets = {
    serverKey = {
      sopsFile = /etc/nixos/secrets/wireguard.yaml;
      mode = "0600";
    };
    clientOnePreshare = {
      sopsFile = /etc/nixos/secrets/wireguard.yaml;
      mode = "0600";
    };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];

      listenPort = 51820;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      privateKeyFile = "${config.sops.secrets.serverKey.path}";

      peers = [
        {
          publicKey = "ZyEZynux1W9u2K/QmX7Z3bVjJNgDYl9N73Qt/RyAVx8=";
          presharedKeyFile = "${config.sops.secrets.clientOnePreshare.path}";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
