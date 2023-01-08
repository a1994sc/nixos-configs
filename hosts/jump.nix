# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  rev = "f72e050c3ef148b1131a0d2df55385c045e4166b";
in {
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/tailscale.nix
      /etc/nixos/modules/step-ca.nix
      /etc/nixos/modules/wireguard.nix
      /etc/nixos/hosts/home/manager.nix
      "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/${rev}.tar.gz"}/modules/sops"
    ];

  networking.hostName = "jump-host";

  nix.gc.dates = "Wed 02:00";

  system.autoUpgrade.dates = "Wed 04:00";

  boot.cleanTmpDir = true;

  home-manager.users.ascii = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    programs.bash.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    # istioctl
    terraform
    ansible
    nix-prefetch
    # fluxcd
    # age
    # gnupg
    # gitops
    # cloudflared
  ];

  services.nginx = {
    enable = false;
    streamConfig = ''
      upstream k3s_servers {
        server 10.2.25.100:6443;
        server 10.2.25.101:6443;
        server 10.2.25.102:6443;
      }

      server {
        listen 6443;
        proxy_pass k3s_servers;
      }
    '';
  };

  programs.ssh.startAgent = true;

  users.users.jump = {
    isNormalUser = true;
    extraGroups  = [];
    openssh.authorizedKeys.keys =  [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVflfgY9+i0jlwcHlVvONUIFyDN3ynU0sEF0nv4nFrw phone@adrp.xyz"
    ];
  };

  sops.age.keyFile = "/home/ascii/.config/sops/age/keys.txt";

  sops.secrets.ascii = {
    owner = "ascii";
    path = "/home/ascii/.ssh/jump";
    sopsFile = /etc/nixos/secrets/ascii.yaml;
    mode = "0600";
  };

  sops.secrets.vault = {
    owner = "ascii";
    path = "/home/ascii/.ssh/vault";
    sopsFile = /etc/nixos/secrets/vault.yaml;
    mode = "0600";
  };

  sops.secrets.jump = {
    owner = "jump";
    path = "/home/jump/.ssh/jump";
    sopsFile = /etc/nixos/secrets/jump.yaml;
    mode = "0600";
  };

  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "10.2.1.9";
    prefixLength = 24;
  } ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}