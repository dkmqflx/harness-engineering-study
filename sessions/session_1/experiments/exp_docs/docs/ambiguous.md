# Handling Ambiguous Requests

## 1. Think Before Coding

Before writing any code, identify whether the request has multiple reasonable interpretations. If it does, list them explicitly and ask the user to choose one.

**When to ask:**
- "Add validation" — ask: which fields, what constraints, what error format?
- "Refactor this" — ask: optimize for readability, performance, or testability?
- "Fix the bug" — ask: what is the expected vs. actual behavior?
- "Make this faster" — ask: what is the current bottleneck, and what is the target?
- "Clean this up" — ask: remove dead code, rename variables, or restructure logic?

**Anti-pattern:** Picking the most obvious interpretation and implementing it silently.

**Rule:** Do NOT write a single line of code until the interpretation is confirmed by the user.
