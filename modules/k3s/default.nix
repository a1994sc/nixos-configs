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

    networking.extraHosts =
      ''
        10.2.25.50  trunk00 
        10.2.25.51  trunk01
        10.2.25.52  trunk02
        10.2.25.56  trunk11 
        10.2.25.60  leaf00 
        10.2.25.61  leaf01 
        10.2.25.70  leaf10
        10.2.25.71  leaf11
      '';

    #  virtualisation.containerd = {
    #    enable = true;
    #  };
  };
}
