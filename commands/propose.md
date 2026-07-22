---
description: Grill the idea with a grill-me interview, then write it up as an OpenSpec change proposal
argument-hint: [idea or change description]
---

Create an OpenSpec change proposal for: $ARGUMENTS

This command replaces OpenSpec's stock elicitation with a relentless grill-me interview. The interview comes FIRST; OpenSpec artifacts are only written once the idea has survived it.

## Step 0: Dependency check

Verify, in order:

1. The `grill-me` skill (from the `mattpocock-skills` plugin) is available in your skills listing.
2. The `openspec` CLI responds (`openspec --version`).
3. An OpenSpec root exists (an `openspec/config.yaml` reachable from the working directory — check with `openspec context 2>/dev/null` or look for the file).

If any check fails, STOP and tell the user to run `/gogodev:setup` first. Do not fall back to stock OpenSpec behavior — a proposal without the interview defeats the purpose of this command.

## Step 1: Grill the idea

Run a `/grill-me` session (the `mattpocock-skills:grill-me` skill) about the idea in $ARGUMENTS. If no idea was given, first ask what change they want to make.

Follow that skill's rules strictly: one question at a time, a recommended answer for each, look up facts in the environment yourself, put every decision to the user. Walk every branch until you reach shared understanding, and get explicit confirmation of the summarized understanding.

Possible outcomes:

- **The idea survives** → continue to Step 2.
- **The interview kills or shelves the idea** → STOP. Write nothing to `openspec/`. Summarize why it died and what would need to change to revive it. A half-grilled idea is not an artifact.

## Step 2: Scaffold the change

Only now touch OpenSpec. Derive a kebab-case change name from the *final* (post-grilling) shape of the idea — the original framing may no longer be accurate. Confirm the name with the user if it differs meaningfully from what they asked for.

```bash
openspec new change "<name>"
openspec status --change "<name>" --json
```

Parse the status JSON for `applyRequires`, `artifacts` (with dependency order), `changeRoot`, and `artifactPaths`. Use those paths — do not assume repo-local layout.

## Step 3: Fill artifacts from the interview

Work through the artifacts in dependency order (typically proposal → design → tasks for the spec-driven schema). For each artifact, fetch its template and guidance:

```bash
openspec instructions <artifact-id> --change "<name>"
```

Then write the artifact **from the grilling transcript**, not from scratch:

- **proposal.md** — the what and why: the problem as sharpened by the interview, the chosen approach, and the alternatives that were considered and rejected (with the reasons the user gave).
- **design.md** — the how: every decision the user confirmed during grilling, with its rationale. This file is the interview's paper trail; a teammate reading it should be able to reconstruct why each choice was made.
- **tasks.md** — implementation steps as `- [ ]` checkboxes, written as **tracer bullets** (per Matt's to-tickets discipline):
  - Each task is a **vertical slice**: a narrow but COMPLETE path through every layer it touches (schema, API, UI, tests) — never a horizontal slice of one layer. A completed task is demoable or verifiable on its own.
  - Size each task to fit a single fresh context window.
  - Any prefactoring ("make the change easy, then make the easy change") comes first.
  - Note blocking edges inline where order matters: `- [ ] Wire X into Y (blocked by: task 2)`. A task with no blockers can start immediately.
  - **Wide refactors** (one mechanical change with a codebase-wide blast radius) are the exception to vertical slicing: sequence them as expand → migrate in batches → contract, each batch its own task blocked by the expand.

The user already answered the hard questions — do NOT re-ask things settled during grilling, and do NOT invent decisions that were never discussed. If writing an artifact reveals a genuine gap, ask one targeted follow-up question rather than guessing.

## Step 4: Validate and hand off

```bash
openspec validate --change "<name>"
```

Fix any validation errors. Then show the user:

- The change name and where its artifacts live
- A one-paragraph summary of the proposal
- Next step: review the artifacts, then run `/gogodev:apply <name>` to implement

Do not start implementing. Proposal and implementation are separate decisions.
