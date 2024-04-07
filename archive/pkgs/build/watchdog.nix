{ pkgs ? import <nixpkgs> { } }:
let
  name = "watchdog";
  version = "5.16";
in
pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  sourceRoot = "";

  # nix-prefetch-url --unpack https://example/com/blah.tar.gz
  src = pkgs.fetchurl {
    url = "https://cytranet.dl.sourceforge.net/project/${name}/${name}/${version}/${name}-${version}.tar.gz";
    sha256 = "b8e7c070e1b72aee2663bdc13b5cc39f76c9232669cfbb1ac0adc7275a3b019d";
  };


  buildInputs = [
    pkgs.gcc
  ];

  buildPhase = ''
    ./configure
    make
  '';

  installPhase = ''
    mkdir -p $out/usr/sbin
    mkdir -p $out/usr/share
    make DESTDIR=$out install
  '';
}
