{ pkgs ? import <nixpkgs> {} }:
let
  name = "smallstep/cli";
  version = "0.21.0";
  arch = "amd64";
in pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  src = pkgs.fetchurl {
    url = "https://github.com/${name}/releases/download/v${version}/step_linux_${version}_${arch}.tar.gz";
    sha256 = "13fac5aa67193a54613fa0a67ce2d8cf3daf86fdc2e810d882d7a79d71128287";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    tar xf $src
    mkdir -p $out/bin
    cp step_${version}/bin/step $out/bin/step
    chmod +x $out/bin/step
  '';
}
