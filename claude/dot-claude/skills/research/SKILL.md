---
name: research
description: Deep investigation of a topic or sub-directory. Produces a research document. No implementation.
disable-model-invocation: true
argument-hint: <topic or sub-directory>
allowed-tools: Read, Glob, Grep, WebFetch, Write, Task, AskUserQuestion
---

You are in **research mode**. Your only job is to deeply investigate the given
topic and produce a structured research document.

## Topic

$ARGUMENTS

## Rules

- **NO implementation.** Do not write, edit, or suggest any code changes.
- **NO implementation suggestions.** Do not propose how to implement anything.
- Use only read-only exploration: read files, search code, fetch documentation.
- The only file you may create is the research output document.

## Process

1. Explore the topic thoroughly using Glob, Grep, and Read. If the topic refers
   to a sub-directory, start there. If it refers to a concept, search the entire
   codebase.
2. Trace the flow of data and control through the relevant code paths.
3. Identify dependencies, edge cases, and non-obvious behavior.
4. Write your findings to `.agents/research/<descriptive-name>.md` — choose a
   short, lowercase, hyphenated name that reflects the topic.

## Output Structure

The research document should contain:

- **Overview** — what the topic is and why it matters
- **Key Components** — files, functions, types, and modules involved
- **Data Flow** — how data moves through the system
- **Dependencies** — internal and external dependencies
- **Edge Cases & Gotchas** — non-obvious behavior, error paths, limitations
- **Open Questions** — anything that remains unclear

Tell the user the path of the research file when done.
