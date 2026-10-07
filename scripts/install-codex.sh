#!/usr/bin/env bash
# Standalone Codex installer. Works from a downloaded copy or a checkout;
# leaves OpenSpec project initialization to the user.
set -euo pipefail

log() { printf '\n== %s ==\n' "$1"; }

if ! command -v codex >/dev/null 2>&1; then
  echo "Codex CLI is required. Install Codex, then rerun this script." >&2
  exit 1
fi

# The CLI's human-readable list has one row per plugin, with its install status
# in the second column. Match the full selector so similarly named plugins do
# not count as installed.
PLUGIN_LIST="$(codex plugin list 2>/dev/null)"
has_plugin() {
  awk -v plugin="$1" '$1 == plugin && $2 == "installed" { found = 1 } END { exit !found }' <<< "$PLUGIN_LIST"
}

MARKETPLACE_LIST="$(codex plugin marketplace list 2>/dev/null)"
has_marketplace() {
  awk -v marketplace="$1" '$1 == marketplace { found = 1 } END { exit !found }' <<< "$MARKETPLACE_LIST"
}

install_plugin() {
  local label="$1" selector="$2" marketplace="$3" source="$4"
  log "$label"
  if has_plugin "$selector"; then
    echo "already installed"
    return
  fi
  if ! has_marketplace "$marketplace"; then
    codex plugin marketplace add "$source"
  fi
  codex plugin add "$selector"
  PLUGINS_INSTALLED=1
}

PLUGINS_INSTALLED=0
install_plugin "gogodev plugin" \
  "gogodev@dadiogaosai" \
  "dadiogaosai" "dadiogaosai/gogodev"
install_plugin "JetBrains modern-go-guidelines plugin" \
  "modern-go-guidelines@goland-codex-marketplace" \
  "goland-codex-marketplace" "JetBrains/go-modern-guidelines"
install_plugin "Alibaba OpenCodeReview plugin" \
  "open-code-review-codex@open-code-review" \
  "open-code-review" "alibaba/open-code-review"

log "Matt Pocock's Codex skills"
SKILLS_INSTALLED=0
MATT_SKILLS=(grilling tdd implement code-review)
MISSING_SKILLS=()
for skill in "${MATT_SKILLS[@]}"; do
  if [[ ! -f "$HOME/.agents/skills/$skill/SKILL.md" && \
        ! -f "$HOME/.codex/skills/$skill/SKILL.md" ]]; then
    MISSING_SKILLS+=("$skill")
  fi
done
if (( ${#MISSING_SKILLS[@]} == 0 )); then
  echo "already installed"
else
  if ! command -v npx >/dev/null 2>&1; then
    echo "npx is required to install Matt Pocock's skills." >&2
    exit 1
  fi
  SKILL_ARGS=()
  for skill in "${MISSING_SKILLS[@]}"; do
    SKILL_ARGS+=(--skill "$skill")
  done
  npx --yes skills@latest add mattpocock/skills \
    --global --agent codex --yes "${SKILL_ARGS[@]}"
  SKILLS_INSTALLED=1
  echo "installed: ${MISSING_SKILLS[*]}"
fi

log "OpenSpec CLI"
if command -v openspec >/dev/null 2>&1; then
  echo "already installed ($(openspec --version 2>/dev/null))"
else
  npm install -g @fission-ai/openspec@latest
  echo "installed"
fi

log "gopls"
if ! command -v go >/dev/null 2>&1; then
  echo "no Go toolchain found — skipping (not needed outside Go projects)"
elif command -v gopls >/dev/null 2>&1; then
  echo "already installed"
else
  go install golang.org/x/tools/gopls@latest
  if command -v gopls >/dev/null 2>&1; then
    echo "installed"
  else
    GOBIN="$(go env GOPATH)/bin"
    echo "installed, but not on PATH — add this to your shell profile:"
    echo "  export PATH=\"${GOBIN}:\$PATH\""
  fi
fi

log "ocr CLI (only needed for \$gogodev-apply's loop mode)"
if command -v ocr >/dev/null 2>&1; then
  echo "already installed"
else
  npm install -g @alibaba-group/open-code-review
  echo "installed"
fi
echo "Configure it with 'ocr config provider' and 'ocr config model' before using loop mode."

if (( PLUGINS_INSTALLED || SKILLS_INSTALLED )); then
  echo
  echo "Start a new Codex session to load the installed plugins and skills."
fi
echo
echo "Next: in each repo where you'll use gogodev, run 'openspec init --tools codex' (or \$gogodev-setup)."
