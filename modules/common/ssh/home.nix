{ config, pkgs, lib, bconfig, ... }: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      "desktop" = {
        hostname = "192.168.4.110";
        user = "kwkaiser";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        forwardAgent = true;
      };
    };
    extraConfig = ''
      Host *
        ServerAliveInterval 300
        ServerAliveCountMax 2
        TCPKeepAlive yes
    '';
  };
}
