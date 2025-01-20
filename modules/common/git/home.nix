{ config, pkgs, bconfig, ... }: {
  programs.git = {
    enable = true;
    userName = bconfig.mine.email;
    aliases = {
      co = "checkout";
      pl = "pull";
      ps = "push";
      rb = "rebase";
      rbx = "rebase -X ours";
      br = "branch";
    };
  };
}
