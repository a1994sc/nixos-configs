{ config, lib, pkgs, ... }:

{
  imports = [
    /etc/nixos/modules/k3s/addons/ceph.nix
    /etc/nixos/modules/k3s/addons/istio.nix
  ];

  boot.kernelParams = [
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  environment.systemPackages = with pkgs; [
    k3s
    cri-tools
    openiscsi
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
  #   paths = [ pkgs.cni-plugins ];
  #   pathsToLink = [ "/etc/cni/bin" ];
  # };

  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        # cni.conf_dir = "/etc/cni/net.d/";
        # cni.bin_dir = "/opt/cni/bin";
        # FIXME: upstream
        cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
      };
    };
  };
}
