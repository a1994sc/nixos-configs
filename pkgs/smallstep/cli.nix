{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "smallstep/cli";
  version = "v0.21.0";

  sourceRoot = ".";

  src =  fetchFromGitHub {
    owner = "smallstep";
    repo = "cli";
    rev = "ffe7c00a1040722c7606bced81a5a4ecc8bd8fe5";
    sha256 = "sha256-LfkLvTK71iNUA8EguJuXYOupO4nGX9T9/La7hEwl9kk=";
  };

  buildInputs = [
    pkgs.go
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.pcsclite
    pkgs.gcc
    pkgs.golangci-lint
  ];

  buildPhase = ''
    make bootstrap
    make build GOFLAGS=""
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/step $out/bin
  '';
}
