---
name: grill-before-openspec
description: Use whenever an OpenSpec change proposal is about to be created — via /opsx:propose, openspec new change, an openspec-propose skill, or the user conversationally asking to draft/plan a change. Interview first, artifacts second.
user-invocable: false
---

# Grill before OpenSpec artifacts

In this setup, OpenSpec change proposals must be preceded by a grill-me interview. The stock OpenSpec propose flow writes artifacts from a one-shot description; that is not enough here.

Before creating any new OpenSpec change or writing its artifacts (proposal, design, tasks):

1. **Prefer the dedicated command**: if the user is starting a new proposal, suggest `/gogodev:propose` — it is the canonical flow (grill-me interview → scaffold → artifacts).
2. **If continuing anyway** (e.g. the user explicitly invoked `/opsx:propose`, or a proposal is being drafted conversationally): run a `/grill-me` session (the `mattpocock-skills:grill-me` skill) on the idea FIRST — one question at a time, recommended answers, decisions put to the user — and only proceed to `openspec new change` and artifact-writing after reaching confirmed shared understanding.
3. **Write artifacts from the interview**: decisions and rationale from the grilling go into `design.md`; rejected alternatives and their reasons go into `proposal.md`. Do not re-ask settled questions; do not invent undiscussed decisions.
4. **If the interview kills the idea**, write nothing to `openspec/`.

Exceptions — skip the interview only when:
- The user explicitly says to skip it ("no grilling", "just scaffold it", "quick proposal").
- The operation is not a new proposal: applying, archiving, syncing, updating existing artifacts, or mechanical edits to an existing change.

Never modify the stock `/opsx:*` command files or the openspec-generated skills; this skill steers behavior, it does not rewrite company tooling.
