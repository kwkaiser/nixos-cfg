{ config, pkgs, bonus, ... }: {
  programs.git = {
    enable = true;
    userName = bonus.mine.email;
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
