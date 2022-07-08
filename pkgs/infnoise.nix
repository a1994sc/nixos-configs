{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "infnoise";
  version = "0.3.2";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/leetronics/infnoise/archive/refs/tags/0.3.2.tar.gz";
    sha256 = "05c35ae52dee000aac3e070b46c9a7a3b2c0fad3ff3e49f430adf613dd3bbaa7";
  };

#  src = pkgs.fetchFromGitHub {
#    owner  = "leetronics";
#    repo   = "infnoise";
#    rev    = "5ce538e95a688d116241fb4fcc1eab5477cfa23a";
#    sha256 = "0jiyr2am84mlamlrmpsfc0dk8yjxbxwd77mnbyiq5acbnc5ww87v";
#  };

  buildInputs = [
    pkgs.libftdi
    pkgs.libftdi1
    pkgs.libusb1
  ];

  buildPhase = ''
    make -f Makefile.linux
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -d $out/bin
    install -m 0755 infnoise $out/bin/
  '';
}
