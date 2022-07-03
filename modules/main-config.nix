{ config, pkgs, lib, ... }:

{
  security.pki.certificateFiles = [ "/etc/nixos/cert" ];

  programs.bash.enableCompletion = true;

  networking.domain   = "adrp.xyz";
  networking.search   = [ "adrp.xyz" ];

  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  nix = {
    maxJobs = "auto";
    autoOptimiseStore = true;
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
    settings.auto-optimise-store = true;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";


  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  services.xserver.enable = false;

  users.users.ascii = {
    isNormalUser = true;
    extraGroups  = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
  ];

  system.autoUpgrade = {
    enable      = true;
    allowReboot = true;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
