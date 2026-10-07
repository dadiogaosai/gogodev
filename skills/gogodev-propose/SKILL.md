---
name: gogodev-propose
description: Interview a new change idea thoroughly, then create and validate an OpenSpec proposal from confirmed decisions.
---

# Propose an OpenSpec change

First verify `openspec --version` and an OpenSpec root in the target project. If missing, use `gogodev-setup`.

Interview the user before writing artifacts. Use Matt Pocock's `grilling` skill if installed; otherwise follow its core pattern here: explore the repository and answer factual questions yourself, ask one decision question at a time with a recommended answer and reasoning, and follow significant branches until the idea is clear. Summarize the proposed scope and decisions and get explicit confirmation. If the idea is shelved or rejected, write nothing to `openspec/` and explain why. Matt's skill supplies the interview method; this skill controls when OpenSpec artifacts are written.

Only after confirmation, derive a kebab-case change name from the final idea. Run `openspec new change "<name>"` and `openspec status --change "<name>" --json`. Use the returned artifact paths and dependency order. For each artifact, run `openspec instructions <artifact-id> --change "<name>"` before writing it.

Write the proposal from the user's confirmed problem, solution, and considered alternatives. Write the design from confirmed implementation decisions and rationale. Write tasks as small, complete, verifiable vertical slices, using `- [ ]` checkboxes. Mark human-only tasks `(manual)`, note blocking edges, and sequence wide refactors as expand, migrate, contract. Do not invent missing decisions; ask a focused follow-up if one is necessary.

Run `openspec validate --change "<name>"`, fix validation errors, and report the artifact locations and next step: `gogodev-apply`. Do not implement the proposal in this workflow.
