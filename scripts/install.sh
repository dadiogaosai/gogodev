#!/usr/bin/env bash
# Terminal counterpart to /gogodev:setup: installs the dependencies that
# /gogodev:propose and /gogodev:apply rely on, skipping anything already present.
set -euo pipefail

STATUS_MATTPOCOCK="skipped"
STATUS_MODERN_GO="skipped"
STATUS_OPENSPEC="skipped"
STATUS_GOPLS="skipped"

log() { printf '\n== %s ==\n' "$1"; }

has_plugin() {
  claude plugin list 2>/dev/null | grep -qi "$1"
}

log "Matt Pocock's skills plugin"
if has_plugin "mattpocock-skills"; then
  echo "already installed"
  STATUS_MATTPOCOCK="present"
else
  claude plugin marketplace add mattpocock/skills || true
  claude plugin install mattpocock-skills@mattpocock
  STATUS_MATTPOCOCK="installed"
fi

log "JetBrains modern-go-guidelines plugin"
if has_plugin "modern-go-guidelines"; then
  echo "already installed"
  STATUS_MODERN_GO="present"
else
  claude plugin marketplace add JetBrains/go-modern-guidelines || true
  claude plugin install modern-go-guidelines@goland-claude-marketplace
  STATUS_MODERN_GO="installed"
fi

log "OpenSpec CLI"
if command -v openspec >/dev/null 2>&1; then
  echo "already installed ($(openspec --version 2>/dev/null))"
  STATUS_OPENSPEC="present"
else
  npm install -g @fission-ai/openspec@latest
  STATUS_OPENSPEC="installed"
fi

log "gopls"
if ! command -v go >/dev/null 2>&1; then
  echo "no Go toolchain found — skipping (not needed outside Go projects)"
  STATUS_GOPLS="skipped: no Go toolchain"
elif command -v gopls >/dev/null 2>&1; then
  echo "already installed"
  STATUS_GOPLS="present"
else
  go install golang.org/x/tools/gopls@latest
  if command -v gopls >/dev/null 2>&1; then
    STATUS_GOPLS="installed"
  else
    GOBIN="$(go env GOPATH)/bin"
    echo "installed, but not on PATH — add this to your shell profile:"
    echo "  export PATH=\"${GOBIN}:\$PATH\""
    STATUS_GOPLS="installed (PATH not updated)"
  fi
fi

log "Summary"
printf '%-28s %s\n' "mattpocock-skills:" "$STATUS_MATTPOCOCK"
printf '%-28s %s\n' "modern-go-guidelines:" "$STATUS_MODERN_GO"
printf '%-28s %s\n' "openspec CLI:" "$STATUS_OPENSPEC"
printf '%-28s %s\n' "gopls:" "$STATUS_GOPLS"

if [[ "$STATUS_MATTPOCOCK" == "installed" || "$STATUS_MODERN_GO" == "installed" ]]; then
  echo
  echo "Restart Claude Code — newly installed plugins only load on the next session."
fi

echo
echo "Next: in each repo where you'll use gogodev, run 'openspec init --tools claude' (or /gogodev:setup) to initialize OpenSpec."
