---
name: gogodev-apply
description: Implement an approved OpenSpec change task by task with TDD, verification, review, and honest task bookkeeping.
---

# Apply an OpenSpec change

Verify the OpenSpec CLI and project root. Select the named change, infer it if unambiguous, or use `openspec list --json` and ask. Run `openspec status --change "<name>" --json` and `openspec instructions apply --change "<name>" --json`. If blocked, report missing artifacts. If complete, suggest `openspec archive <name>`. Otherwise read every returned `contextFiles` entry and report task progress.

Read `design.md` for `## Execution mode`. If it is absent, recommend and ask once: `tdd` for testable behavior, `implement` for wiring or UI, or `loop` for a multi-task change needing stricter gates and a final approval. Record the choice, date, and reason under `## Execution mode` in `design.md`.

For `tdd` or `implement`, work the task list in order. In `tdd`, write a failing test at the agreed seam, implement the smallest passing change, then refactor. In `implement`, check types and tests regularly and use TDD at agreed seams. Follow the project's conventions and run relevant tests. Tick each checkbox immediately after that task is verified; never batch-tick or mark unfinished work complete. If implementation reveals a material design problem, update the OpenSpec artifacts with the user's agreement. When finished, review the complete diff for correctness against the specs, run the project's checks, and report progress and findings. Commit only when authorized by the user or established project workflow. Suggest `openspec archive <name>` when all tasks are done.

For `loop`, require `ocr` on `PATH`. Work each non-manual task with failing tests first, a minimal implementation, and the project's lint, typecheck, and test gate. Leave `(manual)` tasks unticked. Fix failures and only tick a task when its gate passes. Stop if the same blocker recurs without progress. After all agent-executable tasks, review the whole diff against standards and the OpenSpec artifacts, and run `ocr review --audience agent` on the uncommitted workspace. Merge duplicate findings, reopen affected tasks, fix them, rerun the gate, and repeat review until clean or stalled. Keep the tree uncommitted. Report time, review rounds, findings, and the diff location; ask for human approval before the one final commit. If Codex exposes a background agent in this session, the task cycle may run there; otherwise run it in the current session with progress updates.
