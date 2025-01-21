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
    extraConfig = {
      push.default = "current";
      pull.default = "current";
    };

  } // (if bconfig.mine.git.signsCommits then {
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.defaultKeyCommand =
        "sh -c 'ssh-add -L | grep -i AAAAB3NzaC1yc2EAAAADAQABAAABgQDTAi1Dr0jHCqvAKGnZzpFy0I7AqB2aDTih8cxq0Q3ZkaAJK0lhbmm'";
    };
  } else
    { });

}
