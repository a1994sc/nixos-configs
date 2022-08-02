{ config, pkgs, lib, ... }:

{
 # This configuration worked on 09-03-2021 nixos-unstable @ commit 102eb68ceec
 # The image used https://hydra.nixos.org/build/134720986

  imports =
    [
      "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz" }/raspberry-pi/4"
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot = {
#    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = false;
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # A lot GUI programs need this, nearly all wayland applications
        "cma=128M"
    ];
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
  ];

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  boot.loader.raspberryPi.firmwareConfig= toString [
    "dtoverlay=rpi-poe"
    "dtparam=poe_fan_temp0=10000"
    "dtparam=poe_fan_temp1=60000"
    "dtparam=poe_fan_temp2=63000"
    "dtparam=poe_fan_temp3=66000"
    "dtparam=watchdog=on"
  ];
}
