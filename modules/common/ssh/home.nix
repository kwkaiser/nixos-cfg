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
        extraOptions = { StrictHostKeyChecking = "no"; };
      };
    };
    matchBlocks = {
      "desktop-unlock" = {
        hostname = "192.168.4.110";
        user = "root";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        forwardAgent = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
          RemoteCommand = "cryptsetup-askpass";
        };
      };
    };
    matchBlocks = {
      "desktop-wakeup" = {
        hostname = "box.kwkaiser.io";
        user = "kwkaiser";
        forwardAgent = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
          RemoteCommand = "wakeonlan 70:85:c2:dc:da:23";
        };
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
