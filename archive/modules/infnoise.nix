{ config, pkgs, lib, ... }:

{
  # nixpkgs.overlays = [
  #   (self: super: {
  #     infnoise = super.callPackage /etc/nixos/pkgs/build/infnoise.nix {};
  #   })
  # ];

  environment.systemPackages = with pkgs; [
    infnoise
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", SYMLINK+="infnoise", GROUP="dialout", MODE="0664"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015" ,TAG+="systemd", ENV{SYSTEMD_WANTS}="infnoise.service"
  '';

  systemd.services.infnoise = {
    # Unit
    description = "Wayward Geek InfNoise TRNG driver";
    after = [ "dev-infnoise.device" ];
    bindsTo = [ "dev-infnoise.device" ];
    # Install
    wantedBy = [ "multi-user.target" ];
    # Service
    serviceConfig = {
      Type = "forking";
      WorkingDirectory = "/tmp";
      ExecStart = "${pkgs.infnoise}/bin/infnoise --dev-random --daemon --pidfile /var/run/infnoise.pid";
      User = "root";
      Group = "root";
      Restart = "always";
    };
  };
}
