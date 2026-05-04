# CLAUDE.md

Guidelines cut LLM coding mistakes. Merge with project-specific instructions.

**Tradeoff:** Bias toward caution over speed. Trivial tasks: use judgment.

## 1. Think Before Coding

**No assumptions. Surface confusion. State tradeoffs.**

Before + during coding:
- State assumptions. Uncertain: ask.
- Multiple interpretations: present them, don't pick silently.
- Simpler approach exists: say so. Push back.
- Unclear: stop, name what's confusing, ask.

## 2. Simplicity First

**Minimum code solving problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No unrequested "flexibility" or "configurability".
- No error handling for impossible scenarios.
- 200 lines when 50 works: rewrite.

"Would senior engineer say this is overcomplicated?" Yes → simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

Editing existing code:
- Don't improve adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style.
- Unrelated dead code: mention it, don't delete.

Your changes create orphans:
- Remove imports/variables/functions YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Every changed line traces directly to user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

Multi-step tasks: state brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong criteria = loop independently. Weak ("make it work") = constant clarification.

---

**Working if:** fewer unnecessary diff changes, fewer rewrites, clarifying questions before implementation not after.
