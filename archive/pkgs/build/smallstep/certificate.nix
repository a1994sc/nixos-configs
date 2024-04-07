{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "smallstep/cli";
  version = "0.21.0";
  flags = "";

  sourceRoot = "./source";

  src = pkgs.fetchFromGitHub {
    leaveDotGit = true;
    owner = "smallstep";
    repo = "certifcate";
    rev = "v$version";
    sha256 = "sha256-8A63RaNa6/CD0Jlckid3RFvf0gpibFW5YZ36MdYI4ak=";
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
    make GOFLAGS=$flags
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/step-ca $out/bin
    setcap CAP_NET_BIND_SERVICE=+eip $out/bin/step-ca
  '';
}
