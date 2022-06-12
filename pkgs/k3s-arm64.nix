{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.23.7%2Bk3s1/k3s-arm64";
    sha256 = "391dc3d2d8ab5c11f7de432e4df9bc6d1493a2e306bbaf171602862968fd99a3";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
