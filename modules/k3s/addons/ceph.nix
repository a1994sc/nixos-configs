{ config, lib, pkgs, ...}: 

{
  environment.systemPackages = with pkgs; [
    lvm2
    # ceph
    # ceph-csi
    gptfdisk
    parted
  ];

  system.activationScripts.cluster-fix = ''
      ln -sfn /run/current-system/sw/bin/* /bin/
    '';

  boot.kernelModules = [
    "rbd"
  ];
}
