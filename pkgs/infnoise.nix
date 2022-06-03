{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "infnoise";
  version = "0.3.1";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/leetronics/infnoise/releases/download/0.3.1/infnoise-0.3.1.tar.gz";
    sha256 = "07ece276f5415a8a833b5abbd9a22dec416a75e6dba85d5542cbf376c076e44d";
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
#    cp $src $out/bin/infnoise
#    chmod +x $out/bin/infnoise
    install -d $out/bin
    install -m 0755 infnoise $out/bin/
  '';
}
