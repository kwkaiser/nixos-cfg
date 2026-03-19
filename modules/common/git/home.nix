{
  pkgs,
  bconfig,
  isDarwin,
  ...
}: {
  home.packages = with pkgs; [
    git-trim
  ];
  programs.git = {
    enable = true;
    settings =
      {
        user.name = bconfig.mine.email;
        user.email = bconfig.mine.email;
        alias = {
          co = "checkout";
          pl = "pull";
          ps = "push";
          rb = "rebase";
          rbx = "rebase -X ours";
          br = "branch";
          cleanup = "!f() { git worktree list --porcelain | awk '/^worktree /{wt=$2} /^branch refs\\/heads\\//{b=substr($2,17); if(b!=\"main\"){print wt,b}}' | while read wt b; do if git merge-base --is-ancestor \"$b\" main 2>/dev/null; then git worktree remove \"$wt\"; fi; done; wt_branches=$(git worktree list --porcelain | awk -F/ '/^branch refs\\/heads\\//{print $NF}'); git branch --merged main | sed 's/^[* +]*//' | while read b; do echo \"$wt_branches\" | grep -qx \"$b\" || git branch -d \"$b\"; done; }; f";
        };
        push.default = "current";
        push.autoSetupRemote = true;
        branch.autoSetupMerge = "always";
        pull.rebase = true;
      }
      // (
        if bconfig.mine.git.signCommits
        then {
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.defaultKeyCommand = "sh -c 'ssh-add -L | grep -i AAAAB3NzaC1yc2EAAAADAQABAAABgQDTAi1Dr0jHCqvAKGnZzpFy0I7AqB2aDTih8cxq0Q3ZkaAJK0lhbmm'";
        }
        else {}
      )
      // (
        if isDarwin
        then {
        }
        else {
          credential.helper = "${pkgs.gitFull}/libexec/git-core/git-credential-libsecret";
        }
      );
  };
}
