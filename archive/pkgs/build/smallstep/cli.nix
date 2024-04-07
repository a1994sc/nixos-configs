{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "smallstep/cli";
  version = "0.21.0";
  flags = "";

  sourceRoot = "./source";

  src = pkgs.fetchFromGitHub {
    leaveDotGit = true;
    owner = "smallstep";
    repo = "cli";
    rev = "v$version";
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
    make bootstra
    make build GOFLAGS=$flags
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/step $out/bin
  '';
}
