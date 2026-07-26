---
name: go-semantic-search
description: Use when navigating Go code — finding where a symbol is defined, who references it, what implements an interface, or outlining a file's declarations — or when the go-grep-guard hook denies a Grep call.
---

# Go semantic search with gopls

In Go projects (a `go.mod` is present), symbol questions get compiler-grade answers from gopls; grep only approximates them — it can't tell two same-named symbols apart and cannot see interface satisfaction or embedding at all. This plugin's PreToolUse hook denies symbol-shaped Grep calls in Go projects; this skill is the tool it points to.

If `gopls` is not on PATH, suggest `/gogodev:setup` (it installs gopls when a Go toolchain exists).

## The two-step workflow

gopls queries take a **position** (`file.go:line:col`), not a name. So:

1. **Name → position:**
   ```bash
   gopls workspace_symbol 'SymbolName'
   ```
   Returns matches as `path/file.go:line:col-endcol kind SymbolName`. Fuzzy matching works; case hints narrow it.

2. **Query at that position** (line:col from step 1, pointing at the identifier):
   ```bash
   gopls references path/file.go:12:6      # every use, workspace-wide
   gopls definition path/file.go:12:6      # where it's defined
   gopls implementation path/file.go:12:6  # implementations of an interface / interfaces a type satisfies
   ```

## Other useful one-shots

```bash
gopls symbols path/file.go     # outline of one file (all declarations)
gopls check path/file.go       # diagnostics for a file
```

## When grep is still right

Plain-text content: log messages, string literals, comments, TODO/FIXME markers, config keys, build tags — those go straight to Grep; gopls has no answer for them. If the hook denies a genuinely textual search, rephrase the pattern so it reads as text (include surrounding words or quotes).

## Accuracy notes

- Run gopls from the module root (where `go.mod` lives) so the whole workspace loads.
- Every gopls CLI call re-loads and type-checks the workspace from scratch — in a large module each call is slow, so gather your positions and questions up front and make as few calls as possible.
- If gopls errors on a broken build, fix the compile error first, or fall back to grep and state that the results are approximate.
