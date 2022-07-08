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
    sha256 = "6e2f49b2b805021f76e514e5eb4eeea143b7d973ad0a46a4a501780dd8281924";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    tar xf $src
    mkdir -p $out/bin
    cp step_${version}/bin/step $out/bin/step
    chmod +x $out/bin/step
  '';
}
