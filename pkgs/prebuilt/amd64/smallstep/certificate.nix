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
    sha256 = "aaa4042c5f900c948b32e946656ef36cde99e2469d508c24a3a01b8da5c73b3f";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/step-ca
  '';
}