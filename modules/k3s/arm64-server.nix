{ config, pkgs, lib, ... }:

{
  imports = [
    ./.
    ./service-server.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage ../../pkgs/k3s-arm64.nix {};
    })
  ];
}
