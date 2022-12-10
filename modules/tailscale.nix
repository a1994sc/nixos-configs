{ config, pkgs, ... }:

{
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  # if you want exit-node or advertise-routes to work properly
  # boot.kernel.sysctl = {
  #   "net.ipv4.ip_forward" = 1;
  #   "net.ipv6.conf.all.forwarding" = 1;
  # };
}
