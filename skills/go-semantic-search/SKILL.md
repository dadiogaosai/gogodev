---
name: go-semantic-search
description: Use when navigating Go code — finding where a symbol is defined, who references it, what implements an interface, or what a package exports. Prefer gopls over grep for these; grep gives name-collision noise and misses interface/embedding relationships.
---

# Go semantic search with gopls

In Go projects (a `go.mod` is present), symbol questions get compiler-grade answers from gopls. Grep approximates them: it can't tell two symbols with the same name apart, and it cannot see interface satisfaction or embedding at all. A PreToolUse hook in this plugin will deny symbol-shaped Grep calls in Go projects — this skill is the tool you're being pointed to.

If `gopls` is not on PATH, suggest `/gogodev:setup` (it installs gopls when a Go toolchain exists).

## The two-step workflow

gopls queries take a **position** (`file.go:line:col`), not a name. So:

1. **Find the symbol's position by name:**
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

Plain-text content: log messages, string literals, comments, TODO/FIXME markers, config keys, build tags. Don't detour those through gopls — it has no answer for them. If the hook denies a Grep that was genuinely textual, rephrase the pattern to look like text (include surrounding words or quotes).

## Accuracy notes

- Run gopls from the module root (where `go.mod` lives) so the whole workspace loads.
- First query in a large module is slow (type-checking); subsequent ones in the same invocation are not cached — batch questions into as few queries as possible.
- If gopls errors on a broken build, fix the compile error first or fall back to grep *explicitly noting results are approximate*.
