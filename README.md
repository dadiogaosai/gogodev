# gogodev

> [!NOTE]
> **Work in progress, and quite personal.** 🌱
> I built this to fit my own day-to-day workflow, so its choices reflect my preferences and setup, and things may still change as I go. You're very welcome to try it, or fork it and shape it to your own taste — just know it isn't (yet) designed as a general-purpose tool. Improvements, bug fixes, and issues are warmly welcome!

**Work Matt Pocock's way, ship OpenSpec artifacts.**

A thin glue plugin for [Claude Code](https://code.claude.com) connecting [Matt Pocock's engineering skills](https://github.com/mattpocock/skills) to the [OpenSpec](https://github.com/Fission-AI/OpenSpec) spec-driven workflow — for when your team expects `openspec/` artifacts, but you'd rather think through grill-me interviews and tdd/implement loops.

The rule that holds it together: **Matt's process, OpenSpec's artifacts.** Everything persistent lives in `openspec/`, indistinguishable from a by-the-book OpenSpec user. The stock `/opsx:*` tooling is never modified.

## What's in the box

- **Proposal flow** — a relentless interview *before* any artifact exists; artifacts written from the interview, not from a one-shot description.
- **Implementation flow** — Matt's `implement`/`tdd` skills driving OpenSpec's `tasks.md`, with the bookkeeping kept honest.
- **Go layer** — gopls-first code search (enforced by a hook), JetBrains' modern Go guidelines, and gopls LSP diagnostics.

## Install

Inside Claude Code:

```
/plugin marketplace add Waniyama/gogodev
/plugin install gogodev@waniyama
```

Or from the terminal:

```bash
claude plugin marketplace add Waniyama/gogodev
claude plugin install gogodev@waniyama
```

Then:

1. Run `/gogodev:setup` once. Dependencies (`mattpocock-skills`, JetBrains' `modern-go-guidelines`) are declared in the manifest, but marketplace resolution can be finicky — setup installs everything explicitly and is the reliable path. It also installs gopls if you have a Go toolchain.
2. Restart Claude Code — commands, skills, and hooks load at session start.
3. In each repo where you'll use it, run `/gogodev:setup` again to initialize OpenSpec (`openspec init`).

To try the plugin from a local clone instead of GitHub, point the marketplace at the checkout: `claude plugin marketplace add /path/to/gogodev`.

## Update

```bash
claude plugin marketplace update waniyama   # refresh the marketplace's view of the repo
claude plugin update gogodev@waniyama       # update the plugin itself
```

Then restart Claude Code to apply. Note that `update` only acts when the version in `plugin.json` has *increased*; for a same-version refresh (e.g. tracking a local clone), reinstall instead:

```bash
claude plugin uninstall gogodev@waniyama && claude plugin install gogodev@waniyama
```

Dependency plugins update independently: `claude plugin update mattpocock-skills@mattpocock` and `claude plugin update modern-go-guidelines@goland-claude-marketplace` — or update everything at once from the `/plugin` menu.

## Commands

| Command | What it does |
| --- | --- |
| `/gogodev:propose <idea>` | Runs a `/grill-me` interview first. Only if the idea survives: `openspec new change`, then `proposal.md` / `design.md` / `tasks.md` written from the interview, validated. A killed idea writes nothing. |
| `/gogodev:capture [name]` | No-interview counterpart for designs that emerged organically in the session (Matt's `to-spec` rules): synthesize the conversation into an OpenSpec change — re-asking nothing, inventing nothing. One permitted check-in: the testing seams. |
| `/gogodev:apply [change]` | Implements an approved change. Asks once per change — `tdd` or `implement`? (recorded in `design.md`) — then works `tasks.md`, ticking checkboxes one at a time. Ends with `/code-review`; suggests archiving (slash command or `openspec archive` CLI, whichever is loaded). |
| `/gogodev:setup` | Installs the dependency plugins, checks the `openspec` CLI, offers `openspec init --tools claude`, installs gopls when a Go toolchain exists. |

Tasks in `tasks.md` are written as **tracer bullets** (Matt's `to-tickets` discipline): vertical slices that are individually demoable, sized to one context window, with blocking edges noted — and expand–contract sequencing for wide refactors.

## Safety net

A model-invocable skill (`grill-before-openspec`) steers even a habitual `/opsx:propose` or a conversational "let's draft a proposal" through the interview first. Advisory rather than guaranteed — `/gogodev:propose` is the deterministic path.

## Go projects: gopls-first search

In repos with a `go.mod`, symbol questions (definitions, references, implementations) must go through gopls, not grep:

- **The teeth** — a PreToolUse hook denies symbol-shaped Grep patterns (CamelCase/mixedCase identifiers, `func X` / `type X` hunts, call searches) and replies with the exact gopls commands instead. Text-shaped searches (strings, spaces, TODO markers, config keys, regex syntax) always pass. No gopls installed → the grep proceeds with a nudge toward `/gogodev:setup`, never a hard block.
- **The map** — the `go-semantic-search` skill: `gopls workspace_symbol` to find a position, then `references` / `definition` / `implementation` at it.
- **The ambient layer** — gopls registered as an LSP server for `.go` files: diagnostics after every edit where gopls exists, gracefully skipped where it doesn't.
- **The style layer** — JetBrains' [modern-go-guidelines](https://github.com/JetBrains/go-modern-guidelines) (`use-modern-go` skill) keeps generated Go idiomatic up to Go 1.26.

## Not wrapped, on purpose

Archiving and spec syncing (`/opsx:archive`, `/opsx:sync`) are stock OpenSpec — they already validate and bookkeep fine. This plugin adds process where OpenSpec is weak (elicitation, execution discipline), not wrappers for what already works.
