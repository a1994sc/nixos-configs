{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      small-cli = super.callPackage /etc/nixos/pkgs/prebuilt/arm64/smallstep/cli.nix {};
    })
  ];

  environment.systemPackages = with pkgs; [
    small-cli
  ];

}