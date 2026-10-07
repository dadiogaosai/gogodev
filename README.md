# gogodev

> [!NOTE]
> **Work in progress, and quite personal.** 🌱
> I built this to fit my own day-to-day workflow, so its choices reflect my preferences and setup, and things may still change as I go. You're very welcome to try it, or fork it and shape it to your own taste — just know it isn't (yet) designed as a general-purpose tool. Improvements, bug fixes, and issues are warmly welcome!

**Work Matt Pocock's way, ship OpenSpec artifacts.**

A thin glue plugin for [Claude Code](https://code.claude.com) and [Codex](https://developers.openai.com/codex) connecting Matt Pocock-style engineering workflows to the [OpenSpec](https://github.com/Fission-AI/OpenSpec) spec-driven workflow — for when your team expects `openspec/` artifacts, but you'd rather think through grilling interviews and tdd/implement loops.

The rule that holds it together: **Matt's process, OpenSpec's artifacts.** Everything persistent lives in `openspec/`, indistinguishable from a by-the-book OpenSpec user. The stock `/opsx:*` tooling is never modified.

## What's in the box

- **Proposal flow** — a relentless interview *before* any artifact exists; artifacts written from the interview, not from a one-shot description.
- **Implementation flow** — Matt's `implement`/`tdd` skills driving OpenSpec's `tasks.md`, with the bookkeeping kept honest. A third, stricter `loop` mode adds mandatory TDD, a lint+typecheck+test gate, a dual code review, and a human-approval gate before a single commit — see below.
- **Go layer** — gopls-first code search (enforced by a hook), JetBrains' modern Go guidelines, and gopls LSP diagnostics.

## Install in Claude Code

Inside Claude Code:

```
/plugin marketplace add dadiogaosai/gogodev
/plugin install gogodev@dadiogaosai
```

Or from the terminal:

```bash
claude plugin marketplace add dadiogaosai/gogodev
claude plugin install gogodev@dadiogaosai
```

Then:

1. Run `/gogodev:setup` once. Dependencies (`mattpocock-skills`, JetBrains' `modern-go-guidelines`, Alibaba's `open-code-review`) are declared in the manifest, but marketplace resolution can be finicky — setup installs everything explicitly and is the reliable path. For `loop`, it installs the `open-code-review-delegate` skill and offers the `ocr` CLI. It also installs gopls if you have a Go toolchain. Prefer the terminal? `./scripts/install.sh` installs these plus Ponytail outside a Claude session — handy for onboarding a new machine or CI.
2. Restart Claude Code — commands, skills, and hooks load at session start.
3. In each repo where you'll use it, run `/gogodev:setup` again to initialize OpenSpec (`openspec init`).

To try the plugin from a local clone instead of GitHub, point the marketplace at the checkout: `claude plugin marketplace add /path/to/gogodev`.

## Install in Codex

Download the standalone installer and run it with Bash:

```bash
curl -fsSLo install-codex.sh https://raw.githubusercontent.com/dadiogaosai/gogodev/main/scripts/install-codex.sh
bash install-codex.sh
```

It installs gogodev, Matt Pocock's four workflow skills globally, the JetBrains, Alibaba, and Ponytail plugins, OpenSpec, gopls when Go is available, and the `ocr` CLI. It skips dependencies already present and leaves OpenSpec initialization to each target repo. Start a new Codex session after installation. From a gogodev checkout, you can run `./scripts/install-codex.sh` instead.

To install the components manually, start with gogodev:

```bash
codex plugin marketplace add dadiogaosai/gogodev
codex plugin add gogodev@dadiogaosai
```

For Go projects, install JetBrains' modern Go guidelines plugin too:

```bash
codex plugin marketplace add JetBrains/go-modern-guidelines
codex plugin add modern-go-guidelines@goland-codex-marketplace
```

For Matt Pocock's original interview, TDD, implementation, and review guidance, run this in each project where you want it and select Codex plus `grilling`, `tdd`, `implement`, and `code-review`:

```bash
npx skills@latest add mattpocock/skills
```

For `loop` mode, install OpenCodeReview's `ocr` CLI. Its delegation workflow uses the host agent for the review, so no OCR provider, model, or API key is needed:

```bash
npm install -g @alibaba-group/open-code-review
```

Gogodev uses the [OpenCodeReview delegation skill](https://github.com/alibaba/open-code-review/blob/main/skills/open-code-review-delegate/SKILL.md) to combine the host agent's review with Matt's Standards and Spec review. The Codex plugin provides that skill; the installer includes it. For a manual installation:

```bash
codex plugin marketplace add alibaba/open-code-review
codex plugin add open-code-review-codex@open-code-review
```

The installer includes [Ponytail](https://github.com/DietrichGebert/ponytail). For a manual Codex installation:

```bash
codex plugin marketplace add DietrichGebert/ponytail
codex plugin add ponytail@ponytail
```

After installing Ponytail, review and trust its hooks through `/hooks` in Codex, then start a new session. Gogodev's `loop` skill also includes Ponytail's minimal-code ladder.

Start a new Codex session, then invoke the bundled skills as `$gogodev-setup`, `$gogodev-propose`, `$gogodev-capture`, and `$gogodev-apply` (for example, “Use $gogodev-propose to explore this idea”). The existing `go-semantic-search` and `grill-before-openspec` skills are included too. Codex loads these as skills, not Claude's `/gogodev:*` slash commands. Run `$gogodev-setup` in each target repository to check OpenSpec and initialize it with `openspec init --tools codex` when needed.

The Codex skills contain fallback interview, task, and review procedures. They use Matt's interview and TDD skills where applicable; his `implement` and `code-review` instructions are adapted to OpenSpec's task ledger and the uncommitted review gate. They do not require Claude marketplace dependencies. `loop` mode requires the `ocr` CLI and the `open-code-review-delegate` skill, with no OCR provider configuration. The Claude grep guard and gopls LSP registration are Claude-only; in Codex, `go-semantic-search` guides gopls use without a blocking hook.

## Update Claude Code

```bash
claude plugin marketplace update dadiogaosai   # refresh the marketplace's view of the repo
claude plugin update gogodev@dadiogaosai       # update the plugin itself
```

Then restart Claude Code to apply. Note that `update` only acts when the version in `plugin.json` has *increased*; for a same-version refresh (e.g. tracking a local clone), reinstall instead:

```bash
claude plugin uninstall gogodev@dadiogaosai && claude plugin install gogodev@dadiogaosai
```

Dependency plugins update independently: `claude plugin update mattpocock-skills@claude-plugins-official`, `claude plugin update modern-go-guidelines@goland-claude-marketplace`, and `claude plugin update open-code-review@open-code-review` — or update everything at once from the `/plugin` menu.

For Codex, refresh the marketplace and reinstall the plugin to replace its cached copy, then start a new session:

```bash
codex plugin marketplace upgrade dadiogaosai
codex plugin remove gogodev@dadiogaosai
codex plugin add gogodev@dadiogaosai
```

## Claude Code commands and Codex skills

In Codex, use the matching `gogodev-propose`, `gogodev-capture`, `gogodev-apply`, and `gogodev-setup` skills. The slash command names below apply to Claude Code.

| Command | What it does |
| --- | --- |
| `/gogodev:propose <idea>` | Runs a `/grill-me` interview first. Only if the idea survives: `openspec new change`, then `proposal.md` / `design.md` / `tasks.md` written from the interview, validated. A killed idea writes nothing. |
| `/gogodev:capture [name]` | No-interview counterpart for designs that emerged organically in the session (Matt's `to-spec` rules): synthesize the conversation into an OpenSpec change — re-asking nothing, inventing nothing. One permitted check-in: the testing seams. |
| `/gogodev:apply [change]` | Implements an approved change. Asks once per change — `tdd`, `implement`, or `loop`? (recorded in `design.md`) — then works `tasks.md`, ticking checkboxes one at a time. `tdd`/`implement` end with `/code-review` and a commit; `loop` runs its own stricter cycle (below) ending in a human-approved commit. Suggests archiving (slash command or `openspec archive` CLI, whichever is loaded). |
| `/gogodev:setup` | Installs the dependency plugins, checks the `openspec` CLI, offers `openspec init --tools claude`, installs gopls when a Go toolchain exists, and offers the `ocr` CLI for `loop` mode. |

Tasks in `tasks.md` are written as **tracer bullets** (Matt's `to-tickets` discipline): vertical slices that are individually demoable, sized to one context window, with blocking edges noted, an optional `(manual)` tag for human-only tasks, and expand–contract sequencing for wide refactors.

## `loop` mode

A third, opt-in execution mode for `apply`, for changes you want to run with minimal check-ins. In Claude Code the autonomous work runs in a background subagent. In Codex it can use a background agent when available, or run in the current session with progress updates. Both require human approval before the final commit:

- The agent works per non-manual task, in order: write failing tests (mandatory TDD), implement under the [Ponytail](https://github.com/DietrichGebert/ponytail) discipline (stop at the first rung that solves the problem — YAGNI, reuse, stdlib, native feature, existing dependency, one-liner, minimal code, in that order), then gate on lint+typecheck+tests. Tasks tagged `(manual)` are skipped.
- Once every task's gate has passed, it reviews the whole change on Matt's Standards and Spec axes, plus the [OpenCodeReview delegation skill](https://github.com/alibaba/open-code-review/blob/main/skills/open-code-review-delegate/SKILL.md). OCR selects files and supplies rules; the host agent reviews correctness, security, and performance without an OCR API key. Both installers make `open-code-review-delegate` available. Codex applies Matt's review rubric to the uncommitted diff because the upstream skill expects committed `HEAD`. Findings are merged, deduped, and route back to just the task(s) they concern. It never commits.
- Clean review → the subagent reports back and your session opens a human-approval gate (a brief: time taken, review rounds, findings and fixes, a pointer to the full diff). Changes requested resume the same subagent; approval commits once, in your session, against the tree it left.
- No fixed retry cap — only a stall detector (the same failure or finding recurring unchanged) stops the subagent short of success, leaving the working tree uncommitted for inspection.

## Safety net

A model-invocable skill (`grill-before-openspec`) steers even a habitual `/opsx:propose` or a conversational "let's draft a proposal" through the interview first. Advisory rather than guaranteed — `/gogodev:propose` is the deterministic path.

## Go projects: gopls-first search

In repos with a `go.mod`, symbol questions (definitions, references, implementations) must go through gopls, not grep:

- **The teeth in Claude Code** — a PreToolUse hook denies symbol-shaped Grep patterns (CamelCase/mixedCase identifiers, `func X` / `type X` hunts, call searches) and replies with the exact gopls commands instead. Text-shaped searches (strings, spaces, TODO markers, config keys, regex syntax) always pass. No gopls installed → the grep proceeds with a nudge toward `/gogodev:setup`, never a hard block. Codex uses the skill guidance without this hook.
- **The map** — the `go-semantic-search` skill: `gopls workspace_symbol` to find a position, then `references` / `definition` / `implementation` at it.
- **The ambient layer in Claude Code** — gopls registered as an LSP server for `.go` files: diagnostics after every edit where gopls exists, gracefully skipped where it doesn't.
- **The style layer** — JetBrains' [modern-go-guidelines](https://github.com/JetBrains/go-modern-guidelines) (`use-modern-go` skill) is available in both Claude Code and Codex. Install its Codex plugin using the commands above; `$gogodev-apply` uses it for Go changes when available.

## Not wrapped, on purpose

Archiving and spec syncing (`/opsx:archive`, `/opsx:sync`) are stock OpenSpec — they already validate and bookkeep fine. This plugin adds process where OpenSpec is weak (elicitation, execution discipline), not wrappers for what already works.
