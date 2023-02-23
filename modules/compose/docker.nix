{ config, pkgs, lib, ... }: let
in {
  virtualisation.oci-containers.backend = "docker";
}