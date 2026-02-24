# Claude Code Style and Best Practices

## Whitespace Rules
- **NEVER** leave trailing whitespace when writing code
- **ALWAYS** add a single trailing newline to the end of files

These rules ensure clean, consistent code formatting and prevent unnecessary diff noise in version control.

## Commenting Style
- **AVOID** obvious comments that simply restate what the code already makes clear
- Examples of comments to avoid:
  - `# Install function` before `install() {`
  - `# Check if file exists` before `if [ -f "$file" ]; then`
  - `# Loop through items` before `for item in $items; do`
- **DO** include comments that explain:
  - Complex logic or algorithms
  - Business rules or requirements
  - Why something is done (not just what is done)
  - Non-obvious side effects or dependencies

## File Creation Guidelines
- **NEVER** create files unless they're absolutely necessary for achieving your goal
- **ALWAYS** prefer editing an existing file to creating a new one
- **NEVER** proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User

## Error Handling
- **ALWAYS** include proper error handling in new code
- **PREFER** explicit error checking over silent failures

## Import/Dependency Management
- **NEVER** assume libraries are available - always check existing imports first
- **FOLLOW** existing import patterns and conventions in the codebase
- **AVOID** adding new dependencies without understanding existing alternatives
- **ALWAYS** consult with the user before adding a new dependency

## Code Consistency
- **MATCH** existing code style, naming conventions, and patterns
- **USE** existing utilities and helper functions before creating new ones
- **FOLLOW** the project's established architecture patterns

## Go-Specific Rules
- **NEVER** include variable declarations within if statement conditions
  - Preferred: `val := getValue(); if val != nil {`
  - Avoid: `if val := getValue(); val != nil {`
- **PREFER** guard statements with early returns to reduce nesting
  - Preferred: `if !condition { return }`
  - Avoid: `if condition { /* many lines of code */ }`
- **NEVER** exceed 3 levels of indentation
  - Use early returns, extract functions, or restructure logic to maintain shallow nesting
  - Deep nesting makes code harder to read and maintain

## Perl-Specific Rules
- **ALWAYS** use `use strict;` and `use warnings;` at the top of every script
- **ALWAYS** use parentheses on function calls
  - Preferred: `my @sorted = sort(@items);`
  - Avoid: `my @sorted = sort @items;`
- **NEVER** use postfix conditionals or loops
  - Preferred: `if (!defined($val)) { return; }`
  - Avoid: `return unless defined $val;`
- **ALWAYS** use `STDERR->print(...)` for printing to STDERR
  - Avoid: `print STDERR "...";`
  - Avoid: `warn "...";` (when the intent is output, not a warning)
- **ALWAYS** use explicit block forms for control structures
  - Preferred: `if ($cond) { ... }`, `for my $item (@list) { ... }`
  - Avoid: `... if $cond;`, `... for @list;`, `... while $cond;`
- **NEVER** use implicit `$_` when a named variable is practical
  - Preferred: `for my $line (@lines) { chomp($line); }`
  - Avoid: `chomp for @lines;`
- **ALWAYS** use `my` to declare variables in the smallest applicable scope
- **PREFER** `//` (defined-or) over `||` when testing for definedness
  - `my $val = $input // "default";`
- **PREFER** three-argument `open` with lexical filehandles
  - Preferred: `open(my $fh, '<', $path) or die("open $path: $!");`
  - Avoid: `open(FH, $path);`
- **NEVER** use string-eval (`eval "..."`) — use block-eval (`eval { ... }`) when needed
- **PREFER** `die` with a meaningful message over bare `die`
- **PREFER** snake_case for variable and subroutine names
