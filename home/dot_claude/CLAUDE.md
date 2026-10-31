# Global Agent Guidelines

Universal conventions and lessons learned that apply across all repositories.

## Maintaining This File

When you learn something important during a session (e.g., a gotcha,
convention, or correction), **add it to this file** so future sessions retain
the knowledge. Guidelines:

- **Only add project-agnostic learnings** — project-specific lessons go in
  that repo's own CLAUDE.md
- **Only add high-level learnings** — avoid low-value details
- **Ask the user** when adding to this file
- Keep entries concise and actionable
- **Keep the file short** — it loads into every session. Skip anything a
  capable model already does by default; prefer a hook, linter or CI check
  for rules that must always hold

## Worktrees

Use a new git worktree for each logically separate unit of work, so it can't
collide with work in progress by other humans or agents. Work in the main
checkout when the user says to.

## Scope and Ambiguity

- **Do what was asked** — don't add features, refactors or "improvements"
  beyond the request. Mention them instead
- **Ask instead of guessing** when a requirement is ambiguous and a wrong
  guess would be costly to undo. Give a recommendation with the question

## Docs & Commits

### Keep Docs in Sync

When information appears in multiple places, update all copies in the same
change. Don't let documentation drift apart.

### Generated Files Stay Generated

If a file is auto-generated (e.g., README from terraform-docs), edit the source
inputs and regenerate — don't hand-edit the output.

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`,
`fix(scope):`, `refactor!:`) unless the repository uses another convention.

### Branch Names

Branches names should also follow the semantic/conventional model.

## Code Quality

### Make Errors Actionable

Error messages should tell the user what went wrong *and* suggest what to do
about it. "Connection failed" is less useful than "Connection failed: check
that VPN is connected and retry."

### CLAUDE.md vs AGENTS.md

Respect existing project conventions. However, if there is an opportunity for
a rules file, create a `CLAUDE.md` and symlink `AGENTS.md` to it rather than
duplicating content.

## Isolate Throwaway Git Repos

Scripts and tests that create throwaway git repos must first
`unset $(git rev-parse --local-env-vars)`. Run from a git hook, they inherit
`GIT_DIR`/`GIT_INDEX_FILE`, and `git -C <tmp> ...` then writes to the real
repository (this once set `core.bare = true` and a fake identity in a shared
`.git/config`). Before any `git config` or commit, check the temp repo's
`git rev-parse --absolute-git-dir` is inside the temp directory, and pass test
identities with `git -c` rather than writing config.

## Security

- **Never commit secrets, credentials, connection strings, or keys** — not in
  code, not in default values, not in commit messages, not in PR descriptions
- **If a secret is ever committed, treat it as compromised** — rotating or
  revoking is not optional just because history could be rewritten. Tell the
  user immediately so they can rotate it
- **Default to least privilege** — scope permissions as narrowly as actually
  needed; don't default to broad/wildcard permissions for convenience
- **Keep a Defense in Depth mindset** — for all design and execution decisions
- **Never reference an organization in my public GitHub (JoshSLawrence/\*)**
  — no org, team or employer names, their repos, real resource names or
  suffixes, or subscription, tenant or client IDs. That applies to code,
  tests, docs, commit messages, PR titles and bodies, comments and release
  notes. Use generic placeholders (`contoso`, `example`). Grep diffs and
  PR/release text for them before pushing. Repos owned by an organization may
  reference that organization.

## Validating Changes

Run any available tests, linters, hooks, etc. before considering work done —
don't just eyeball the diff. If you have an opportunity to add a test or linter
that will add value, do it. Guidelines:

- **If a linter or hook fails, stop and surface it** — don't silently work
  around it. Explain what failed and why.
- **Never auto-add a suppression** (`# shellcheck disable=...`,
  `# tflint-ignore:`, `#trivy:ignore:`, `// eslint-disable-next-line`, etc.) to
  make a hook pass. Only add one if the user explicitly approves after you've
  explained the finding.
- **Prefer fixing the underlying issue** over suppressing the finding.
- **Never bypass hooks** — no `--no-verify`, `git commit -n` or disabling a
  hook to get a commit or push through.
- **Never weaken tests to get a pass** — don't skip, delete or loosen
  assertions without asking. A failing test is a finding, not an obstacle.

## Agent Workflow

Work directly in the main session by default. Delegate to subagents only when
it pays for itself:

- **Independent parallel work**, e.g. the same change across several repos.
- **Context-heavy searches** where only the conclusion matters.
- **Independent review** of a large change: a code-review command (e.g.
  `/code-review`) or a fresh reviewer agent that had no part in the
  implementation. Re-review each round of fixes until it reports clean.

For large multi-workstream efforts, propose a design/implement/review split
and ask before fanning out.

When delegating:

- **Brief precisely.** Give each agent the files to read, the decisions
  already made, what it may and may not run, and exactly what to report.
- **Verify agents' claims** before acting on them: re-run their tests, read
  their diffs, check anything destructive read-only. An agent's report is
  not proof.
- **Agents never** push, merge, tag, release, apply infrastructure or change
  settings and config; the main session does those after review and green
  CI. Infrastructure applies only through CI, with the user's approval.
- **Agents work in their own git worktree**, stage only the files they
  changed, and commit with the user's normal identity and signing.

**Ask the user** for decisions that are theirs (scope, trade-offs, access),
with a recommendation, and record durable decisions in memory.
