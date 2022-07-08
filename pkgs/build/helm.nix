{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "helm";
  version = "v3.9.0";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/helm/helm/archive/refs/tags/v3.9.0.tar.gz";
    sha256 = "4674aac1527db460bcbb6e0d0fa9677a4ce8b1ae7cc535a7a57c9c1778683cbe";
  };

  buildInputs = [
    pkgs.go
    pkgs.gnumake
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -d $out/bin
    install -m 0755 helm $out/bin/
  '';
}
