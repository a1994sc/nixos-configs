{ config, pkgs, lib, ... }: let

in {
  sops.secrets.token.sopsFile = /etc/nixos/modules/k3s/secrets/server.yaml;

  environment.systemPackages = with pkgs; [
    kubectl
  ];

  systemd.services.k3s-server = {
    # Unit
    description = "Lightweight Kubernetes";
    documentation = [ "https://k3s.io" ];
    wants = [ "network-online.target" "containerd.service" ];
    after = [ "containerd.service" ];
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
        "--tls-san 10.2.1.9"
        "--server https://10.2.25.50:6443"
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
    };
  };
}