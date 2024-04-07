{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      small-ca = super.callPackage /etc/nixos/pkgs/prebuilt/arm64/smallstep/certificate.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    small-ca
  ];

  security.wrappers.step-ca = {
    owner = "root";
    group = "root";
    capabilities = "CAP_NET_BIND_SERVICE=+eip";
    source = "${pkgs.small-ca}/bin/step-ca";
  };
}
