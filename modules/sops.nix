{ config, pkgs, lib, ... }:
let
  rev = "b6ab3c61e2ca5e07d1f4eb1b67304e2670ea230c";
#  src = fetchFromGitHub {
#    owner = "Mic92";
#    repo = "sops-nix";
#    rev = "f075361ecbde21535b38e41dfaa28a28f160855c";
#    sha256 = "sha256-uCdQ2fzIPGakHw2TkvOncUvCl7Fo7z/vagpDWYooO7s=";
#  };
in {
  imports = [ "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/${rev}.tar.gz"}/modules/sops" ];

  environment.systemPackages = with pkgs; [
    age
    gnupg
  ];

  sops.age.keyFile = "/home/ascii/.config/sops/age/keys.txt";
}
