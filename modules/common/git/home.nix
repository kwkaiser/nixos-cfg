{
  pkgs,
  bconfig,
  isDarwin,
  ...
}: {
  home.packages = with pkgs; [
    git-trim
    git-delete-merged-branches
  ];
  programs.git = {
    enable = true;
    signing.format = null;
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
          cof = "!git co \$(git branch --format='%(refname:short)' | fzf)";
          df = "!git br -D \$(git branch --format='%(refname:short)' | fzf -m | xargs)";
          cleanup = "!git trim --no-update --no-confirm && git worktree prune";
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
