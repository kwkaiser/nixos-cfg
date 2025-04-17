{ config, pkgs, lib, bconfig, ... }: {
  programs.ssh.forwardAgent = true;
}
