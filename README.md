# Welcome

[![CI][ci-badge]][ci-workflow]

[ci-workflow]:
  https://github.com/JoshSLawrence/dotfiles/actions/workflows/ci.yml
[ci-badge]:
  https://github.com/JoshSLawrence/dotfiles/actions/workflows/ci.yml/badge.svg

Welcome to my dotfiles repo!

This repo is a massive WIP

The dotfiles are managed with [chezmoi](https://www.chezmoi.io) in symlink
mode: each managed file in `$HOME` is a symlink into this repo, so editing
`~/.zshrc` edits the repo copy. Commit and push from this repo as usual.

## Layout

`.chezmoiroot` points chezmoi at `home/`, which mirrors `$HOME` using
chezmoi's names: `home/dot_zshrc` becomes `~/.zshrc` and
`home/dot_config/k9s` becomes `~/.config/k9s`.

```text
.
├── .chezmoiroot
├── .github                     CI workflow
├── .gitignore
├── .markdownlint-cli2.jsonc
├── .mise                       npm lock for markdownlint
├── .shellcheckrc
├── home
│   ├── .chezmoi.toml.tmpl      questions asked once per machine
│   ├── .chezmoiexternal.toml   nvim
│   ├── .chezmoiignore          paths left alone on purpose
│   ├── .chezmoiscripts         package and tool installs
│   ├── .chezmoitemplates       logging shared by the scripts
│   ├── dot_aliases
│   ├── dot_claude
│   ├── dot_config
│   ├── dot_exports
│   └── dot_zshrc
├── mise-tasks                  lint and test tasks
├── mise.lock
├── mise.toml                   dev tools and tasks
└── README.md
```

## Install on a new machine

Supported platforms are macOS, Linux (Ubuntu) and WSL (Ubuntu). On macOS,
install [Homebrew](https://brew.sh) first.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" \
  init --apply --source "$HOME/source/github/dotfiles" JoshSLawrence
```

This installs chezmoi to `~/.local/bin`, clones this repo to
`~/source/github/dotfiles`, asks the questions below, links the dotfiles and
runs the install scripts. Open a new shell when it finishes. mise then keeps
chezmoi up to date, so the `~/.local/bin` copy is only the bootstrap.

To do it in steps, run `chezmoi init` before `chezmoi apply`: the templates
need the config that `init` generates.

Each question is asked once per machine. The answers stay in
`~/.config/chezmoi/chezmoi.toml`, never in this repo. To change one, delete
its key from that file and run `chezmoi init`.

| Question                             | Asked on      | Default        |
| ------------------------------------ | ------------- | -------------- |
| Does this machine have a desktop?    | Linux         | if display set |
| Git `user.name` and `user.email`     | all           | empty: not set |
| Use Git Credential Manager (Windows) | WSL           | no             |
| Separate Azure DevOps credentials    | WSL, with GCM | no             |

### GitHub token for mise

mise reads a GitHub token from `gh` (`credential_command` in
`home/dot_config/mise/config.toml`), so its GitHub API calls are not rate
limited and no token sits in an environment variable. Run `gh auth login`
once per machine; new shells warn when `gh` is missing or logged out.

### Tool versions

`home/dot_config/mise/mise.lock` pins the exact version of every tool in
`config.toml`, `"latest"` included, with checksums for Linux (x64 and arm64),
macOS (arm64) and Windows (x64). Every machine installs the same versions.
The dependency locks of npm and pypi tools sit beside it in `.mise/locks`,
which chezmoi links into place as a whole directory.

Upgrade on any machine, then commit the lock with any new `.mise/locks`
entries:

```bash
mise upgrade
git -C ~/source/github/dotfiles add home/dot_config/mise
```

Other machines pick the versions up with `chezmoi update`, which reruns
`mise install` when the lock changes. A tool missing on one platform is
limited with `os = [...]` in `config.toml`, so `mise install` skips it there.

### .NET

mise owns `dotnet`. A machine set up with the old `setup.sh` has the SDK in
`~/.dotnet`. After `chezmoi apply`, open a new shell and run this once there:

```bash
mise uninstall dotnet --all && env -u DOTNET_ROOT mise install
```

Use a new shell because one opened before the switch still exports
`DOTNET_ROOT=~/.dotnet`, and mise would reinstall into that folder.

mise installs into `$DOTNET_ROOT` when it is set, so installs made while the
old `DOTNET_ROOT=$HOME/.dotnet` was exported live in `~/.dotnet`. This repo no
longer sets it. `~/.dotnet/tools` stays on `PATH` for `dotnet tool install -g`.

## Day to day

Edits to tracked files need no command: the file in `$HOME` is the repo
file.

| To                             | Run                                   |
| ------------------------------ | ------------------------------------- |
| Pull from GitHub and apply     | `chezmoi update`                      |
| Apply local repo changes       | `chezmoi apply`                       |
| List untracked config          | `chezmoi unmanaged ~/.config`         |
| Track a new file or directory  | `chezmoi add <path> && chezmoi apply` |
| See what differs from the repo | `chezmoi status`                      |
| Update nvim                    | `chezmoi apply --refresh-externals`   |

To stop `chezmoi unmanaged` from listing something you don't want to track,
add it to `home/.chezmoiignore`.

Some apps keep tokens next to their config (`gh` is one). Never `chezmoi add`
a whole directory of such an app: add single files, and run `git diff` before
committing.

`~/.config/nvim` is a clone of
[JoshSLawrence/nvim](https://github.com/JoshSLawrence/nvim): commit and push
from there. A new clone uses the https URL; to push over SSH, run:

```bash
git -C ~/.config/nvim remote set-url --push origin \
  git@github.com:JoshSLawrence/nvim.git
```

`~/.exports_ignored` is sourced by `~/.exports` if it exists. Put
machine-local exports there; it is not tracked. It loads into every shell, so
don't put `MISE_GITHUB_TOKEN` in it (that overrides the `gh`-based
`credential_command`) or broad cloud credentials (prefer a per-project mise
env).

## What each platform gets

The install scripts in `home/.chezmoiscripts` run after the dotfiles are
linked, so a failed install never blocks the links. Package and mise installs
run again when their list changes.

| Step                               | macOS | Linux   | WSL |
| ---------------------------------- | ----- | ------- | --- |
| OS packages (Homebrew or apt)      | yes   | yes     | yes |
| X11 clipboard and session packages | no    | desktop | no  |
| JetBrains Mono Nerd Font           | cask  | desktop | no  |
| mise, then the tools in its config | yes   | yes     | yes |
| zsh as the login shell             | no    | yes     | yes |
| Git identity (if given at init)    | yes   | yes     | yes |
| Git Credential Manager (if chosen) | no    | no      | yes |

Every dotfile is linked on every platform, except Ghostty's config, which
is skipped where there is no desktop (WSL, or Linux without one).

## Theming (automatic light/dark)

The terminal follows the OS light/dark setting. Dark uses Tokyonight (with
Catppuccin Mocha where no Tokyonight variant exists); light uses Tokyonight Day
for Ghostty/Neovim and Catppuccin Latte everywhere else.

Ghostty, Neovim, and herdr follow the OS appearance natively and switch live
(Ghostty reports it via OSC 2031; herdr and Neovim react). Tools that can only
read their theme at startup pick it from `~/.config/theme/theme-detect.sh` when
a shell starts. That detector is cross-platform: macOS (`AppleInterfaceStyle`),
WSL (the Windows registry), and Linux desktops (`gsettings`). No background
daemon is involved.

How each tool reacts:

| Tool       | Dark              | Light             | Updates          |
| ---------- | ----------------- | ----------------- | ---------------- |
| Ghostty    | TokyoNight Night  | TokyoNight Day    | live (native)    |
| Neovim     | tokyonight-night  | tokyonight-day    | live (plugin)    |
| herdr      | tokyo-night       | catppuccin-latte  | live (native)    |
| oh-my-posh | tokyonight-night  | Catppuccin Latte  | next shell       |
| lazygit    | Tokyonight        | Catppuccin Latte  | next launch      |
| btop       | Tokyo Night       | Catppuccin Latte  | next launch      |
| k9s        | Catppuccin Mocha  | Catppuccin Latte  | next launch      |

Use the `theme` command to override the shell-driven tools (prompt, lazygit,
btop, k9s): `theme light`, `theme dark`, `theme auto` (follow the OS again),
or `theme status`. Ghostty, Neovim, and herdr always follow the OS directly.

Herdr: only `~/.config/herdr/config.toml` is tracked. The rest of
`~/.config/herdr` (sessions, sockets, logs) is a normal local directory,
listed in `home/.chezmoiignore`.

## Development

The dev tools and checks live in `mise.toml` at the repo root, outside `home/`
so chezmoi never manages them. CI runs the same tasks.

```bash
mise trust
mise run lint
mise run test
```

`lint` checks the shell files, renders the install scripts for five machine
types, lints markdown and lints the workflow. `test` applies the dotfiles into
a throwaway home directory and checks the result; it clones nvim, so it needs
network access. Neither touches your real `$HOME`.

Commit authors must be on the allowlist: my personal and GitHub noreply
identities, plus the GitHub Actions and Dependabot bots. The list is in
`mise-tasks/check/commit-email`. CI fails a pull request otherwise
(`mise run check:commit-email <base> <head>` runs the same check locally). To
fix a branch, set `user.email` for this repo and run:

```bash
git rebase --exec 'git commit --amend --no-edit --reset-author' origin/main
```

## Agent instructions

`home/dot_claude/CLAUDE.md` holds global agent instructions and becomes
`~/.claude/CLAUDE.md`. The rest of `~/.claude` (sessions, history,
credentials, caches) stays local and untracked. OpenCode's
`~/.config/opencode/AGENTS.md` is a symlink to `../../.claude/CLAUDE.md`
(from `home/dot_config/opencode/symlink_AGENTS.md`), so both tools share one
copy.

## Symlink mode notes

- `theme-detect.sh` is linked like any other file and runs because the repo
  stores it as executable (git mode `100755`). Keep that bit if you replace
  the file. chezmoi's `executable_` prefix would copy it instead of linking
  it.
- Some apps save config by writing a new file over the old one, which
  replaces the symlink with a plain file. `chezmoi status` then shows the
  file as `MM`. To keep the app's change, run
  `chezmoi add <file> && chezmoi apply <file>`. To throw it away, run
  `chezmoi apply --force <file>`.
- `chezmoi forget <file>` deletes the repo copy, which leaves a broken
  symlink in `$HOME`. To stop tracking a file but keep it, turn the symlink
  back into a plain file first:
  `cp <file> <file>.tmp && mv <file>.tmp <file> && chezmoi forget <file>`.
- Removing or renaming a file in the repo likewise leaves a dead link in
  `$HOME`. Find them with the command below (it only matches links into
  this repo), and delete the ones you no longer want with `rm`.

  ```bash
  find ~ -maxdepth 4 -type l -lname "$HOME/source/github/dotfiles/*" \
    ! -exec test -e {} \; -print
  ```
