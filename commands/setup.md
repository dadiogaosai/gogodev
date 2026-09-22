---
description: One-time setup — install Matt Pocock's skills plugin and initialize OpenSpec in this repo
---

Set up the dependencies that `/gogodev:propose` and `/gogodev:apply` rely on. Run each check, fix what's missing (with the user's consent for anything that installs software), and report a checklist at the end.

## Check 1: Matt Pocock's skills plugin

Check whether the `mattpocock-skills` plugin is installed:

```bash
claude plugin list 2>/dev/null | grep -i mattpocock
```

If missing, install it (user-scope, so it follows you across repos) from Anthropic's official marketplace — pre-added by default, no `marketplace add` needed:

```bash
claude plugin install mattpocock-skills@claude-plugins-official
```

Matt Pocock recommends installing from this official marketplace rather than his own `mattpocock/skills` repo marketplace.

Do the same for JetBrains' modern Go guidelines plugin (part of this plugin's Go layer):

```bash
claude plugin marketplace add JetBrains/go-modern-guidelines
claude plugin install modern-go-guidelines@goland-claude-marketplace
```

Do the same for Alibaba's OpenCodeReview plugin (the second parallel reviewer in `/gogodev:apply`'s `loop` mode):

```bash
claude plugin marketplace add alibaba/open-code-review
claude plugin install open-code-review@open-code-review
```

## Check 2: OpenSpec CLI

```bash
openspec --version
```

If the CLI is missing, ask the user before installing globally:

```bash
npm install -g @fission-ai/openspec@latest
```

## Check 3: OpenSpec initialized in this repo

Look for `openspec/config.yaml` in the repo root. If absent, offer to run:

```bash
openspec init --tools claude
```

This scaffolds `openspec/` and the stock `/opsx:*` commands. It writes into the repo's `.claude/` directory — if this is a shared company repo, remind the user to check what `git status` shows before committing.

## Check 4: gopls (Go projects only)

```bash
command -v gopls || echo missing
```

If gopls is missing:

- **No Go toolchain** (`command -v go` fails) → note "skipped: no Go toolchain" and move on. Do not install Go.
- **Go present** → install and verify:
  ```bash
  go install golang.org/x/tools/gopls@latest
  command -v gopls
  ```
  If the install succeeded but `gopls` still doesn't resolve, `$(go env GOPATH)/bin` is not on PATH — tell the user to add it to their shell profile (classic gotcha with version managers like gobrew) and show the exact line, e.g. `export PATH="$(go env GOPATH)/bin:$PATH"`.

gopls powers this plugin's Go integration: the LSP server registration, the go-semantic-search skill, and the Grep guard hook that enforces semantic search in Go projects.

## Check 5: `ocr` CLI and a configured LLM provider (only needed for `/gogodev:apply`'s `loop` mode)

```bash
command -v ocr || echo missing
```

If missing, ask the user before installing globally:

```bash
npm install -g @alibaba-group/open-code-review
```

`ocr` also needs an LLM provider configured before its first real review — this is interactive and needs an API key, so it cannot be scripted here. If the user hasn't set this up yet, tell them to run, once:

```bash
ocr config provider
ocr config model
```

Note "skipped: `ocr` not configured yet" in the report rather than blocking on it — `loop` mode is opt-in per change, so this only needs to be done before someone actually chooses `loop`.

## Report

Print a checklist of the five dependencies with pass/fixed/skipped status.

If anything was installed in Check 1, tell the user: **restart Claude Code** — newly installed plugins (and their skills) only load on the next session, so `/gogodev:propose` will not find `grilling` until then.
