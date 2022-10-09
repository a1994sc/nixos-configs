# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  rev = "d92fba1bfc9f64e4ccb533701ddd8590c0d8c74a";
in {
  imports =
    [
      /etc/nixos/modules/main-config.nix
      /etc/nixos/modules/bare.nix
      /etc/nixos/modules/tailscale.nix
#      /etc/nixos/modules/smallstep/amd64/certificate.nix
#      /etc/nixos/modules/smallstep/amd64/cli.nix
      "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/${rev}.tar.gz"}/modules/sops"
      /etc/nixos/hosts/home/manager.nix
    ];

  networking.hostName = "jump-host";

  nix.gc.dates = "Wed 02:00";

  system.autoUpgrade.dates = "Wed 04:00";

  nixpkgs.overlays = [
    (self: super: {
      helm = super.callPackage /etc/nixos/pkgs/prebuilt/amd64/helm.nix {};
    })
    (self: super: {
      istioctl = super.callPackage /etc/nixos/pkgs/prebuilt/amd64/istioctl.nix {};
    })
  ];

  home-manager.users.ascii = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    programs.bash.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    istioctl
    linode-cli
    terraform
    ansible
    nix-prefetch
    infnoise
    fluxcd
    yubikey-manager
    age
    gnupg
  ];

  services.nginx = {
    enable = true;
    streamConfig = ''
      upstream k3s_servers {
        server 10.2.25.50:6443;
        server 10.2.25.51:6443;
        server 10.2.25.52:6443;
        server 10.2.25.55:6443;
        server 10.2.25.56:6443;
      }

      server {
        listen 6443;
        proxy_pass k3s_servers;
      }
    '';
  };

  programs.ssh.startAgent = true;

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", OWNER="ascii", TAG+="uaccess"
  '';

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

  sops.secrets.jump = {
    owner = "jump";
    path = "/home/jump/.ssh/jump";
    sopsFile = /etc/nixos/secrets/jump.yaml;
    mode = "0600";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  systemd.services.tailscale.environment = {
      PORT = "41641";
    };
}