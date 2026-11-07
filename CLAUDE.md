# Claude Code SDLC Lifecycle Instructions

These instructions govern Claude Code sessions working within repositories utilizing the **SDLC Lifecycle**.

---

## The 3-Document Anchoring System
1. **`conversation-context.md`**:
   - At session kickoff, check if `conversation-context.md` exists. If not, prompt:
     `"Save context to conversation-context.md for future sessions? (Yes/No)"`
   - If enabled, read before taking action.
   - Update sections after key decisions; use append-only style with strike-throughs for superseded decisions.
   - Conclude sessions with a confirmed update.
2. **`PLAN.md`**:
   - Author a comprehensive architecture specification before touching production code.
   - Clarify in-scope vs. untouched legacy components and define quality exit criteria.
3. **`TRACKER.md`**:
   - Decompose `PLAN.md` into numbered milestones (`M1`, `M2`, etc.) with checkboxes and live completion percentages.

---

## Quality Verification Gates
Before marking any milestone or feature complete:
- **Static Analysis**: Zero errors or warnings on linters (`flutter analyze`, `eslint`, `ruff`, etc.).
- **Automated Tests**: 100% test pass rate.
- **Hardware/Device**: When applicable, verify on connected devices via ADB / `scrcpy`.
- **Git Hygiene**: Clean `.gitignore`, verify `git status`, and use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).

---

## References & Skill Runbook
- Skill Guide: [skills/sdlc-lifecycle/SKILL.md](./skills/sdlc-lifecycle/SKILL.md)
- Templates:
  - [skills/sdlc-lifecycle/references/conversation-context.md](./skills/sdlc-lifecycle/references/conversation-context.md)
  - [skills/sdlc-lifecycle/references/plan.md](./skills/sdlc-lifecycle/references/plan.md)
  - [skills/sdlc-lifecycle/references/tracker.md](./skills/sdlc-lifecycle/references/tracker.md)
