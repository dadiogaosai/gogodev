---
name: gogodev-setup
description: Set up the gogodev OpenSpec workflow in Codex, including OpenSpec, Go tooling, and optional review tooling.
---

# Set up gogodev for Codex

Check `openspec --version`. If it is missing, offer to install `@fission-ai/openspec` using npm. Check for `openspec/config.yaml` in the target project. If absent, offer `openspec init --tools codex`; check `openspec init --help` if this CLI version uses different syntax. Do not run initialization in the gogodev plugin source repo unless that is the user's target project.

For Go projects, check `go` and `gopls`. If Go is present and gopls is missing, offer `go install golang.org/x/tools/gopls@latest`, then verify it is on `PATH`. Explain the GOPATH/bin fix if needed. The `go-semantic-search` skill provides the Go search procedure.

For the optional `loop` execution mode, check `ocr`. If missing, offer `npm install -g @alibaba-group/open-code-review`. The user configures its provider and model with `ocr config provider` and `ocr config model`; never request or store an API key in plugin files.

Report each check as present, installed, or pending, and give the next actionable step. Codex skill workflows are bundled with this plugin, so no Claude marketplace dependency installation is needed.
