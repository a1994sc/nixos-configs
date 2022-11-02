{ config, pkgs, lib, ... }: let

in {
  sops.secrets.token.sopsFile = /etc/nixos/modules/k3s/secrets/agent.yaml;

  systemd.services.k3s-agent = {
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
        "${pkgs.k3s}/bin/k3s agent"
        "--token-file ${config.sops.secrets.token.path}"
        "--server https://10.2.25.50:6443"
        "--kubelet-arg node-status-update-frequency=5s"
        "--kubelet-arg shutdownGracePeriod=30s"
        "--kubelet-arg shutdownGracePeriodCriticalPods=10s"
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];
    };
  };
}