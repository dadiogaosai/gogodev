---
description: Implement an approved OpenSpec change using Matt Pocock's implement or tdd workflow
argument-hint: [change-name]
---

Implement the OpenSpec change: $ARGUMENTS

This command keeps OpenSpec's task bookkeeping honest while handing the actual engineering to Matt Pocock's `implement` or `tdd` skill.

## Step 0: Dependency check

Verify the `implement` and `tdd` skills (from the `mattpocock-skills` plugin) are available, the `openspec` CLI responds, and an OpenSpec root exists. If not, STOP and point the user at `/gogodev:setup`.

## Step 1: Select the change

If $ARGUMENTS names a change, use it. Otherwise infer from conversation context; if only one active change exists, auto-select it; if ambiguous, run `openspec list --json` and ask the user to pick (AskUserQuestion). Announce: "Using change: <name>".

## Step 2: Load OpenSpec state

```bash
openspec status --change "<name>" --json
openspec instructions apply --change "<name>" --json
```

Handle states:
- `blocked` (missing artifacts) → report which artifacts are missing and suggest finishing the proposal first (`/gogodev:propose` or `/opsx:continue`).
- `all_done` → congratulate, suggest `/opsx:archive <name>`.
- Otherwise → read EVERY file listed in `contextFiles` (proposal, specs, design, tasks — whatever the schema lists), then show progress ("N/M tasks complete") and continue.

## Step 3: Choose the execution mode (once per change)

Check the change's `design.md` for an `## Execution mode` section.

- **If present**, use the recorded mode. Do not re-ask.
- **If absent**, look at the design and tasks, then ask the user ONCE (AskUserQuestion): "`tdd` or `implement` for this change?" Give a recommendation: lean `tdd` when the work is testable logic with clear seams; lean `implement` (the default) when it is mostly wiring, config, or UI plumbing. Record the answer by appending to `design.md`:

  ```markdown
  ## Execution mode

  <implement|tdd> — chosen <date>. <one-line reason>
  ```

  This makes the choice survive interrupted sessions.

## Step 4: Implement tasks with Matt's workflow

Run the chosen skill — `implement` or `tdd` from the `mattpocock-skills` plugin — with the change's artifacts as the spec. The `contextFiles` from Step 2 ARE the spec/tickets that skill expects; follow its rules (for `tdd`: pre-agreed seams, red-green loop, vertical slices; for `implement`: typecheck regularly, use tdd at pre-agreed seams where possible).

Layer OpenSpec's bookkeeping on top:

- Work through `tasks.md` in order, one task at a time.
- Immediately after a task is verified complete, tick its checkbox in the tasks file (`- [ ]` → `- [x]`). Never batch-tick; the file must always reflect reality.
- If implementation reveals a design problem, PAUSE — propose updating the change's artifacts (that is normal OpenSpec flow, not a failure) and get the user's agreement before continuing.
- Pause on unclear tasks, errors, or blockers. Don't guess.

## Step 5: Wrap up

When done (or paused), report: tasks completed this session, overall progress N/M, and — per Matt's `implement` skill — run `/code-review` on the work and commit to the current branch if the user hasn't said otherwise.

If all tasks are complete, suggest archiving to fold the change into the main specs. Archiving is stock OpenSpec; this plugin does not wrap it. Two equivalent routes — offer the one that works now:

- `/opsx:archive <name>` — only if the `/opsx:*` commands are loaded in this session (they won't be if `openspec init` ran mid-session; they register at session start).
- `openspec archive <name>` via Bash — always works, same behavior including built-in validation. Offer to run it directly rather than telling the user to restart.
