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

## Security

- **Never commit secrets, credentials, connection strings, or keys** — not in
  code, not in default values, not in commit messages, not in PR descriptions
- **If a secret is ever committed, treat it as compromised** — rotating or
  revoking is not optional just because history could be rewritten. Tell the
  user immediately so they can rotate it
- **Default to least privilege** — scope permissions as narrowly as actually
  needed; don't default to broad/wildcard permissions for convenience
- **Keep a Defense in Depth mindset** — for all design and execution decisions

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
