{ pkgs ? import <nixpkgs> {} }: let
  name = "gitops";
  version = "0.10.0";
  arch = "x86_64";
  sha = "f797d0ed87f3afee4ff1b31350d9c5920e8da11332659f99c3ef7e76a4333fb8";
in  pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/weaveworks/weave-gitops/releases/download/v${version}/gitops-linux-${arch}.tar.gz";
    sha256 = "${sha}";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv gitops $out/bin/
    chmod 0755 $out/bin/gitops
  '';
}
