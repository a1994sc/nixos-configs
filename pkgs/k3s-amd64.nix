{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.23.7%2Bk3s1/k3s";
    sha256 = "6b015a1d6004f097035f295dfbd9ef20c4af573be5f3cd46c2e7c578804906e7";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
