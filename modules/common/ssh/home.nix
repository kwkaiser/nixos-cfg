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
        extraConfig = ''
          StrictHostKeyChecking no
        '';
      };
    };
    matchBlocks = {
      "desktop-unlock" = {
        hostname = "192.168.4.110";
        user = "root";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        forwardAgent = true;
        RemoteCommand = "cryptsetup-askpass";
        extraConfig = ''
          StrictHostKeyChecking no
        '';
      };
    };
    matchBlocks = {
      "desktop-wakeup" = {
        hostname = "box.kwkaiser.io";
        user = "kwkaiser";
        forwardAgent = true;
        RemoteCommand = "wakeonlan 70:85:c2:dc:da:23";
        extraConfig = ''
          StrictHostKeyChecking no
        '';
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
