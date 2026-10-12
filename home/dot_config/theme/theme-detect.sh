#!/usr/bin/env bash
#
# theme-detect.sh - Print the current system appearance as "light" or "dark".
#
# Works across the platforms this dotfiles repo targets:
#   - macOS      : reads AppleInterfaceStyle
#   - WSL        : reads the Windows apps theme from the registry
#   - Linux (DE) : reads the GNOME/freedesktop color-scheme
#
# A manual override (see the `theme` function in .aliases) always wins so you
# can pin a mode regardless of the OS setting. Falls back to "dark" when the
# appearance cannot be determined, matching the repo's default look.

set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/theme"
override_file="$state_dir/override"

# Manual override wins over OS detection.
if [[ -f "$override_file" ]]; then
    override="$(cat "$override_file" 2>/dev/null || true)"
    case "$override" in
        light | dark)
            printf '%s\n' "$override"
            exit 0
            ;;
    esac
fi

is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] && return 0
    grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

case "$(uname -s)" in
    Darwin)
        # AppleInterfaceStyle is "Dark" in dark mode and absent in light mode.
        if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
            printf 'dark\n'
        else
            printf 'light\n'
        fi
        ;;
    Linux)
        if is_wsl; then
            # AppsUseLightTheme: 0x0 = dark, 0x1 = light.
            reg_path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
            value="$(reg.exe query "$reg_path" /v AppsUseLightTheme 2>/dev/null \
                | tr -d '\r' | awk '/AppsUseLightTheme/ {print $NF}')"
            if [[ "$value" == "0x0" ]]; then
                printf 'dark\n'
            else
                printf 'light\n'
            fi
        else
            scheme=""
            if command -v gsettings >/dev/null 2>&1; then
                scheme="$(gsettings get org.gnome.desktop.interface color-scheme \
                    2>/dev/null | tr -d "'")"
            fi
            case "$scheme" in
                *prefer-dark*) printf 'dark\n' ;;
                *prefer-light*) printf 'light\n' ;;
                *) printf 'dark\n' ;;
            esac
        fi
        ;;
    *)
        printf 'dark\n'
        ;;
esac
