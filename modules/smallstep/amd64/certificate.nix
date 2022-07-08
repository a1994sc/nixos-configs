{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      small-ca = super.callPackage /etc/nixos/pkgs/prebuilt/amd64/smallstep/certificate.nix {};
    })
  ];

  environment.systemPackages = with pkgs; [
    small-ca
  ];

  security.wrappers.small-ca = {
    owner = "root";
    group = "root";
    capabilities = "CAP_NET_BIND_SERVICE=+eip";
    permissions = "0755";
  };
}