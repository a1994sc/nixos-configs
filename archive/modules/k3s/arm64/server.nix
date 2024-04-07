{ config, pkgs, lib, ... }:
let
  version = "v1.23";
  arch = "arm64";
  role = "server";
in
{
  imports = [
    ../.
    "/etc/nixos/modules/k3s/service-${role}.nix"
  ];

  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage "/etc/nixos/pkgs/prebuilt/${arch}/k3s/${version}.nix" { };
    })
  ];
}
