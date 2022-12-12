{ pkgs ? import <nixpkgs> {} }: let
  name = "istioctl";
  version = "1.15.0";
  arch = "arm64";
  sha = "f0a6e02751aa8947012c484957e57aa8a0202c5e7e4003dd762a3d225c78a10a";
in  pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/istio/istio/releases/download/${version}/istioctl-${version}-linux-${arch}.tar.gz";
    sha256 = "${sha}";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv istioctl $out/bin/
    chmod 0755 $out/bin/istioctl
  '';
}
