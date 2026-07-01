{...}: {
  home.file.".ssh/config".force = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = true;
        ServerAliveInterval = 300;
        ServerAliveCountMax = 2;
        TCPKeepAlive = "yes";
      };
      "homelab-vm" = {
        Hostname = "localhost";
        Port = 2222;
        User = "kwkaiser";
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
        AddKeysToAgent = "yes";
      };
      "desktop" = {
        Hostname = "192.168.4.110";
        User = "kwkaiser";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com";
      };
      "livingroom" = {
        Hostname = "192.168.4.109";
        User = "bingus";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
      };
      "desktop-unlock" = {
        Hostname = "192.168.4.110";
        User = "root";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        RequestTTY = "force";
        RemoteCommand = "cryptsetup-askpass";
        MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com";
      };
      "desktop-wakeup" = {
        Hostname = "192.168.4.109";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        User = "bingus";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        RemoteCommand = "wakeonlan 70:85:c2:dc:da:23";
      };
    };
  };
}
