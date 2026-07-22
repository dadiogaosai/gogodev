---
description: Turn the current conversation into an OpenSpec change proposal — no interview, just synthesis of what was already discussed
argument-hint: [optional change name or focus]
---

Capture the design already discussed in this conversation as an OpenSpec change proposal.

This is the no-interview counterpart to `/gogodev:propose`, borrowing the rules of the `mattpocock-skills:to-spec` skill: the thinking already happened in this session — synthesize it, don't re-litigate it. The output is OpenSpec artifacts instead of a tracker spec.

## Step 0: Preconditions

- The `openspec` CLI responds and an OpenSpec root exists (else point to `/gogodev:setup`).
- **The conversation actually contains a discussed design.** If the session has no substantive design discussion to capture — the user is really starting fresh — say so and redirect to `/gogodev:propose`, which runs the interview. Capturing a thin conversation produces a thin proposal that only looks authoritative.

## Step 1: Synthesize — do NOT interview

Do NOT re-ask questions the conversation already answered, and do NOT invent decisions that were never discussed. Explore the repo first if you haven't already; use the project's domain vocabulary and respect ADRs in the area.

The one permitted check-in, per to-spec's rules: sketch the **seams** at which the work will be tested — prefer existing seams, at the highest point possible, ideally one — and confirm those seams with the user before writing artifacts.

## Step 2: Scaffold and write artifacts

Derive a kebab-case name from the discussed change ($ARGUMENTS may name or narrow it), then:

```bash
openspec new change "<name>"
openspec status --change "<name>" --json
openspec instructions <artifact-id> --change "<name>"   # per artifact, in dependency order
```

Map the conversation onto the artifacts:

- **proposal.md** — problem and solution from the *user's* perspective, plus alternatives that were raised and rejected in conversation (with the stated reasons).
- **design.md** — the implementation decisions made in the session: modules and interfaces touched, schema changes, API contracts, architectural choices, and the testing decisions including the confirmed seams. Record decisions, not file-path-by-file-path plans — paths go stale. If anything discussed was explicitly deferred, list it under an "Out of scope" heading.
- **tasks.md** — tracer-bullet checkboxes, per the slicing rules below.

If synthesis reveals a genuine hole — a decision the conversation never actually made — ask one targeted question rather than guessing, and note the answer in design.md.

## Tracer-bullet slicing rules (for tasks.md)

- Each task is a **vertical slice**: a narrow but COMPLETE path through every layer it touches (schema, API, UI, tests) — never a horizontal slice of one layer. A completed task is demoable or verifiable on its own.
- Size each task to fit a single fresh context window.
- Any prefactoring ("make the change easy, then make the easy change") comes first.
- Note blocking edges inline where order matters: `- [ ] Wire X into Y (blocked by: task 2)`. A task with no blockers can start immediately.
- **Wide refactors** (one mechanical change with a codebase-wide blast radius) are the exception: sequence them as expand → migrate in batches → contract, each batch its own task blocked by the expand.

## Step 3: Validate and hand off

Run `openspec validate --change "<name>"`, fix errors, then show the change name, artifact locations, and a one-paragraph summary. Next step: `/gogodev:apply <name>`. Do not start implementing.
