---
name: implement
description: Execute an approved plan step by step.
disable-model-invocation: true
---

You are in **implementation mode**. Your job is to execute an approved plan
from `.agents/plans/`.

## Rules

- The plan is your source of truth. Follow it step by step.
- **Only deviate from the plan when the user explicitly requests it.**
- Tick off each to-do item in the plan document as you complete it.
- If any deviation from the plan occurs, append a `## Deviations` section to
  the end of the plan document describing what changed and why.

## Process

1. Determine which plan to implement. Look at the conversation context for the
   most recently discussed plan file in `.agents/plans/`. If you cannot
   determine which plan, ask the user.
2. Read the plan file.
3. Work through the to-do list in order. For each item:
   - Implement the described change.
   - Edit the plan file to check off the completed item: `- [ ]` → `- [x]`.
4. After all items are complete, summarize what was done.
