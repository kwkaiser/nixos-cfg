{
  pkgs,
  bconfig,
  isDarwin,
  ...
}: {
  home.packages = with pkgs;
    [
      git-trim
      git-delete-merged-branches
    ]
    ++ [
      (writeShellScriptBin "git-wt-claim" (builtins.readFile ./wt-claim.sh))
      (writeShellScriptBin "git-wt-release" (builtins.readFile ./wt-release.sh))
      (writeShellScriptBin "git-wt-switch" (builtins.readFile ./wt-switch.sh))
      (writeShellScriptBin "git-wt-delete" (builtins.readFile ./wt-delete.sh))
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
          cf = "!git wt-switch \$(git branch --format='%(refname:short)' | fzf -m | xargs)";
          pl = "pull";
          ps = "push";
          rb = "rebase";
          rbx = "rebase -X ours";
          br = "branch";
          cof = "!git co \$(git branch --format='%(refname:short)' | fzf)";
          df = "!git wt-delete \$(git branch --format='%(refname:short)' | fzf -m | xargs)";
          cleanup = "!git trim --no-update --no-confirm && git worktree prune";
        };
        push.default = "current";
        push.autoSetupRemote = true;
        branch.autoSetupMerge = "always";
        pull.rebase = true;
        init.defaultBranch = "main";
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
