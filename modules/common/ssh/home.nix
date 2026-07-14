{
  lib,
  pkgs,
  ...
}: {
  home.file.".ssh/config".force = true;
  home.file.".ssh/rc" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -n "$SSH_AUTH_SOCK" ]; then
        ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock_link"
      fi
    '';
  };
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
      "desktop-lan-check" = lib.hm.dag.entryBefore ["desktop"] {
        header = ''Match originalhost desktop exec "${pkgs.coreutils}/bin/timeout 1 ${pkgs.bash}/bin/bash -c '</dev/tcp/192.168.4.110/22'"'';
        ProxyJump = "none";
      };
      "desktop" = {
        Hostname = "192.168.4.110";
        User = "kwkaiser";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com";
      };
      "livingroom-lan-check" = lib.hm.dag.entryBefore ["livingroom"] {
        header = ''Match originalhost livingroom exec "${pkgs.coreutils}/bin/timeout 1 ${pkgs.bash}/bin/bash -c '</dev/tcp/192.168.4.109/22'"'';
        ProxyJump = "none";
      };
      "livingroom" = {
        Hostname = "192.168.4.109";
        User = "bingus";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
      };
      "desktop-unlock" = {
        Hostname = "box.kwkaiser.io";
        User = "kwkaiser";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        RequestTTY = "force";
        RemoteCommand = "ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o MACs=hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com root@192.168.4.110 systemd-tty-ask-password-agent --query";
      };
      "desktop-wakeup" = {
        Hostname = "box.kwkaiser.io";
        User = "kwkaiser";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        RemoteCommand = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null bingus@192.168.4.109 wakeonlan 70:85:c2:dc:da:23";
      };
      "desktop-wm" = {
        Hostname = "192.168.4.110";
        User = "kwkaiser";
        ProxyJump = "kwkaiser@box.kwkaiser.io";
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com";
        RequestTTY = "force";
        RemoteCommand = "sudo greetd-remote-login";
      };
    };
  };
}
