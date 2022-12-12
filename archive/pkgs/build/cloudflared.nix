{ lib, buildGoModule, fetchFromGitHub, stdenv }:

# nix-prefetch fetchFromGitHub --owner cloudflare --repo cloudflared --rev 2022.10.3
buildGoModule rec {
  pname = "cloudflared";
  version = "2022.10.3";

  src = fetchFromGitHub {
    owner  = "cloudflare";
    repo   = "cloudflared";
    rev    = version;
    hash   = "sha256-o1+j8OaDg6cjAOKXXsXo535VjcEDkG+DaMRW7qa/sRU=";
  };

  vendorSha256 = null;

  ldflags = [ "-X main.Version=${version}" ];

  preCheck = ''
    # Workaround for: sshgen_test.go:74: mkdir /homeless-shelter/.cloudflared: no such file or directory
    export HOME="$(mktemp -d)";

    # Workaround for: protocol_test.go:11:
    #   lookup protocol-v2.argotunnel.com on [::1]:53: read udp [::1]:51876->[::1]:53: read: connection refused

    substituteInPlace "edgediscovery/protocol_test.go" \
      --replace "TestProtocolPercentage" "SkipProtocolPercentage"
  '';

  # nativeBuildInputs = [ installShellFiles ];
  # postInstall = ''
  #   mkdir -p $out/share/completions/
  #   installShellCompletion $out/share/completions/${pname}.{bash,fish,zsh}
  # '';

  doCheck = !stdenv.isDarwin;
}
