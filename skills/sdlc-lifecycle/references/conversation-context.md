# Conversation Context Template & Protocol

The `conversation-context.md` file serves as the externalized, persistent working memory for agentic engineering workflows. It prevents memory drift across turns, context compactions, and multi-day session restarts.

---

## 1. Interaction Protocol

1. **Session Kickoff**: At the start of a conversation, check whether `conversation-context.md` exists. If not, prompt the user:
   > "Save context to `conversation-context.md` for future sessions? (Yes/No)"
2. **Review Before Action**: If "Yes" or already present, read and absorb the context before proposing architectural solutions or making modifications.
3. **Synchronous Updates**: Update sections as soon as key decisions, architectural shifts, or task completions occur.
4. **Append-Only History**: Never delete outdated decisions; strike them through (`~~outdated decision~~`) and append the updated rationale to preserve reasoning provenance.
5. **Session Wrap-Up Confirmation**: At the end of every active session, synchronize final decisions, next steps, and confirm the update explicitly to the user.

---

## 2. Document Template

```markdown
# Conversation Context

## Objectives
- [High-level goal 1]
- [Deliverable 2]

## Background & Assumptions
- [Architectural foundation or domain context]
- [Scope boundaries: what is included, what must remain untouched]

## Decisions Made
- **[Topic 1]**: [Decision rationale and trade-offs considered]
- **[Topic 2]**: [Decision rationale and trade-offs considered]

## Preferences / Working Style
- [User formatting preferences, framework conventions, review cadence]

## Key Facts & Constraints
- [Toolchain versions (e.g., Flutter 3.27, Python 3.12, AGP 9)]
- [Hardware / Platform constraints (e.g., on-device only, zero external APIs)]
- [Key paths and file locations]

## Open Questions / Risks / Dependencies
- [Unresolved requirements or upstream blockers]
- [Potential technical risks and mitigation paths]

## Action Items & Next Steps
- [x] [Completed task 1]
- [x] [Completed task 2]
- [ ] [Pending task 3]

## Chronological Summary
- **Turn 1**: [Brief description of what was explored or agreed upon]
- **Turn 2**: [Key actions performed and artifacts created]
- **Turn 3**: [Testing, verification, or refinement results]
```

