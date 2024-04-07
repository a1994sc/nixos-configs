{ config, pkgs, lib, ... }:
let
  kubeletConfig = pkgs.writeText "k3s_kubelet.yaml"
    ''
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration

      shutdownGracePeriod: 30s
      shutdownGracePeriodCriticalPods: 10s
    '';
in
{
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
        "--kubelet-arg=config=${kubeletConfig}"
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
        # CIS Hardening
        "--kubelet-arg='streaming-connection-idle-timeout=5m'"
        "--kubelet-arg='make-iptables-util-chains=true'"
      ];
    };
  };
}
