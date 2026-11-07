# Feature Implementation Tracker Template & Operational Protocol

The `TRACKER.md` file bridges planning (`PLAN.md`) and hands-on execution. It converts broad architectural sections into granular, verifiable milestones with interactive checklists and percentage progress bars.

---

## 1. Operational Protocol

1. **Direct Derivation from Plan**:
   - Each major section in `PLAN.md` must correspond to a distinct Milestone (`M1`, `M2`, `M3`, etc.).
   - Tasks within milestones must have clear, objective completion criteria.
2. **Synchronous Updates**:
   - Never batch updates after an entire sprint or turn. Update task checkboxes (`[x]`) and milestone percentages immediately as tasks pass verification gates.
3. **Traceability**:
   - Include direct clickable links to the files, test files, or screenshots created under each task.

---

## 2. Document Template

```markdown
# [Feature Name] Implementation Tracker

> **Source**: Generated from [PLAN.md](./PLAN.md)  
> **Target Project**: `[project_directory]`  
> **Current Status**: **[IN PROGRESS | COMPLETED] ([XX]%)**  
> **Last Updated**: [YYYY-MM-DD]  

---

## Progress Overview

| Milestone | Description | Architecture Scope | Status | Completion |
|---|---|---|:---:|:---:|
| **Milestone 1** | UI Design & Spec Alignment | [Scope] | **COMPLETED** | 100% |
| **Milestone 2** | Project Setup & Scaffolding | [Scope] | **COMPLETED** | 100% |
| **Milestone 3** | Domain Models & Services | [Scope] | **COMPLETED** | 100% |
| **Milestone 4** | Theme Tokens & Reusable UI | [Scope] | **IN PROGRESS** | 50% |
| **Milestone 5** | Core Screens Implementation | [Scope] | **PENDING** | 0% |
| **Milestone 6** | Quality Gates & Unit Tests | [Scope] | **PENDING** | 0% |
| **Milestone 7** | Physical Device Validation | [Scope] | **PENDING** | 0% |
| **Milestone 8** | Production Polish & Release Build | [Scope] | **PENDING** | 0% |

**Overall Completion**: **[XX]%**

---

## Detailed Task Checklist

### Milestone 1: [Milestone Name] (COMPLETED)
- [x] **M1.1**: [Task description] ([link_to_artifact](./path))
- [x] **M1.2**: [Task description] ([link_to_artifact](./path))

---

### Milestone 2: [Milestone Name] (IN PROGRESS)
- [x] **M2.1**: [Completed subtask]
- [ ] **M2.2**: [Pending subtask]
```

