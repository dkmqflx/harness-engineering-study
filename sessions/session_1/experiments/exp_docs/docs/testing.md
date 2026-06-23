# Error Handling and Testing

## 5. Error Handling

Only handle errors at system boundaries. Do not add defensive try/catch inside internal code.

**System boundaries (handle here):**
- User input parsing
- External API calls
- File I/O and database queries
- Deserialization of untrusted data

**Internal code (do NOT wrap in try/catch):**
- Pure functions with known inputs
- Internal method calls within the same module
- Framework-managed lifecycle methods

**Anti-pattern:**
```python
def calculate_total(items):
    try:                          # items is internal — no need
        return sum(item.price for item in items)
    except Exception as e:
        return 0                  # silently swallows bugs
```

## 7. Testing

Write tests before or alongside implementation. Tests define the contract; implementation satisfies it.

**What to test:**
- Happy path with representative inputs
- Boundary conditions (empty, null, zero, max)
- Error cases that the function is expected to handle

**What NOT to test:**
- Internal implementation details (private methods, internal state)
- Framework behavior (e.g., that ORM correctly saves to DB)
- Scenarios that require mocking 3 or more layers

**Test naming:** `test_<function>_<condition>_<expected>` — e.g., `test_calculate_discount_negative_price_raises_value_error`

**Anti-pattern:** Writing tests after implementation that only test the happy path.
