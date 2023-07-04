{ config, lib, pkgs, ... }: let
  path = "/etc/nixos";
in {
  imports = [
    # "${path}/modules/tailscale.nix"
    "${path}/modules/sops.nix"
    # "${path}/modules/acme.nix"
  ];

  virtualisation.oci-containers.containers."pihole".extraOptions = pkgs.lib.mkForce [
    "--cap-add=NET_ADMIN"
    "--hostname=pihole-secondary"
  ];
}
