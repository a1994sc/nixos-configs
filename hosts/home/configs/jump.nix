{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source <(helm completion bash)
      source <(flux completion bash)
      source <(istioctl completion bash)
    '';
  };
}