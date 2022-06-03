{ config, pkgs, lib, ... }:

{
  systemd.services.k3s-agent = {
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
         "${pkgs.k3s}/bin/k3s agent"
         "--token-file ${lib.mkDefault config.sops.secrets.k3s-server-token.path}"
         "--server https://10.2.25.99:6443"
         "--kubelet-arg=config=/etc/nixos/misc/configs/k3s_kublet.yaml"
       ];
     };
  };
}