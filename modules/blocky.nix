{ config, pkgs, lib, ... }: let

in {
  services.blocky.enable = true;
  services.blocky.settings = {
    upstream.default = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    upstreamTimeout = "2s";
    startVerifyUpstream = true;
    connectIPVersion = "dual";
    minTlsServeVersion = "1.3";

    blocking = {
      blackLists.ads = [
        "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
        "https://v.firebog.net/hosts/AdguardDNS.txt"
        "https://v.firebog.net/hosts/Easyprivacy.txt"
        "https://v.firebog.net/hosts/Prigent-Ads.txt"
        "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
        "https://phishing.army/download/phishing_army_blocklist_extended.txt"
      ];
      clientGroupsBlock.default = [ "ads" ];
      blockType = "zeroIp";
      blockTTL = "1m";
      refreshPeriod = "4h";
      downloadTimeout = "4m";
      downloadAttempts = 5;
      downloadCooldown = "10s";
      startStrategy = "blocking";
    };

    prometheus.enable = false;
    filtering.queryTypes = [ "AAAA" ];
    ports.dns = 8153;

    log = {
      level = "info";
      format = "text";
      timestamp = true;
      privacy = false;
    };
  };

  services.dnsdist = {
    enable = true;
    listenPort = 53;
    listenAddress = "0.0.0.0";
    extraConfig = ''
      setACL({'0.0.0.0/0'})
      truncateTC(true)
      warnlog(string.format("Script starting %s", "up!"))
      newServer("127.0.0.1:8153")
      newServer({address="127.0.0.1:8154", pool="lab"})
      addAction({'example.io.', 'adrp.xyz.', '10.in-addr.arpa.'}, PoolAction("lab"))
      setServerPolicy(roundrobin)
      setSecurityPollSuffix("")
    '';
  };
}
