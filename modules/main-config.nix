{ config, pkgs, lib, ... }:

{
  security.pki.certificates = [
    ''
    Derpy CA
    =========
    -----BEGIN CERTIFICATE-----
    MIIBdDCCARqgAwIBAgIRANkYt8S37DW7KItbxVZr9OUwCgYIKoZIzj0EAwIwGDEW
    MBQGA1UEAxMNRGVycHkgUm9vdCBDQTAeFw0yMDEyMzEwMDI1NTNaFw0zMDEyMzEw
    MDI1NTNaMBgxFjAUBgNVBAMTDURlcnB5IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggq
    hkjOPQMBBwNCAATOFoME0It/e323PaeOgrrQZGUGbz3AovjJBBDLAkwld057duoq
    2ppzrcNQYm3/KfFJrGZUbel0PHpIqh4ufFJWo0UwQzAOBgNVHQ8BAf8EBAMCAQYw
    EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUSCs2bRDtMPz4sfHi3sUfJLw5
    nVgwCgYIKoZIzj0EAwIDSAAwRQIhALmYLFGo9FUAGP6wY8vj1Q5wRXW6n6xV/S6T
    RG/LtMsYAiBwzyJT5Ht+D/KnxHCqhDTxb/kQQL41IyEcswrIdDF4wA==
    -----END CERTIFICATE-----
    ''
  ];

  programs.bash.enableCompletion = true;

  networking = {
    domain = "adrp.xyz";
    search = [ "adrp.xyz" ];

    wireless.enable = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    firewall.enable = false;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "${config.networking.hostName}@${config.networking.domain}";
    server = "https://10.2.1.9/acme/acme/directory";
    validMinDays = 2;
    keyType = "ec384";
    extraLegoFlags = [
      "--http"
    ];
  };

  nix = {
    settings = {
      max-jobs = "auto";
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    # Free up to 2GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024 * 2)}
    '';
    optimise = {
      automatic = true;
      dates = [ "@daily" ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  services.xserver.enable = false;

  users.users.ascii = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "dialout" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVflfgY9+i0jlwcHlVvONUIFyDN3ynU0sEF0nv4nFrw phone@conlon.dev"
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    htop
    git
    python3
  ];

  environment.etc = {
    environment = {
      text = ''
        PATH="/run/current-system/sw/bin/:$PATH"
      '';
      mode = "0644";
    };
  };

  system.autoUpgrade = {
    enable      = true;
    allowReboot = true;
    channel = https://nixos.org/channels/nixos-22.11;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  system.stateVersion = "22.05";
}
