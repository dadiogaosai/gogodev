---
description: One-time setup — install Matt Pocock's skills plugin and initialize OpenSpec in this repo
---

Set up the dependencies that `/gogodev:propose` and `/gogodev:apply` rely on. Run each check, fix what's missing (with the user's consent for anything that installs software), and report a checklist at the end.

## Check 1: Matt Pocock's skills plugin

Check whether the `mattpocock-skills` plugin is installed:

```bash
claude plugin list 2>/dev/null | grep -i mattpocock
```

If missing, install it (user-scope, so it follows you across repos):

```bash
claude plugin marketplace add mattpocock/skills
claude plugin install mattpocock-skills@mattpocock
```

If the marketplace already exists, `marketplace add` may error harmlessly — continue to the install step.

Do the same for JetBrains' modern Go guidelines plugin (part of this plugin's Go layer):

```bash
claude plugin marketplace add JetBrains/go-modern-guidelines
claude plugin install modern-go-guidelines@goland-claude-marketplace
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

## Report

Print a checklist of the four dependencies with pass/fixed/skipped status.

If anything was installed in Check 1, tell the user: **restart Claude Code** — newly installed plugins (and their skills) only load on the next session, so `/gogodev:propose` will not find `grill-me` until then.
