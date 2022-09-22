{ config, lib, pkgs, ...}: 

{
  # Run the following commands before adding this module.
  # $ sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
  # $ sudo nix-channel --update
  imports = [
    <home-manager/nixos>
  ];

  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.activationScripts.home-man = ''
      chown -R ascii:users /etc/nixos/host/home/configs
      ln /etc/nixos/hosts/home/configs/ /home/ascii/.config/nixpkgs/
    '';
}
