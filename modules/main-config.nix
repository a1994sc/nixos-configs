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
    ''
    Red Hat CA
    =========
    -----BEGIN CERTIFICATE-----
    MIID6DCCAtCgAwIBAgIBFDANBgkqhkiG9w0BAQsFADCBpTELMAkGA1UEBhMCVVMx
    FzAVBgNVBAgMDk5vcnRoIENhcm9saW5hMRAwDgYDVQQHDAdSYWxlaWdoMRYwFAYD
    VQQKDA1SZWQgSGF0LCBJbmMuMRMwEQYDVQQLDApSZWQgSGF0IElUMRswGQYDVQQD
    DBJSZWQgSGF0IElUIFJvb3QgQ0ExITAfBgkqhkiG9w0BCQEWEmluZm9zZWNAcmVk
    aGF0LmNvbTAeFw0xNTEwMTQxNzI5MDdaFw00NTEwMDYxNzI5MDdaME4xEDAOBgNV
    BAoMB1JlZCBIYXQxDTALBgNVBAsMBHByb2QxKzApBgNVBAMMIkludGVybWVkaWF0
    ZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
    ggEKAoIBAQDYpVfg+jjQ3546GHF6sxwMOjIwpOmgAXiHS4pgaCmu+AQwBs4rwxvF
    S+SsDHDTVDvpxJYBwJ6h8S3LK9xk70yGsOAu30EqITj6T+ZPbJG6C/0I5ukEVIeA
    xkgPeCBYiiPwoNc/te6Ry2wlaeH9iTVX8fx32xroSkl65P59/dMttrQtSuQX8jLS
    5rBSjBfILSsaUywND319E/Gkqvh6lo3TEax9rhqbNh2s+26AfBJoukZstg3TWlI/
    pi8v/D3ZFDDEIOXrP0JEfe8ETmm87T1CPdPIZ9+/c4ADPHjdmeBAJddmT0IsH9e6
    Gea2R/fQaSrIQPVmm/0QX2wlY4JfxyLJAgMBAAGjeTB3MB0GA1UdDgQWBBQw3gRU
    oYYCnxH6UPkFcKcowMBP/DAfBgNVHSMEGDAWgBR+0eMgvlHoSCD3ri/GasNz824H
    GTASBgNVHRMBAf8ECDAGAQH/AgEBMA4GA1UdDwEB/wQEAwIBhjARBglghkgBhvhC
    AQEEBAMCAQYwDQYJKoZIhvcNAQELBQADggEBADwaXLIOqoyQoBVck8/52AjWw1Cv
    ath9NGUEFROYm15VbAaFmeY2oQ0EV3tQRm32C9qe9RxVU8DBDjBuNyYhLg3k6/1Z
    JXggtSMtffr5T83bxgfh+vNxF7o5oNxEgRUYTBi4aV7v9LiDd1b7YAsUwj4NPWYZ
    dbuypFSWCoV7ReNt+37muMEZwi+yGIU9ug8hLOrvriEdU3RXt5XNISMMuC8JULdE
    3GVzoNtkznqv5ySEj4M9WsdBiG6bm4aBYIOE0XKE6QYtlsjTMB9UTXxmlUvDE0wC
    z9YYKfC1vLxL2wAgMhOCdKZM+Qlu1stb0B/EF3oxc/iZrhDvJLjijbMpphw=
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
