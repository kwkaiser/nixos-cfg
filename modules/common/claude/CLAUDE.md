# Code

## Code comments

I never ever ever want you to write comments in my code unless explicitly asked. If you violate this requirement, you are going against my express wishes and I will probably end up deleting them. It does not matter how complex the code you are writing is -- do not write comments in the code unless I request it.

If I ask for comments or explanations in an area:

- keep them terse and explain only subjects I wanted explanation on
- do not use syntax or details that are duplicative with the languages type system
    - this means no JSDoc @links!

# Git & Pull requests

## Working with worktrees

If `worktrunk` is available in a repo (usually the `wt` command) prefer to use it for setting up & tearing down worktrees. This is my preferred way of propagating values that may not be git-tracked. Here's a shortlist of options:

```
- `wt switch [-c] <branch>` — create/switch to a worktree by branch name (paths computed automatically)
- `wt list` — status across all worktrees (staged, commits, remote tracking)
- `wt merge <branch>` — squash/rebase/merge back + cleanup in one step
- `wt remove` — delete worktree + branch
- `wt switch pr:123` — checkout a PR into its own worktree
```

## Pull requests

- Never create one for me unless explicitly asked

## Branch conventions:

- Prefix branches with `u/kwkaiser/<topic>-<branch iter>`. For example:
    - `u/kwkaiser/foo-setup-1`
    - `u/kwkaiser/foo-setup-2`

## Pull request descriptions

- When describing branch changes for pull requests, use a maximum of 3 bullet points to describe changes
- Reference other pull requests this pull request may have up / downstream for stacked PRs / base branches
- Never include description of "verification steps" that are duplicative with basic CI. Only include description of verification steps if we did something separate from what CI is doing.
- Never include "Generated with claude code"

## Pull request feedback

Never ever respond to pull request feedback from humans on my behalf. 
