# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ../modules/k3s/.
      ../modules/raspberry-pi.nix
      ../modules/main-config.nix
      ../modules/sops.nix
    ];

  networking.hostName = "trunk00";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  # over-ride the default k3s-server cmd as trunk00 acts as the cluster starter
  nixpkgs.overlays = [
    (self: super: {
      k3s = super.callPackage ../pkgs/k3s-arm64.nix {};
    })
  ];

  systemd.services.k3s-server = {
     # Unit
     description = "Lightweight Kubernetes";
     documentation = [ "https://k3s.io" ];
     wants = [ "network-online.target" ];
     # Install
     wantedBy = [ "multi-user.target" ];
     # Service
     serviceConfig = {
       Type = "exec";
       KillMode = "process";
       Delgate = "yes";
       LimitNOFILE = "infinity";
       LimitNPROC = "infinity";
       LimitCORE = "infinity";
       TasksMax = "infinity";
       TimeoutStartSec = "0";
       Restart = "always";
       RestartSec = "5s";
       ExecStartPre = "${pkgs.kmod}/bin/modprobe -a br_netfilter overlay";
       ExecStart = toString [
         "${pkgs.k3s}/bin/k3s server"
         "--tls-san 10.2.25.99"
         "--cluster-init"
         "--server https://10.2.25.99:6443"
         "--token-file ${config.sops.secrets.k3s-server-token.path}"
         "--disable traefik,servicelb,coredns,metrics-server"
         "--write-kubeconfig-mode=644"
         "--kube-apiserver-arg default-not-ready-toleration-seconds=30"
         "--kube-apiserver-arg default-unreachable-toleration-seconds=30"
         "--kube-apiserver-arg feature-gates=GracefulNodeShutdown=true"
         "--kube-controller-arg node-monitor-period=20s"
         "--kube-controller-arg node-monitor-grace-period=20s"
         "--kubelet-arg node-status-update-frequency=5s"
         "--kube-apiserver-arg feature-gates=GracefulNodeShutdownBasedOnPodPriority=true"
         "--kubelet-arg=config=/etc/nixos/modules/k3s/k3s_kubelet.yaml"
       ];
     };
  };
}
