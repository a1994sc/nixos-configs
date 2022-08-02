{ config, pkgs, lib, ... }:

{
  imports = [
    ../.
    /etc/nixos/modules/k3s/service-agent.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage /etc/nixos/pkgs/prebuilt/amd64/k3s.nix {};
    })
  ];
}