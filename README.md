# Welcome

Welcome to my dotfiles repo!

This repo is a massive WIP

## Usage

To install my dotfiles and all tools/programs

```bash
git clone "https://github.com/joshslawrence/dotfiles"
cd dotfiles
chmod +x setup.sh
bash setup.sh full
```

To install my dotfiles only (omit `full` when running the shell script)

```bash
git clone "https://github.com/joshslawrence/dotfiles"
cd dotfiles
chmod +x setup.sh
bash setup.sh
```

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
| k9s        | Catppuccin Mocha  | Catppuccin Latte  | next launch      |

<!-- markdownlint-disable-next-line MD013 -->

Use the `theme` command to override the shell-driven tools (prompt, lazygit,
k9s): `theme light`, `theme dark`, `theme auto` (follow the OS again), or
`theme status`. Ghostty, Neovim, and herdr always follow the OS directly.

Herdr is special-cased in `setup.sh`: only `~/.config/herdr/config.toml` is
symlinked. The rest of `~/.config/herdr` stays local so live sessions, sockets,
logs, and session state are preserved.
