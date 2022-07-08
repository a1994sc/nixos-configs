{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "smallstep/cli";
  version = "v0.21.0";

  sourceRoot = ".";

  src = pkgs.fetchFromGitHub {
    owner = "smallstep";
    repo = "certifcate";
    rev = "36a075ed2cc8f7c4343a185b29e8dfa2e652acb3";
    sha256 = "sha256-8A63RaNa6/CD0Jlckid3RFvf0gpibFW5YZ36MdYI4ak=";
  };

  buildInputs = [
    pkgs.go
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.pcsclite
    pkgs.gcc
  ];

  buildPhase = ''
    make bootstrap
    make build GOFLAGS=""
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/step-ca $out/bin
    setcap CAP_NET_BIND_SERVICE=+eip $out/bin/step-ca
  '';
}
