# Comments and Code Style

## 4. No Unnecessary Comments

Default to writing zero comments. Code should be self-documenting through naming.

**When a comment IS appropriate:**
- A non-obvious constraint: `// must run before DB migration due to schema lock`
- A subtle invariant: `// list is guaranteed sorted by the caller`
- A workaround for a specific external bug: `// Safari 16 breaks flex gap in nested grids`

**When a comment is NOT appropriate:**
- Explaining what the code does: `// increment counter` above `count++`
- Naming the caller: `// used by AuthService`
- Describing the task: `// added for issue #123`
- Restating the function signature as a docstring

**Anti-pattern:**
```python
# This function calculates the discount based on user type
def calculate_discount(price, user_type):
```

## 8. Code Style

Follow the conventions already present in the file. Do not introduce new patterns unless the existing ones are absent.

**Naming:**
- Functions and variables: `snake_case` in Python, `camelCase` in JavaScript/TypeScript
- Classes: `PascalCase` in all languages
- Constants: `UPPER_SNAKE_CASE`
- Boolean variables: prefix with `is_`, `has_`, `can_`, `should_`

**Structure:**
- One concept per function
- Functions longer than 20 lines are a signal to decompose
- Maximum nesting depth: 3 levels. If deeper, extract a function.

**Imports:** Group in order — standard library, third-party, local. Alphabetical within each group.
