{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = config.mine.email;
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
