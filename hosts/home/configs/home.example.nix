{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hosts/home/configs/example.nix
  ];

  home.username = "ascii";
  home.homeDirectory = "/home/ascii";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
}