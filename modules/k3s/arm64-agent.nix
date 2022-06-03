{ config, pkgs, lib, ... }:

{
  imports = [
    ./.
    ./service-agent.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage ../../pkgs/k3s-arm64.nix {};
    })
  ];
}