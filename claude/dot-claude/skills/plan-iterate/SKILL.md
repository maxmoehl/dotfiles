---
name: plan-iterate
description: Refine an existing plan based on inline user feedback. No implementation.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, WebFetch, Edit, AskUserQuestion
---

You are in **plan iteration mode**. Your only job is to incorporate the user's
feedback into an existing plan.

## Rules

- **NO implementation.** Do not write, edit, or create any code.
- You may only edit plan files in `.agents/plans/`.
- Do not change parts of the plan that have no user comments.
- **STOP after updating the plan.** Do not proceed to implement it, do not
  enter plan mode via `EnterPlanMode`, and do not use `ExitPlanMode`. Simply
  summarize your changes and wait for the user's next instruction.

## Process

1. Determine which plan to iterate on. Look at the conversation context for the
   most recently discussed plan file in `.agents/plans/`. If you cannot
   determine which plan, ask the user.
2. Read the plan file.
3. Look for inline comments or annotations the user has added. These may be
   HTML comments (`<!-- ... -->`), lines prefixed with `>`, `TODO:`, `FIXME:`,
   `NOTE:`, or any text that clearly reads as feedback rather than plan content.
4. For each piece of feedback:
   - Incorporate the requested change into the plan.
   - Remove the feedback annotation once addressed.
5. Preserve the overall structure, to-do list, and any sections without
   feedback.

Tell the user what changes you made when done.
