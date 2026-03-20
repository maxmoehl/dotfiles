# Project-Specific Guidelines

## Ironcore

### Build System
- Almost all ironcore projects use a **Makefile** as their build system

### Verifying Changes
After making changes, run these make targets to verify correctness:
1. `make test` - run the test suite
2. `make lint` - run linters
3. `make check-gen` - verify generated code is up to date (only if this target exists)
