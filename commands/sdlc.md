---
description: Execute or audit the 7-Stage SDLC Lifecycle with the 3-Document Anchoring System (conversation-context.md, PLAN.md, TRACKER.md)
---

# SDLC Lifecycle Slash Command

You are initiating or auditing a software feature using the **SDLC Lifecycle: Spec-Driven Autonomous Feature Engineering Pipeline**.

Follow these 7 stages methodically:

## Stage 1: Context Anchoring & Session Working Memory
- Check if `conversation-context.md` exists in the project root.
- If it does not exist, ask the user:
  > "Save context to `conversation-context.md` for future sessions? (Yes/No)"
- If "Yes" or already present, read it and maintain its sections (`Objectives`, `Background & Assumptions`, `Decisions Made`, `Preferences / Working Style`, `Key Facts & Constraints`, `Open Questions / Risks / Dependencies`, `Action Items & Next Steps`, `Chronological Summary`).
- Outdated decisions must be struck through (`~~decision~~`) rather than deleted.

## Stage 2: Visual UI Prototyping First (If UI Feature)
- If the feature has a visual user interface (mobile, web, desktop), generate visual mockups or prototypes first (e.g. Stitch MCP or HTML/SVG artifacts) before writing front-end code.
- Extract design tokens: color palette, typography hierarchy, responsive breakpoints, layout states (empty, loading stepper, success, error diagnostics).

## Stage 3: Architectural Specification (PLAN.md)
- Conduct alignment interviews or design Q&A to resolve ambiguities, edge cases, data models, and scope boundaries.
- Create or update `PLAN.md` with:
  1. Executive Summary & Goals
  2. Scope & Boundaries (Explicitly delineate **In Scope** vs **Untouched Legacy Files**)
  3. Architecture & Data Flow (Mermaid diagrams, domain services, platform engines)
  4. UI / UX Design Specifications
  5. Technical Dependencies & Configurations (keep rules, permissions)
  6. Multi-Tier Verification Strategy

## Stage 4: Milestone Task Decomposition (TRACKER.md)
- Convert `PLAN.md` into granular numbered Milestones (`M1`, `M2`, `M3`, etc.) in `TRACKER.md`.
- Include an interactive Progress Overview table with percentage completion.
- List explicit checkboxes (`- [ ]` / `- [x]`) and direct artifact links for every subtask.

## Stage 5: Test-Driven Iterative Implementation
- Scaffold data models, interfaces, and domain services.
- Implement automated unit tests and parity tests before/alongside application UI.
- Never modify out-of-scope legacy files without explicit user approval.

## Stage 6: Multi-Tier Quality Verification Gates
Never mark a milestone complete without passing all applicable gates:
1. **Static Analysis Gate**: Zero errors or warnings on project linters (`flutter analyze`, `eslint`, `ruff`, `cargo clippy`, etc.).
2. **Automated Test Gate**: 100% pass rate on test suites.
3. **Runtime / Hardware Gate**: Physical device / emulator verification (e.g. ADB + `scrcpy` for mobile, browser DevTools for web).
4. **Build Optimization Gate**: Obfuscation, minification, and ProGuard/R8 verification.

## Stage 7: Production Release & Git Hygiene
- Generate necessary release assets (adaptive icons, manifest permissions).
- Clean up `.gitignore` to prevent secret, cache, or local session leaks.
- Commit working changes using atomic, conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Synchronize final status in `conversation-context.md`, `PLAN.md`, and `TRACKER.md`.
