{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        extraOptions = {
          ServerAliveInterval = "300";
          ServerAliveCountMax = "2";
          TCPKeepAlive = "yes";
        };
      };
      "homelab-vm" = {
        hostname = "localhost";
        port = 2222;
        user = "kwkaiser";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          AddKeysToAgent = "yes";
        };
      };
      "desktop" = {
        hostname = "192.168.4.110";
        user = "kwkaiser";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        forwardAgent = true;
        extraOptions = {StrictHostKeyChecking = "no";};
      };
      "livingroom" = {
        hostname = "192.168.4.109";
        user = "bingus";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        forwardAgent = true;
      };
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
      "desktop-wakeup" = {
        hostname = "192.168.4.109";
        proxyJump = "kwkaiser@box.kwkaiser.io";
        user = "bingus";
        forwardAgent = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
          RemoteCommand = "wakeonlan 70:85:c2:dc:da:23";
        };
      };
    };
  };
}
