{ config, pkgs, ... }:

{
  imports = [
    example.nix
  ];

  home.username = "ascii";
  home.homeDirectory = "/home/ascii";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
}