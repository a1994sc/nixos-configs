{ config, pkgs, lib, ... }:

{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/run/secrets/cache-priv-key.pem";
  };

  sops.secrets.cache = {
    owner = "nix-serve";
    sopsFile = /etc/nixos/secrets/cache.yaml;
    mode = "0600";
  };

  services.nginx = {
    # enable = true;
    virtualHosts = {
      "cache.10.2.1.9.nip.io" = {
        serverAliases = [ "binarycache" ];
        locations."/".extraConfig = ''
          proxy_pass http://localhost:${toString config.services.nix-serve.port};
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
        locations."^/nix-cache-info".extraConfig = ''
          proxy_store        on;
          proxy_store_access user:rw group:rw all:r;
          proxy_temp_path    /mnt/nginx/nix-cache-info/temp;
          root               /mnt/nginx/nix-cache-info/store;
          proxy_set_header Host "cache.nixos.org";
          proxy_pass https://cache.nixos.org;
        '';
        locations."^/nar/.+$".extraConfig = ''
          proxy_store        on;
          proxy_store_access user:rw group:rw all:r;
          proxy_temp_path    /mnt/nginx/nar/temp;
          root               /mnt/nginx/nar/store;

          proxy_set_header Host "cache.nixos.org";
          proxy_pass https://cache.nixos.org;
        '';
      };
    };
  };
}