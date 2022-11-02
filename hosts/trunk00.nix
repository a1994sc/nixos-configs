{ config, lib, pkgs, ... }: let 
  k3s-args = toString [
    "${pkgs.k3s}/bin/k3s server"
    "--tls-san 10.2.1.9"
    "--cluster-init"
    "--token-file ${config.sops.secrets.token.path}"
    "--disable traefik,servicelb,metrics-server,coredns"
    "--write-kubeconfig-mode=644"
    "--kube-apiserver-arg default-not-ready-toleration-seconds=30"
    "--kube-apiserver-arg default-unreachable-toleration-seconds=30"
    "--kube-apiserver-arg feature-gates=GracefulNodeShutdown=true"
    "--kube-apiserver-arg feature-gates=GracefulNodeShutdownBasedOnPodPriority=true"
    "--kube-controller-arg node-monitor-period=20s"
    "--kube-controller-arg node-monitor-grace-period=20s"
    "--kubelet-arg node-status-update-frequency=5s"
    "--kubelet-arg shutdownGracePeriod=30s"
    "--kubelet-arg shutdownGracePeriodCriticalPods=10s"
    "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
in {
  imports =
    [ 
      /etc/nixos/modules/k3s/arm64/server.nix
      /etc/nixos/modules/raspberry-pi.nix
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/sops.nix
      /etc/nixos/hosts/home/manager.nix
    ];

  networking.hostName = "trunk00";

  nix.gc.dates = "Fri 02:00";

  system.autoUpgrade.dates = "Fri 04:00";

  systemd.services.k3s-server.serviceConfig.ExecStart = pkgs.lib.mkForce k3s-args;
}
