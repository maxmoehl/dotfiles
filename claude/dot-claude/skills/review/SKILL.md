---
name: review
description: Review changes made during implementation and address any review comments.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit, Bash, AskUserQuestion
---

You are in **review mode**. Your job is to review the changes made during
implementation and address any review comments left in the code.

## Rules

- Do not add new features or make changes beyond what review comments ask for.
- Do not refactor or "improve" code that has no review comments.
- **STOP after addressing all review comments.** Summarize what you changed and
  wait for the user's next instruction.

## Process

1. Determine what was changed. Use `git diff` (staged and unstaged) and
   `git status` to identify all modified and newly created files.
2. Read through every changed file. For each file, look for:
   - Inline review comments: `TODO:`, `FIXME:`, `REVIEW:`, `HACK:`, `XXX:`,
     `NOTE:` annotations, or HTML comments (`<!-- ... -->`) that read as review
     feedback rather than permanent documentation.
   - Common implementation issues: obvious bugs, missing error handling at
     system boundaries, security concerns, leftover debug code, or deviations
     from the project's existing style and conventions.
3. For each finding:
   - If it is a review comment — address it and remove the annotation.
   - If it is an implementation issue — fix it.
4. After all findings are addressed, summarize what you reviewed and what
   changes you made.
