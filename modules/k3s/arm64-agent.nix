{ config, pkgs, lib, ... }:

{
  imports = [
    ./.
    /etc/nixos/modules/k3s/service-agent.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage ../../pkgs/k3s-arm64.nix {};
    })
  ];
}