{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source <(helm completion bash)
      source <(k3s completion bash)
      source <(crictl completion bash)
    '';
  };
}
