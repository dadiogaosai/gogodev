---
name: grill-before-openspec
description: Use whenever an OpenSpec change proposal is about to be created — via /opsx:propose, openspec new change, an openspec-propose skill, or the user conversationally asking to draft/plan a change.
user-invocable: false
---

# Grill before OpenSpec artifacts

In this setup, OpenSpec artifacts are written only from an idea that has **survived** a grilling interview. The stock OpenSpec propose flow writes artifacts from a one-shot description; that is not enough here.

Before creating any new OpenSpec change or writing its artifacts (proposal, design, tasks):

1. **Prefer the dedicated command**: if the user is starting a new proposal, suggest `/gogodev:propose` — the canonical flow (grilling interview → scaffold → artifacts).
2. **If continuing anyway** (the user explicitly invoked `/opsx:propose`, or a proposal is being drafted conversationally): run the `mattpocock-skills:grilling` skill on the idea FIRST, and reach `openspec new change` and artifact-writing only after confirmed shared understanding.
3. **Write artifacts from the interview**: confirmed decisions and their rationale go into `design.md`; rejected alternatives and why go into `proposal.md`. Artifacts record only what the interview settled — a genuine gap gets one targeted follow-up question, not an invented answer.
4. **If the interview kills the idea**, write nothing to `openspec/`.

Skip the interview only when:
- The user explicitly waives it ("no grilling", "just scaffold it", "quick proposal").
- The operation is not a new proposal: applying, archiving, syncing, updating existing artifacts, or mechanical edits to an existing change.

Never modify the stock `/opsx:*` command files or the openspec-generated skills; this skill steers behavior, it does not rewrite company tooling.
