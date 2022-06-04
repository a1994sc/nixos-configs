{ config, lib, pkgs, ...}: let
in {
  config = {
    boot.kernelParams = [
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];

    environment.systemPackages = with pkgs; [
      kubectl
      k3s
    ];

    sops.secrets.k3s-server-token.sopsFile = ../../secrets/k3s.yaml;

    #  virtualisation.containerd = {
    #    enable = true;
    #  };
  };
}
