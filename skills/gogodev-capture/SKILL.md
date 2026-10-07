---
name: gogodev-capture
description: Turn a design already settled in the current conversation into validated OpenSpec artifacts without repeating the interview.
---

# Capture an agreed design

Check `openspec --version` and the target project's OpenSpec root. The conversation must contain a substantive, already discussed design. If it does not, use `gogodev-propose` to interview the idea.

Read relevant repository code and decisions. Synthesize only what the conversation settled, following Matt Pocock's `to-spec` synthesis rules if that skill is installed. Keep OpenSpec as the sole output destination; do not create a separate tracker spec. Identify the highest useful testing seam, preferably an existing one, and confirm it with the user before creating artifacts. Ask one targeted question for any material design gap; do not invent an answer.

Choose a kebab-case name, run `openspec new change "<name>"` and `openspec status --change "<name>" --json`, then follow the returned artifact paths and order. Run `openspec instructions <artifact-id> --change "<name>"` for each artifact. Write `proposal.md` from the agreed problem, solution, and rejected alternatives; `design.md` from agreed implementation and test decisions; and `tasks.md` as verifiable vertical slices with checkboxes, dependencies, `(manual)` tags, and expand/migrate/contract ordering when needed.

Run `openspec validate --change "<name>"`, repair errors, and report the change name, paths, and next step: `gogodev-apply`. Do not start implementation.
