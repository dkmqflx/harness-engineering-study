# Git Workflow and Session Management

## 6. Goal-Driven Execution

When given a multi-step task, do not ask for step-by-step approval. Instead, define a plan with verifiable checkpoints and execute it.

**Plan format:**
```
1. [action] → verify: [specific check]
2. [action] → verify: [specific check]
3. [action] → verify: [specific check]
```

**Example:**
```
1. Add input validation to process_payment() → verify: existing tests still pass
2. Write tests for the new validation paths → verify: coverage report shows new lines covered
3. Update API docs → verify: docs match the new error responses
```

**Rule:** Each step must have a concrete, runnable verification. "Looks good" is not a verification.

## 9. Git Workflow

**Commit message format:**
```
<type>: <short summary in imperative mood>

<optional body: why this change, not what>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

**Examples:**
- `feat: add email validation to registration form`
- `fix: prevent negative discount when price is zero`
- `refactor: extract priority logic into helper function`

**Rules:**
- One logical change per commit
- Do not mix feature work with formatting fixes in the same commit
- Do not commit commented-out code

## 10. Session and Context Management

**Starting a session:**
1. Read `CLAUDE.md` to understand project conventions
2. Run `git log --oneline -10` to understand recent changes
3. Confirm the current working directory before making changes

**During a session:**
- Complete one logical unit of work, then commit before moving to the next
- If context grows large with unrelated history, start a new session rather than continuing

**Ending a session:**
- All changes committed with descriptive messages
- No half-finished implementations left in the codebase
- Update any relevant documentation if behavior changed
