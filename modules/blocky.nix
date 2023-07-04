{ config, pkgs, lib, ... }: let

in {
  services.blocky.enable = true;
  services.blocky.settings = ''
    upstream:
      default:
      - 1.1.1.1
      - 1.0.0.1
    upstreamTimeout: 2s
    connectIPVersion: v4
    # customDNS:
    #   customTTL: 1h
    #   filterUnmappedTypes: true
    #   mapping:
    #     printer.lan: 192.168.178.3,2001:0db8:85a3:08d3:1319:8a2e:0370:7344
    blocking:
      blackLists:
        ads:
        - https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt
        - https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
        - https://v.firebog.net/hosts/AdguardDNS.txt
        - https://v.firebog.net/hosts/Easyprivacy.txt
        - https://v.firebog.net/hosts/Prigent-Ads.txt
        - https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
        - https://phishing.army/download/phishing_army_blocklist_extended.txt
        default:
        - ads
      zeroIp: 0.0.0.0 will
      blockType: zeroIp
      blockTTL: 15m
      refreshPeriod: 4h
      downloadTimeout: 4m
      downloadAttempts: 5
      downloadCooldown: 10s
      startStrategy: blocking
    caching:
      minTime: 5m
      maxTime: 30m
      maxItemsCount: 0
      prefetching: true
      prefetchExpires: 2h
      prefetchThreshold: 5
      prefetchMaxItemsCount: 0
      cacheTimeNegative: 30m
    prometheus:
      enable: false
    filtering:
      queryTypes:
      - AAAA
    ports:
      dns: 53
  '';
}
