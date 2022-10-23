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
        # "--flannel-backend=none"
        # "--disable-network-policy"
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];
    };
  };
}