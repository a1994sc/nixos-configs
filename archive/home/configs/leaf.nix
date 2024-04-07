{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source <(k3s completion bash)
      source <(crictl completion bash)
    '';
  };
}
