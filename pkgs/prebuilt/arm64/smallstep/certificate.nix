{ pkgs ? import <nixpkgs> {} }:
let
  name = "smallstep/certificates";
  version = "0.21.0";
  arch = "amd64";
in pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  src = pkgs.fetchurl {
    url = "https://github.com/${name}/releases/download/v${version}/step-ca_linux_${version}_${arch}.tar.gz";
    sha256 = "56e73c0a044e5a2f10ac82b00b39044d06057f1a9a04d62372a85c00ed099eb8";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/*
    chmod +x $out/bin/*
  '';
}
