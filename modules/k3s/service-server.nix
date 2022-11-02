{ config, pkgs, lib, ... }: let
  kubeletConfig = pkgs.writeText "k3s_kubelet.yaml"
    ''
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      shutdownGracePeriod: 30s
      shutdownGracePeriodCriticalPods: 10s
    '';
in {
  sops.secrets.token.sopsFile = /etc/nixos/modules/k3s/secrets/server.yaml;

  environment.systemPackages = with pkgs; [
    kubectl
  ];

  systemd.services.k3s-args = {
    enable = false;
    description = toString [
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
        "--kubelet-arg=config=${kubeletConfig}"
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];
  };

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
      ExecStart = "${config.systemd.services.k3s-args.description}";
    };
  };
}