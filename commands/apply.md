---
description: Implement an approved OpenSpec change using Matt Pocock's implement or tdd workflow
argument-hint: [change-name]
---

Implement the OpenSpec change: $ARGUMENTS

This command keeps OpenSpec's task bookkeeping honest while handing the actual engineering to Matt Pocock's `implement` or `tdd` skill.

## Step 0: Dependency check

Verify the `implement` and `tdd` skills (from the `mattpocock-skills` plugin) are available, the `openspec` CLI responds, and an OpenSpec root exists. If not, STOP and point the user at `/gogodev:setup`. (The `ocr` CLI, needed only if `loop` mode is chosen, is checked in Step 4-loop instead — no need to gate the whole command on it.)

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
- **If absent**, look at the design and tasks, then ask the user ONCE (AskUserQuestion): "`tdd`, `implement`, or `loop` for this change?"
  - `tdd` / `implement` — a single pass through the tasks (Step 4), ending with `/code-review` and one commit (Step 5).
  - `loop` — a stricter, mostly-autonomous cycle (Step 4-loop): mandatory TDD per task, a lint+typecheck+test gate, a dual review (Standards+Spec and OpenCodeReview) once every task is implemented, and a single human-approval gate before the one commit for the whole change.
  - Recommendation: lean `tdd` when the work is testable logic with clear seams; lean `implement` when it is mostly wiring, config, or UI plumbing; lean `loop` when the change has several tasks and should run with minimal check-ins along the way.

  Record the answer by appending to `design.md`:

  ```markdown
  ## Execution mode

  <implement|tdd|loop> — chosen <date>. <one-line reason>
  ```

  This makes the choice survive interrupted sessions.

## Step 4: Implement tasks with Matt's workflow (`tdd` / `implement` modes)

Skip this step and Step 5 entirely if the mode is `loop` — go to "Step 4-loop" below instead; it replaces both.

Run the chosen skill — `implement` or `tdd` from the `mattpocock-skills` plugin — with the change's artifacts as the spec. The `contextFiles` from Step 2 ARE the spec/tickets that skill expects; follow its rules (for `tdd`: pre-agreed seams, red-green loop, vertical slices; for `implement`: typecheck regularly, use tdd at pre-agreed seams where possible).

Layer OpenSpec's bookkeeping on top:

- Work through `tasks.md` in order, one task at a time.
- Immediately after a task is verified complete, tick its checkbox in the tasks file (`- [ ]` → `- [x]`). Never batch-tick; the file must always reflect reality.
- If implementation reveals a design problem, PAUSE — propose updating the change's artifacts (that is normal OpenSpec flow, not a failure) and get the user's agreement before continuing.
- Pause on unclear tasks, errors, or blockers. Don't guess.

## Step 5: Wrap up (`tdd` / `implement` modes)

When done (or paused), report: tasks completed this session, overall progress N/M, and — per Matt's `implement` skill — run `/code-review` on the work and commit to the current branch if the user hasn't said otherwise.

If all tasks are complete, suggest archiving to fold the change into the main specs. Archiving is stock OpenSpec; this plugin does not wrap it. Two equivalent routes — offer the one that works now:

