{ config, pkgs, lib, ... }:
let
  rev = "master";
in
{
  imports = [
    "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/${rev}.tar.gz"}/modules/sops"
  ];

  environment.systemPackages = with pkgs; [
    age
    gnupg
  ];

  sops.age.keyFile = "/home/aconlon/.config/sops/age/keys.txt";
}
