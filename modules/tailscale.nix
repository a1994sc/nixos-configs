{ config, pkgs, ... }:

{
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  systemd.services.tailscale = {
    description = "Tailsscale Service";
    documentation = [ "https://tailscale.com/kb/" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" "NetworkManager.service" "systemd-resolved.service" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.tailscale}/bin/tailscaled --cleanup";
      ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --tun 'tailscale0' --port $PORT $FLAGS";
      ExecStopPost = "${pkgs.tailscale}/bin/tailscaled --cleanup";
    };
    environment = {
      PORT="41641"; 
    };
  };

  # if you want exit-node or advertise-routes to work properly
  # boot.kernel.sysctl = toString [
  #   "net.ipv4.ip_forward = 1"
  #   "net.ipv6.conf.all.forwarding = 1"
  # ];

  # added as a template to add new nodes
  # systemd.services.tailscale-autoconnect = {
  #   description = "Automatic connection to Tailscale";
  #   # make sure tailscale is running before trying to connect to tailscale
  #   after = [ "network-pre.target" "tailscale.service" ];
  #   wants = [ "network-pre.target" "tailscale.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   # set this service as a oneshot job
  #   serviceConfig.Type = "oneshot";
  #   # have the job run this shell script
  #   script = with pkgs; ''
  #     # wait for tailscaled to settle
  #     sleep 2
  #     # check if we are already authenticated to tailscale
  #     status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #     if [ $status = "Running" ]; then # if so, then do nothing
  #       exit 0
  #     fi
  #     # otherwise authenticate with tailscale
  #     ${tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
  #   '';
  # };
}
