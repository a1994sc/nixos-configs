{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "istioctl";
  version = "1.15.0";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/istio/istio/releases/download/${version}/istioctl-${version}-linux-amd64.tar.gz";
    sha256 = "dfeef7a61d1be13463150c28963852f61589517b0c534bfbcc006d99e17b9f71";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv istioctl $out/bin/
    chmod 0755 $out/bin/istioctl
  '';
}
