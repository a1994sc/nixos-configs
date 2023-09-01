{ pkgs ? import <nixpkgs> {} }:let
  name = "matchbox";
  version = "v0.10.0";
  arch = "amd64";
  sha = "f43e8de2c5ceab824d813dfcbe420c7a78f8af05239d6b956299afa15ea6897c";
in pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/poseidon/${name}/releases/download/${version}/${name}-${version}-linux-${arch}.tar.gz";
    sha256 = "${sha}";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv ${name}-${version}-linux-${arch}/${name} $out/bin/
    chmod 0755 $out/bin/${name}
  '';
}
