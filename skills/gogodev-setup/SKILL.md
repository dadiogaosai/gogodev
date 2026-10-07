---
name: gogodev-setup
description: Set up the gogodev OpenSpec workflow in Codex, including OpenSpec, Go tooling, and optional review tooling.
---

# Set up gogodev for Codex

Check `openspec --version`. If it is missing, offer to install `@fission-ai/openspec` using npm. Check for `openspec/config.yaml` in the target project. If absent, offer `openspec init --tools codex`; check `openspec init --help` if this CLI version uses different syntax. Do not run initialization in the gogodev plugin source repo unless that is the user's target project.

For Matt Pocock's original guidance, check whether `grilling`, `tdd`, `implement`, and `code-review` are available as Codex skills. If any are missing, offer `npx skills@latest add mattpocock/skills` in the target project and have the user select Codex and those skills. Include `to-spec` and `to-tickets` if they want the upstream synthesis and slicing guidance too. Matt does not currently publish a native Codex plugin. Gogodev uses the upstream interview and TDD skills where their behavior fits, and adapts the other guidance to keep OpenSpec as the artifact destination and task ledger. Start a new Codex session after installation.

For Go projects, check `go` and `gopls`. If Go is present and gopls is missing, offer `go install golang.org/x/tools/gopls@latest`, then verify it is on `PATH`. Explain the GOPATH/bin fix if needed. The `go-semantic-search` skill provides the Go search procedure.

For Go projects, check whether JetBrains' `use-modern-go` skill is available. If it is missing, offer to install the Codex plugin with `codex plugin marketplace add JetBrains/go-modern-guidelines` and `codex plugin add modern-go-guidelines@goland-codex-marketplace`. Start a new Codex session after installation so the skill is loaded. This plugin is maintained by JetBrains and should be installed from their marketplace rather than copied into gogodev.

For the optional `loop` execution mode, check `ocr`. If missing, offer `npm install -g @alibaba-group/open-code-review`. OCR-managed review needs a configured provider and model (`ocr config provider`, `ocr config model`, then `ocr llm test`); never request or store an API key in plugin files. The optional Codex review plugin can be installed with `codex plugin marketplace add alibaba/open-code-review` and `codex plugin add open-code-review-codex@open-code-review`. Gogodev's loop calls the CLI directly so the review output remains available to its findings cycle.

Ponytail's full Codex plugin is optional: `codex plugin marketplace add DietrichGebert/ponytail` and `codex plugin add ponytail@ponytail`. Its lifecycle hooks need user trust through `/hooks` and a new Codex session. Gogodev embeds the minimal-code ladder in `gogodev-apply`, so the loop works without those hooks; install the plugin if the user wants Ponytail's full behavior across Codex tasks.

Report each check as present, installed, or pending, and give the next actionable step. Gogodev's OpenSpec orchestration is bundled here; Matt's methods, JetBrains' Go guidance, Ponytail's full plugin, and OCR's review plugin remain upstream installations.
