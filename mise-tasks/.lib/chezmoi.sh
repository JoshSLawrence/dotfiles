#!/usr/bin/env bash
# Shared chezmoi wrapper for the lint and test tasks. Source it; do not
# execute it (non-executable on purpose, see common.sh).
#
# Every invocation is confined to one scratch directory so a task can never
# read or write the real chezmoi config, state or $HOME.

[[ -n "${_CHEZMOI_LIB_LOADED:-}" ]] && return 0
_CHEZMOI_LIB_LOADED=1

# cz_init SCRATCH_DIR -> point every chezmoi path at SCRATCH_DIR. The source
# is the repo root so .chezmoiroot selects home/, exactly like a real clone.
cz_init() {
  CZ_DIR="$1"
  CZ_DEST="$CZ_DIR/home"
  mkdir -p "$CZ_DEST"
}

# cz ARGS... -> chezmoi with the scratch config, destination, cache and state.
# --persistent-state keeps chezmoi's boltdb out of the real config dir.
cz() {
  chezmoi \
    --source "$(project_root)" \
    --destination "$CZ_DEST" \
    --config "$CZ_DIR/chezmoi.toml" \
    --cache "$CZ_DIR/cache" \
    --persistent-state "$CZ_DIR/state.boltdb" \
    "$@"
}
