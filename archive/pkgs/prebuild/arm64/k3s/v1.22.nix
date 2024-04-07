{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.22.13%2Bk3s1/k3s-arm64";
    sha256 = "dcc087fbf12b6fdb3eed31dca5ac44c2eb10cbbd25380ddcb761f9f7e8fdb54d";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
