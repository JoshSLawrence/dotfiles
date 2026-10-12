# Welcome

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

### .NET

mise owns `dotnet`. A machine set up with the old `setup.sh` has the SDK in
`~/.dotnet`; run this once there:

```bash
mise uninstall dotnet --all && mise install
```

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
from there.

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

<!-- markdownlint-disable MD013 -->

| Tool       | Dark              | Light             | Updates          |
| ---------- | ----------------- | ----------------- | ---------------- |
| Ghostty    | TokyoNight Night  | TokyoNight Day    | live (native)    |
| Neovim     | tokyonight-night  | tokyonight-day    | live (plugin)    |
| herdr      | tokyo-night       | catppuccin-latte  | live (native)    |
| oh-my-posh | tokyonight-night  | Catppuccin Latte  | next shell       |
| lazygit    | Tokyonight        | Catppuccin Latte  | next launch      |
| btop       | Tokyo Night       | Catppuccin Latte  | next launch      |
| k9s        | Catppuccin Mocha  | Catppuccin Latte  | next launch      |

<!-- markdownlint-disable-next-line MD013 -->

Use the `theme` command to override the shell-driven tools (prompt, lazygit,
btop, k9s): `theme light`, `theme dark`, `theme auto` (follow the OS again),
or `theme status`. Ghostty, Neovim, and herdr always follow the OS directly.

Herdr: only `~/.config/herdr/config.toml` is tracked. The rest of
`~/.config/herdr` (sessions, sockets, logs) is a normal local directory,
listed in `home/.chezmoiignore`.

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
  `$HOME`. Find them with
  `find ~ ~/.config ~/.claude -maxdepth 3 -type l ! -exec test -e {} \; -print`
  and delete the ones you no longer want with `rm`.
