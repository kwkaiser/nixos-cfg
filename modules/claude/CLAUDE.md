# File references

Every reference to a file or code location in prose must be a clickable markdown link whose visible text is short and whose target is an absolute `file://` URL with a `#L<line>` fragment:

- `[modules/tmux.nix:12](file:///abs/path/to/repo/modules/tmux.nix#L12)`
- Link text is the repo-relative path (plus `:<line>` when relevant), or just the basename when the path is already clear from context
- Omit the fragment when there is no specific line

This overrides the default `file_path:line_number` convention. Never show an absolute path as visible text, never wrap file references in backticks, and never write a bare path instead of a link.
# Code

## Code comments

I never ever ever want you to write comments in my code unless explicitly asked. If you violate this requirement, you are going against my express wishes and I will probably end up deleting them. It does not matter how complex the code you are writing is -- do not write comments in the code unless I request it.

If I ask for comments or explanations in an area:

- keep them terse and explain only subjects I wanted explanation on
- do not use syntax or details that are duplicative with the languages type system
    - this means no JSDoc @links!
- Never include ticket numbers in comments or deprecation warnings

## Iterating & Development

- Prefer to solidify basic functionality, services, dataflow, etc *before* running tests for net-new functionality

# Git & Pull requests

## Pull requests

- Never create one for me unless explicitly asked

## Branch conventions:

- Prefix branches with `u/kwkaiser/<topic>-<branch iter>`. For example:
    - `u/kwkaiser/foo-setup-1`
    - `u/kwkaiser/foo-setup-2`
- Prefer to have consistent prefix across stacked branches

## Commit messages & PR titles

For commit messages and PR titles, prefer to format with:

- `feat`, `fix`, `perf` deploy; `refactor`, `chore`, `docs`, `test`, `ci`, `build`, `style` don't
- Use `fix`/`feat` for anything that needs to ship, even if refactor-shaped. Never use `!`/`BREAKING CHANGE` unless asked
- Branch commits are parsed too (merge commits), so keep their types consistent with the PR title

## Pull request descriptions

When writing pull request descriptions, use the following format to indicate all generated content:

```
> [!NOTE]
> Generated summary:
> 
> [<Ticket name or ID>](<link to ticket>)
> foo
> bar
>
> **Demos**:
> - [description](<link to recording if applicable>) @ `<commit tag>`
```

Replacing the ticket details if available (skip if not) and `foo`, `bar` with actual content. This provides important clarity to coworkers. 

CRUCIAL: NEVER provide your own generated description outside of that generated summary block. That means that you should not put ANY text outside the `>` backticks, nor edit existing text without explicit approval. NEVER modify description outside of the `[!NOTE]` block, as this is human-written. The means any time you're asked to modify the annotated text, you MUST retrieve the latest version of that text, which may have been edited since you last saw it.

Other rules:

- Only attach demos to the description if one is EXPLICITLY provided to the session
- If demos are re-created, leave the original demo link in place and list the new one with respect to commit
- If you find additions outside of the `Generated content` block, leave them alone
- Do not use unbulleted descriptions of changes
- When describing branch changes for pull requests, use a maximum of 3 bullet points to describe changes. Each bullet should be less than 100 characters
- Reference other pull requests this pull request may have up / downstream for stacked PRs / base branches
- Never include description of "verification steps" that are duplicative with basic CI. Only include description of verification steps if we did something separate from what CI is doing.
- NEVER include "Generated with claude code"
- Do not include any other sections unless explicitly asked 

## Pull request comments & feedback

- NEVER reply to pull comments without explicit approval from myself
- When you reply, use an equivalent reply format to distinguish a generated response from my own responses:
- Continue following the same conventions around brevity (i.e. do not spam out the commenter in the reply)

```
> [!NOTE]
> Generated response:
> 
> <content>
```
