{ config, pkgs, lib, ... }:

{
  imports = [ "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz"}/modules/sops" ];

  environment.systemPackages = with pkgs; [
    age
    gnupg
  ];

  sops.age.keyFile = "/home/ascii/.config/sops/age/keys.txt";
}
