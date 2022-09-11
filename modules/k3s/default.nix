{ config, lib, pkgs, ...}: 

{
  config = {
    boot.kernelParams = [
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];

    environment.systemPackages = with pkgs; [
      k3s
      lvm2
      # ceph
      ceph-csi
      cri-tools
    ];

    boot.kernelModules = [
      # Istio modules
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
      # Rook Ceph module
      "rbd"
    ];

    networking.extraHosts =
      ''
        10.2.25.50  trunk00 
        10.2.25.51  trunk01
        10.2.25.52  trunk02
        10.2.25.55  trunk10 
        10.2.25.56  trunk11 
        10.2.25.60  leaf00 
        10.2.25.61  leaf01
        10.2.25.62  leaf02 
        10.2.25.70  leaf10
        10.2.25.71  leaf11
        10.2.25.72  leaf12
      '';

    # environment.etc."cni".source = pkgs.buildEnv {
    #   name = "etc-cni-bin";
    #   paths = [ pkgs.cni-plugins pkgs.cilium-cli ];
    #   pathsToLink = [ "/bin" ];
    # };

  virtualisation.containerd = {
    enable = true
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        # FIXME: upstream
        cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
      };
    };
  };
}
