{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.21.14%2Bk3s1/k3s-arm64";
    sha256 = "f852b7c71ed639f6ca6a54dd846a2fae656b48b7ee4c49ed23f05be087bae4aa";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
