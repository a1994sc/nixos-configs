{ config, lib, pkgs, ... }: let
  path = "/etc/nixos";
in {
  imports =[
    "${path}/modules/sops.nix"
    "${path}/modules/step-ca.nix"
    "${path}/modules/wireguard.nix"
  ];

  sops.secrets.ascii = {
    owner = "ascii";
    path = "/home/ascii/.ssh/jump";
    sopsFile = /etc/nixos/secrets/ascii.yaml;
    mode = "0600";
  };

  sops.secrets.vault = {
    owner = "ascii";
    path = "/home/ascii/.ssh/vault";
    sopsFile = /etc/nixos/secrets/vault.yaml;
    mode = "0600";
  };
}