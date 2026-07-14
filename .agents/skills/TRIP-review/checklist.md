# Code Review Checklist

This file is the **single source of truth** for code-review criteria. Both human-driven reviews via `.agents/skills/TRIP-review` and Codex-driven reviews via `.agents/skills/codex-code-review` apply the criteria below — referenced, not copied — so the two review surfaces cannot drift.

## Systematic Review Checklist

### 1. Functional Requirements

- [ ] Implementation logic matches requirements correctly
- [ ] Interface/API matches documented specifications
- [ ] Error scenarios handled with proper feedback
- [ ] Edge cases and boundary conditions validated

### 2. Code Quality

- [ ] Proper typing (no unjustified dynamic types)
- [ ] DRY principle - no code duplication
- [ ] KISS principle - not unnecessarily complex
- [ ] Consistent, descriptive naming conventions
- [ ] Complex logic has explanatory comments
- [ ] Files/modules not excessively large
- [ ] Imports/includes organized, unused ones removed

### 3. Architectural Compliance

- [ ] Code follows established patterns from ARCHI.md
- [ ] Proper separation of concerns
- [ ] Appropriate abstractions used
- [ ] Consistent with existing codebase style

### 4. LIFEPUNCH / CVL compliance

- [ ] Economy/donor/config changes cite the matching skill and do not invent exceptions
- [ ] No AI attribution on any git surface; author identity respected in the change set
- [ ] Sensor Law: behavioral claims in the CR cite a real sensor (test count, compile, screenshot)
- [ ] Editor sync acknowledged when runtime proof was required
- [ ] Proprietary header present on new LifePunch-authored source files

### 5. Error Handling

- [ ] Errors are properly caught and handled
- [ ] Error messages are clear and actionable
- [ ] Failure modes are graceful
- [ ] Logging is appropriate (not too verbose, not silent)

### 6. Security (if applicable)

- [ ] Input validation implemented
- [ ] No sensitive data exposed
- [ ] Authentication/authorization respected
- [ ] No obvious vulnerabilities

### 7. Performance

- [ ] No obvious performance issues
- [ ] Resource cleanup implemented (no leaks)
- [ ] Appropriate data structures used
- [ ] No unnecessary operations in hot paths

---

## Issue Severity Classification

**Critical (Block Deployment)**:

- Security vulnerabilities
- Data corruption risks
- Breaking API/interface changes
- Authentication bypasses

**Major (Require Immediate Fix)**:

- Incorrect business logic
- Significant performance degradation
- Missing error handling
- Compilation/build errors

**Minor (Should Fix)**:

- Code style inconsistencies
- Missing documentation
- Code duplication
- Missing edge case handling

**Suggestions (Nice to Have)**:

- Performance optimizations
- Readability improvements
- Additional test coverage

---

## Review Completion Criteria (Approval Gate)

Minimum for approval:

- [ ] All functional requirements implemented
- [ ] No critical or major issues remaining
- [ ] Build/compilation successful
- [ ] Affected unit tests pass (per the TRIP-2 testing gate)
- [ ] New logic has test coverage (or a coverage-debt ledger entry per the hard-to-cover policy)
- [ ] Documentation updated per project standards
