# Coding Rules

## 1. Think Before Coding

If a request has multiple reasonable interpretations, list them and ask — do not quietly pick one.
Surface tradeoffs explicitly rather than hiding them inside a chosen approach.

Examples of ambiguous requests that require clarification:
- "Add validation" — ask: what inputs, what error format, where to surface errors?
- "Refactor this" — ask: optimize for readability, performance, or testability?
- "Fix the bug" — ask: what is the expected vs. actual behavior?

Do NOT start implementing until the interpretation is confirmed.

## 2. Simplicity First

If you wrote 200 lines and it could be 50, rewrite it.
Prefer the fewest lines that correctly express the intent.

- No helper functions unless used in 3+ places
- No abstractions introduced for hypothetical future use
- No half-finished implementations
- No feature flags or backwards-compatibility shims when you can just change the code

## 3. Surgical Changes

Every changed line must trace directly to the user's request.

- Do NOT fix unrelated style, naming, or dead code unless explicitly asked
- Do NOT add imports, types, or variables not required by the change
- Only remove orphans (imports, vars, functions) that your own changes made unused
- If you notice unrelated rough edges, mention them — do not fix them

## 4. No Unnecessary Comments

Default to writing no comments.

Only add a comment when the WHY is non-obvious:
- A hidden constraint
- A subtle invariant
- A workaround for a specific bug
- Behavior that would surprise a reader

Do NOT write comments that:
- Explain WHAT the code does (well-named identifiers already do that)
- Reference the current task ("added for issue #123", "used by the auth flow")
- Summarize a block of code that is already readable

## 5. Error Handling

Do not add error handling, fallbacks, or validation for scenarios that cannot happen.

- Trust internal code and framework guarantees
- Only validate at system boundaries: user input, external APIs, file I/O
- Do not wrap every internal function call in try/catch "just in case"

## 6. Goal-Driven Execution

Reframe vague tasks as testable ones before starting:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"

For multi-step work, write a plan with explicit verifications:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```
