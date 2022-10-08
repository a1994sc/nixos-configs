{ lib
, pkgs
, stdenv
, buildGoModule
, fetchFromGitHub
}: let
  plugins = pkgs.writeText "coredns_plugin.cfg"
  ''
    metadata:metadata
    geoip:geoip
    cancel:cancel
    tls:tls
    reload:reload
    nsid:nsid
    bufsize:bufsize
    root:root
    bind:bind
    debug:debug
    trace:trace
    ready:ready
    health:health
    pprof:pprof
    prometheus:metrics
    errors:errors
    log:log
    dnstap:dnstap
    local:local
    dns64:dns64
    acl:acl
    any:any
    chaos:chaos
    loadbalance:loadbalance
    tsig:tsig
    cache:cache
    rewrite:rewrite
    header:header
    dnssec:dnssec
    autopath:autopath
    minimal:minimal
    template:template
    transfer:transfer
    hosts:hosts
    clouddns:clouddns
    file:file
    auto:auto
    secondary:secondary
    loop:loop
    forward:forward
    erratic:erratic
    whoami:whoami
    on:github.com/coredns/caddy/onevent
    sign:sign
    view:view
    unbound:unbound
  '';
in buildGoModule rec {
  pname = "coredns";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "coredns";
    repo = "coredns";
    rev = "v${version}";
    sha256 = "sha256-9lRZjY85SD1HXAWVCp8fpzV0d1Y+LbodT3Sp21CNp+k=";
  };

  nativeBuildInputs = [ pkgs.unbound ];

  vendorSha256 = lib.fakeSha256;

  preBuild = ''
    ls $out
    touch $out/plugin.cfg
    cat ${plugins} > $out/plugin.cfg
  '';

  postPatch = ''
    substituteInPlace test/file_cname_proxy_test.go \
      --replace "TestZoneExternalCNAMELookupWithProxy" \
                "SkipZoneExternalCNAMELookupWithProxy"

    substituteInPlace test/readme_test.go \
      --replace "TestReadme" "SkipReadme"
  '' + lib.optionalString stdenv.isDarwin ''
    # loopback interface is lo0 on macos
    sed -E -i 's/\blo\b/lo0/' plugin/bind/setup_test.go
  '';

  meta = with lib; {
    homepage = "https://coredns.io";
    description = "A DNS server that runs middleware";
  };
}
