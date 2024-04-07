{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    device-tree_rpi
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_5_15.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
        sha256 = "9bfabc38e56758bd0cfe22715a3f9a74cdf4a8870f3b150a03d2ffda29f832dc";
      };
      version = "5.15.44";
      modDirVersion = "5.15.44";
    };
  });
}
