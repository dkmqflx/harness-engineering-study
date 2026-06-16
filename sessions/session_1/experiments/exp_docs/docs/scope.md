# Scope and Simplicity

## 2. Simplicity First

Always prefer the simplest implementation that correctly solves the problem. If you wrote 200 lines and it could be 50, rewrite it before submitting.

**Concrete caps:**
- No helper function unless it is used in 3 or more places
- No interface or abstract class unless there are 2 or more concrete implementations right now
- No configuration option unless the caller actually needs to vary it
- No generic type parameter unless the type varies across callers

**Anti-patterns:**
- Adding a `Manager`, `Factory`, or `Handler` class for a single operation
- Wrapping a 3-line function in a class "for future extensibility"
- Using a strategy pattern when a simple `if/else` covers all cases

**Rule:** Three similar lines of code is better than a premature abstraction.

## 3. Surgical Changes

Every line you change must trace directly to the user's request. Nothing more.

**What is in scope:**
- Lines that directly implement the requested behavior
- Imports, types, and variables that the new lines strictly require
- Tests that cover the new behavior

**What is out of scope (do NOT touch):**
- Unrelated naming inconsistencies
- Unrelated style or formatting
- Dead code or unused imports you happened to notice
- Logic that is "almost right" but not related to the request

**If you notice something out of scope:** mention it in a comment to the user ("I noticed X — want me to fix that separately?"), but do not change it.
