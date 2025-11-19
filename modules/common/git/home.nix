{ config, pkgs, bconfig, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.name = bconfig.mine.email;
      user.email = bconfig.mine.email;
      alias = {
        co = "checkout";
        pl = "pull";
        ps = "push";
        rb = "rebase";
        rbx = "rebase -X ours";
        br = "branch";
      };
      push.default = "current";         
      push.autoSetupRemote = true;      
      branch.autoSetupMerge = "always"; 
      pull.rebase = true;
    } // (if bconfig.mine.git.signsCommits then {
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.defaultKeyCommand =
        "sh -c 'ssh-add -L | grep -i AAAAB3NzaC1yc2EAAAADAQABAAABgQDTAi1Dr0jHCqvAKGnZzpFy0I7AqB2aDTih8cxq0Q3ZkaAJK0lhbmm'";
    } else
      { });
  };
}
