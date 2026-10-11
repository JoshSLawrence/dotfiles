# Global Agent Guidelines

Universal conventions and lessons learned that apply across all repositories.

## Maintaining This File

When you learn something important during a session (e.g., a gotcha,
convention, or correction), **add it to this file** so future sessions retain
the knowledge. Guidelines:

- **Only add project-agnostic learnings** — project-specific lessons go in that
  repo's own CLAUDE.md
- **Only add high-level learnings** — avoid low-value details
- **Ask the user** when adding to this file
- Keep entries concise and actionable

## Formatting & Style

### Directory Trees

Use `text` as the code block language. Sort entries **lexically**: dotfiles
first (sorted among themselves, ignoring the dot), then everything else
alphabetically (case-insensitive).

### Keep Docs in Sync

When information appears in multiple places, update all copies in the same
change. Don't let documentation drift apart.

### Markdown Portability

- `> [!NOTE]` / `> [!IMPORTANT]` is GitHub-only. Use `> **Note:** ...` instead
- `<details>`/`<summary>` is not universally supported
- Separate paragraphs with blank lines, not trailing whitespace

### Markdown Line Length

Keep markdown files within 80 columns. For unwrappable content (tables, URLs),
disable the linter for that section with `<!-- markdownlint-disable MD013 -->`.
Agent instruction files (`CLAUDE.md`, `AGENTS.md`) never get disable comments:
exclude them in the repository's linter config instead.

### Markdown Tables

Tables should be readable in raw markdown. Avoid wrapping lines in the middle of
a table row. Columns should be aligned with spaces, not tabs.

When realigning tables with a script, skip fenced code blocks: a line starting
with `|` (KQL, shell pipes) is not a table row. Diff code blocks before and
after; markdownlint won't catch a query mangled into a table.

### Generated Files Stay Generated

If a file is auto-generated (e.g., README from terraform-docs), edit the source
inputs and regenerate — don't hand-edit the output.

### Keep Code Blocks Copy-Paste Friendly

Put explanations outside the block, not as inline comments that break
copy-paste.

## Code Quality

### Comments: Explain "Why" Not "What"

The code shows *what* it does; comments should explain *why* it does it —
intent, edge cases, non-obvious reasons for a choice. Don't narrate the code.

### Follow Existing Patterns

When contributing to an established codebase, match the existing style and
patterns even if you'd do it differently in a greenfield project. Consistency
trumps personal preference.

### Make Errors Actionable

Error messages should tell the user what went wrong *and* suggest what to do
about it. "Connection failed" is less useful than "Connection failed: check
that VPN is connected and retry."

### Prefer Editing Over Creating

When adding functionality, look for existing files or functions to extend
before creating new ones. Reduces fragmentation and keeps related logic
together.

### CLAUDE.md vs AGENTS.md

Respect existing project conventions. However, if there is an opportunity for
a rules file, create a `CLAUDE.md` and symlink `AGENTS.md` to it rather than
duplicating content.

## Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Always `set -euo pipefail` at the top
- Run `chmod +x` on new scripts

### Log Every Significant Step

Pipeline/script logs should tell a clear story someone can follow without
reading the source. Log before operations, warn for non-fatal issues, error
before failures. Create helper functions for color-coded logging, e.g.
`log_info`, `log_warn`, `log_error`.

### Temporarily Disable errexit to Handle Errors Gracefully

When you are aware of and can address/handle an error yourself instead of
immediately exiting: given the `set -euo pipefail` behavior, you should
temporarily disable exit-on-error, handle the error, then re-enable
exit-on-error.

### Isolate Scripts That Create Git Repos

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

## CI/CD

### Job Timeouts Must Exceed Tool Timeouts

Set a CI job's timeout above the longest timeout of the tool it runs (e.g.
OpenTofu provider resource timeouts, often 60 minutes). If the runner is
killed first, the tool can't fail cleanly: state stays locked and
half-applied changes go unrecorded. Comment the reason next to the setting.

## Agent Workflow

**Ask upfront, don't assume.** At the start of each new ask that is
multi-step or non-trivial, ask whether to use the orchestrator pattern below
or work directly in the main session. Don't default to either. Skip the
question for trivial asks (a quick edit, a lookup, a one-line fix) and just
work directly. Honor the answer for that ask only; it doesn't carry over to
the next one unless the user says so.

When the user opts in, the main session orchestrates and delegates to agents:

| Role         | Model            | Does                                                   |
| ------------ | ---------------- | ------------------------------------------------------ |
| Orchestrator | the main session | Plans, briefs, verifies, commits, pushes, merges       |
| Designer     | Opus             | Investigates and writes a design file; changes nothing |
| Reviewer     | Opus             | Reviews one domain read-only; reports findings         |
| Worker       | Sonnet           | Implements a design or a review's findings             |

- **Design, implement, review.** For anything non-trivial, an Opus agent
  designs first and writes the design to a file outside the repo. A Sonnet
  agent implements it, and an Opus agent reviews the result.
- **The same reviewer re-reviews** each round of fixes until it reports clean.
  Prefer a fresh agent for a new, large piece of work, so it starts without
  stale context.
- **Brief precisely.** Give each agent the files to read, the decisions
  already made, what it may and may not run, and exactly what to report.
- **Verify agents' claims** before acting on them: re-run their tests, read
  their diffs, check anything destructive read-only. An agent's report is
  not proof.
- **Ask the user** for decisions that are theirs (scope, trade-offs, access),
  with a recommendation, and record durable decisions in memory.
- **Agents never** push, merge, tag, release, apply infrastructure or change
  settings and config; the orchestrator does those after review and green
  CI. Infrastructure applies only through CI, with the user's approval.
- **Agents work in their own git worktree** when the user may be editing the
  main checkout, stage only the files they changed, and commit with the
  user's normal identity and signing.
