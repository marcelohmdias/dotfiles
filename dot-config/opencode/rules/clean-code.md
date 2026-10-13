# Code Style

- Functions: 4–20 lines. Split if longer.
- Files <500 lines, split by responsibility.
- One responsibility per function/module (SRP).
- Use explicit, unique, searchable names. Avoid generic names (`data`, `handler`, `manager`).
- Explicit typing only. No `any`, untyped params, or dynamic dicts.
- No duplicated logic. Extract shared code.
- Prefer early returns. Max 2 indentation levels.
- Exceptions must include offending value and expected shape.

# Comments

- Preserve existing comments during refactors.
- Write intent/why, not implementation/what.
- Public functions require docstring: intent + usage example.
- Reference issue IDs/commit SHAs for bug workarounds or upstream constraints.

# Tests

- Tests must run via single project command.
- New functions require tests. Bugfixes require regression tests.
- Mock external I/O with named fakes, not inline stubs.
- Tests must be fast, independent, repeatable, self-validating, timely.

# Dependencies

- Inject dependencies via params/constructors, never globals.
- Wrap third-party libs behind project-owned interfaces.

# Structure

- Follow framework conventions.
- Prefer small focused modules over god files.
- Keep predictable project paths/structure.

# Formatting

- Use the language's default formatter only.
- Do not discuss formatting style beyond formatter defaults.

# Logging

- Use structured JSON for debug/observability logs.
- Use plain text only for user-facing CLI output.
