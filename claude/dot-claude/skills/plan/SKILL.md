---
name: plan
description: Create an implementation plan based on research findings. No implementation.
disable-model-invocation: true
argument-hint: <feature or change>
allowed-tools: Read, Glob, Grep, WebFetch, Write, Task, AskUserQuestion, Bash(agent-helper *)
---

You are in **planning mode**. Your only job is to design a detailed
implementation plan for the requested feature or change.

## Feature / Change

$ARGUMENTS

## Project Directory

- Research: !`agent-helper document-dir`/research
- Plans: !`agent-helper document-dir`/plans
- Assets: !`agent-helper document-dir`/assets — if the user mentions additional
  assets (diagrams, screenshots, specs, etc.), look for them here.

## Rules

- **NO implementation.** Do not write, edit, or create any code.
- The only file you may create is the plan document.
- Base your plan on existing research in the research directory listed above.
- **STOP after writing the plan.** The plan document is the deliverable. Do not
  proceed to implement it, do not enter plan mode via `EnterPlanMode`, and do
  not use `ExitPlanMode`. Simply tell the user the path and wait for their next
  instruction.

## Process

1. List the research files in !`agent-helper document-dir`/research and
   read the ones relevant to this feature or change.
2. If no relevant research exists, tell the user and suggest running `/research`
   first.
3. Explore the codebase as needed to fill gaps not covered by the research.
4. Design the implementation approach.
5. Write the plan to !`agent-helper document-dir`/plans/<descriptive-name>.md
   — choose a short, lowercase, hyphenated name that reflects the feature.
   **Do NOT use mkdir or Bash to create directories.** The Write tool creates
   parent directories automatically.

## Plan Structure

The plan document should contain:

- **Context** — what problem this solves and why the change is needed
- **Approach** — the chosen strategy and rationale
- **Files to Modify** — list every file that will be created or changed
- **Step-by-Step Changes** — detailed description of each change, in order
- **Verification** — how to test that the implementation is correct

### To-Do List

End the plan with a detailed to-do list using markdown checkboxes. Each
checkbox should represent one concrete implementation step:

```markdown
## To-Do

- [ ] Step one description
- [ ] Step two description
- [ ] ...
```

Tell the user the path of the plan file when done.
