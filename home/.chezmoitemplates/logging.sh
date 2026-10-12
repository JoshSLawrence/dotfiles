# Color-coded logging shared by the run_ scripts. The argument passed to this
# template names the script, so chezmoi's combined output stays readable.
log_info() { printf '\033[0;32m[INFO]\033[0m  {{ . }}: %s\n' "$*"; }
log_warn() { printf '\033[0;33m[WARN]\033[0m  {{ . }}: %s\n' "$*" >&2; }
log_error() { printf '\033[0;31m[ERROR]\033[0m {{ . }}: %s\n' "$*" >&2; }
