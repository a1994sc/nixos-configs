{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "helm";
  version = "v3.9.0";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz";
    sha256 = "1484ffb0c7a608d8069470f48b88d729e88c41a1b6602f145231e8ea7b43b50a";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv linux-amd64/helm $out/bin/
    chmod 0755 $out/bin/helm
  '';
}
