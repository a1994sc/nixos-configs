{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.23.10%2Bk3s1/k3s-arm64";
    sha256 = "61c47728fa906bb019f307c1c0ef6b10fce9d0eef5688902716330f9ccafc931";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
