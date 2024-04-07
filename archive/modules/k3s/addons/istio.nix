{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [
    "br_netfilter"
    "ip6table_mangle"
    "ip6table_nat"
    "ip6table_raw"
    "iptable_mangle"
    "iptable_nat"
    "iptable_raw"
    "xt_REDIRECT"
    "xt_connmark"
    "xt_conntrack"
    "xt_mark"
    "xt_owner"
    "xt_tcpudp"
    "bridge"
    "ip6_tables"
    "ip_tables"
    "nf_conntrack"
    "nf_conntrack_ipv4"
    "nf_conntrack_ipv6"
    "nf_nat"
    "nf_nat_ipv4"
    "nf_nat_ipv6"
    "nf_nat_redirect"
    "x_tables"
  ];
}
