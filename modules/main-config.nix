{ config, pkgs, lib, ... }: let
  git-rebuild-script = pkgs.writeShellScriptBin "rebuid.sh" ''
    if [ -f /etc/nixos/daily.ignore ]; then
      ${pkgs.coreutils-full}/bin/echo "Skipping daily rebuilding"
    else
      /run/wrappers/bin/sudo -u ${config.users.users.ascii.name} ${pkgs.git}/bin/git -C /etc/nixos/ clean -df
      /run/wrappers/bin/sudo -u ${config.users.users.ascii.name} ${pkgs.git}/bin/git -C /etc/nixos/ stash
      /run/wrappers/bin/sudo -u ${config.users.users.ascii.name} ${pkgs.git}/bin/git -C /etc/nixos/ pull
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
    fi
  '';
in {
  imports = [
    /etc/nixos/modules/ca-certs.nix
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
      dates = [ "daily" ];
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    htop
    git
    python3
  ];

  system.autoUpgrade = {
    enable      = true;
    allowReboot = true;
    channel = https://nixos.org/channels/nixos-unstable;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  systemd = {
    services.git-rebuild = {
      serviceConfig = {
        Type = "oneshot";
      };
      script = "${git-rebuild-script}/bin/rebuid.sh";
    };
    timers.git-rebuild = {
      enable = true;
      wantedBy = [ "timers.target" ];
      partOf = [ "git-rebuild.service" ];
      timerConfig = {
        OnCalendar = "0/3:00:00";
        Unit = "git-rebuild.service";
      };
    };
  };

  system.stateVersion = "22.05";
}
