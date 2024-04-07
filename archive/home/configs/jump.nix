{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source <(helm completion bash)
    '';
  };
}
