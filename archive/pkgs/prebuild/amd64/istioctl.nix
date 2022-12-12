{ pkgs ? import <nixpkgs> {} }: let
  name = "istioctl";
  version = "1.15.0";
  arch = "amd64";
  sha = "dfeef7a61d1be13463150c28963852f61589517b0c534bfbcc006d99e17b9f71";
in  pkgs.stdenv.mkDerivation {
  name = "${name}";
  version = "${version}";

  sourceRoot = ".";

  src = pkgs.fetchurl {
    url = "https://github.com/istio/istio/releases/download/${version}/istioctl-${version}-linux-${arch}.tar.gz";
    sha256 = "${sha}";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv istioctl $out/bin/
    chmod 0755 $out/bin/istioctl
  '';
}
