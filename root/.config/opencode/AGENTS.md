# Global Agent Guidelines

Universal conventions and lessons learned that apply across all repositories.

## Maintaining This File

When you learn something important during a session (e.g., a gotcha, convention, or correction), **add it to this file** so future sessions retain the knowledge. Guidelines:

- **Only add repo-agnostic learnings** — if a lesson only applies to a specific repo (e.g., that repo's architecture, tooling quirks, or conventions), add it to that repo's own AGENTS.md instead
- **Only add high-level, important learnings** — avoid bloating this file with low-value details
- **Ask the user for confirmation** if you're unsure whether something warrants inclusion
- Keep entries concise and actionable

## Formatting & Style

### Directory Trees

Sort directory trees in **lexical (alphabetical) order** within each level: dotfiles first (sorted alphabetically among themselves, ignoring the leading dot), then every other entry alphabetically (case-insensitive). This makes diffs predictable and easier to review.

```
# Good
├── .gitignore
├── .pre-commit-config.yaml
├── scripts/
│   ├── common.sh
│   ├── install-tools.sh
│   └── setup.sh

# Bad (arbitrary order)
├── scripts/
│   ├── setup.sh
│   ├── common.sh
│   └── install-tools.sh
├── .gitignore
├── .pre-commit-config.yaml
```

### Keep Docs in Sync

When information appears in multiple places (e.g., repo structure in README and CONTRIBUTING), update all copies in the same change. Don't let documentation drift apart.

### Markdown Portability

Not all Markdown renderers support the same features. Be aware of your target platform:

- GitHub-only syntax like `> [!NOTE]` / `> [!IMPORTANT]` doesn't render on Azure DevOps, GitLab, or many other platforms. Use a plain blockquote with a bolded lead-in instead: `> **Note:** ...`
- `<details>`/`<summary>` collapsibles are not universally supported
- Separate paragraphs with a blank line rather than relying on trailing whitespace for line breaks

### Generated Files Stay Generated

If a file is auto-generated (e.g., README from terraform-docs, API docs from code comments), edit the source inputs and regenerate — don't hand-edit the generated output.

## Code Quality

### Comments: Explain "Why" Not "What"

The code shows *what* it does; comments should explain *why* it does it — intent, edge cases, non-obvious reasons for a choice. Don't narrate the code.

### Follow Existing Patterns

When contributing to an established codebase, match the existing style and patterns even if you'd do it differently in a greenfield project. Consistency trumps personal preference.

### Make Errors Actionable

Error messages should tell the user what went wrong *and* suggest what to do about it. "Connection failed" is less useful than "Connection failed: check that VPN is connected and retry."

### Prefer Editing Over Creating

When adding functionality, look for existing files or functions to extend before creating new ones. Reduces fragmentation and keeps related logic together.

## Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Always `set -euo pipefail` at the top
- Run `chmod +x` on new scripts

### Log Every Significant Step

Pipeline/script logs should tell a clear story someone can follow without reading the source. Log before operations, warn for non-fatal issues, error before failures.

### Temporarily Disable errexit to Handle Errors Gracefully

When you need to handle an error yourself instead of immediately exiting:

```bash
set +e  # Disable exit-on-error
some_command
exit_code=$?
set -e  # Re-enable exit-on-error

if [ $exit_code -ne 0 ]; then
    echo "Error: some_command failed with exit code: $exit_code" >&2
    exit $exit_code
fi
```

### Split Declare and Assign (SC2155)

`local foo=$(cmd)` always succeeds because `local` returns 0, masking the command's exit code:

```bash
# Good
local foo
foo=$(some_command)

# Bad — local always returns 0, masking the command's exit code
local foo=$(some_command)
```

The same applies to `curl` and other commands where you need to check the exit code:

```bash
local response
response=$(curl ...) || { echo "Error: curl failed" >&2; return 1; }
```

### Trap Overwriting

If a script sets a trap and sources another file that also sets a trap on the same signal, the second overwrites the first. Use trap chaining if needed:

```bash
existing_trap=$(trap -p EXIT | sed "s/trap -- '\(.*\)' EXIT/\1/")
trap "${existing_trap}; my_cleanup" EXIT
```

## Security

- **Never commit secrets, credentials, connection strings, or keys** — not in code, not in default values, not in commit messages, not in PR descriptions
- **If a secret is ever committed, treat it as compromised** — rotating or revoking is not optional just because history could be rewritten. Tell the user immediately so they can rotate it
- **Default to least privilege** — scope permissions as narrowly as actually needed; don't default to broad/wildcard permissions for convenience

## Validating Changes

Run the repo's linting/validation hooks before considering work done — don't just eyeball the diff.

- **If a linter or hook fails, stop and surface it** — don't silently work around it. Explain what failed and why.
- **Never auto-add a suppression** (`# shellcheck disable=...`, `# tflint-ignore:`, `#trivy:ignore:`, `// eslint-disable-next-line`, etc.) to make a hook pass. Only add one if the user explicitly approves after you've explained the finding.
- **Prefer fixing the underlying issue** over suppressing the finding.