- `/opsx:archive <name>` — only if the `/opsx:*` commands are loaded in this session (they won't be if `openspec init` ran mid-session; they register at session start).
- `openspec archive <name>` via Bash — always works, same behavior including built-in validation. Offer to run it directly rather than telling the user to restart.

## Step 4-loop: The `loop` execution mode

This replaces Step 4 and Step 5 completely — do not run those for `loop` mode. Requires the `open-code-review` plugin's `ocr` CLI (`/gogodev:setup` Check 5). If `ocr` isn't on PATH, STOP and point the user there.

`loop` mode's whole point is to run with minimal check-ins, so the autonomous work is delegated to a background subagent — this session only launches it and handles the one human-approval checkpoint at the end. Never run the per-task cycle or the review inline in this session; that would defeat the purpose and flood this session's context with every task's test/gate output.

### 4-loop.a: Launch the implementation subagent

Launch a subagent via the Agent tool with `subagent_type: "fork"` — it inherits this session's already-loaded OpenSpec context (Steps 1–2) for free, runs in the background, and keeps its tool output out of this session's context. Tell the user it's running in the background and they can keep working; do not poll for progress — wait for its completion notification.

Give the fork this brief, in full (it must be self-contained and unambiguous even though it inherits context):

> Work through `<change name>`'s `tasks.md` autonomously. Do not commit at any point — a human approves and commits after you report back.
>
> **1. Classify tasks.** For each task, decide whether it's manual (not agent-executable — dashboard clicks, external approvals, credential rotation, anything outside the codebase): prefer an explicit `(manual)` tag at the end of the task line (e.g. `- [ ] Rotate the prod API key (manual)`); for untagged tasks, judge from the description. Manual tasks are excluded from the cycle below — leave their checkboxes unticked, they're the human's to do and tick themselves.
>
> **2. Per-task cycle**, for each non-manual, unticked task, in order:
>    1. Write failing tests for the task. Mandatory — no implement-only path.
>    2. Implement, applying the [ponytail](https://github.com/DietrichGebert/ponytail) ladder throughout — stop at the first rung that solves the problem: (1) does it need to exist at all? skip speculative needs — (2) already in this codebase? reuse it — (3) does stdlib cover it? — (4) a native platform feature (CSS over JS, a DB constraint over app logic)? — (5) an already-installed dependency? never add a new one for a few lines — (6) a one-liner? — (7) minimal working code, only then. Fix bugs at the root cause / shared layer, never just in the caller that tripped on it. Never simplify away input validation, error handling, security, or accessibility. Mark any deliberate corner-cutting with a `ponytail:` comment naming the ceiling and the upgrade path.
>    3. Gate: run the project's lint, typecheck, and test commands (detect from its tooling — `package.json` scripts, `Makefile`, etc.). Fail → back to step 1/2 for this task, unless this failure is materially the same as the previous attempt's (same error, nothing changed) — then stop, this is a stall (see below). Pass → tick this task's checkbox immediately (never batch-tick), move to the next task.
>
> **3. Review the whole change once every non-manual task's checkbox is ticked.** Run in parallel: `mattpocock-skills:code-review` (Standards + Spec) against the change's fixed point, and OpenCodeReview via `ocr review --audience agent` (workspace mode, the uncommitted diff directly — call the CLI directly, not the plugin's packaged `/review` command, which decides on its own whether to apply fixes). Merge and dedupe both reports into one findings list. Any findings → for each affected task, un-tick its checkbox, redo step 2 for just that task, then review again — unless a review round surfaces materially the same finding as the previous round with nothing changed, which is also a stall. Clean → done.
>
> **4. Report back.** If you stopped on a stall: report what was tried and why it's stuck, and leave the working tree exactly as the last attempt left it, uncommitted. If review came back clean: report total time taken, how many review→fix rounds ran, the findings from each round and what was fixed, and confirm the working tree is uncommitted and ready for human approval.

### 4-loop.b: Human gate

When the subagent's completion notification arrives:

- **It stalled** → relay its report to the user as-is (what was tried, why it's stuck, the tree left uncommitted for inspection). `loop` mode ends here; there's nothing to approve.
- **It came back clean** → ask the user (AskUserQuestion) with a brief built from its report: total time, review→fix round count, findings and fixes per round, and a pointer to the full diff (`git diff <fixed-point>...HEAD`) rather than the diff dumped inline — large multi-task changes don't fit in a brief.
  - **Changes requested** → `SendMessage` the *same* subagent, naming which task(s) to reopen and why; wait for its next report; re-run this step when it arrives.
  - **Approved** → commit now, in this session, against the working tree the subagent left. This is the loop's only commit for the whole change — nothing commits before this point.

If all tasks are complete after commit, suggest archiving exactly as Step 5 does for `tdd`/`implement` mode.
