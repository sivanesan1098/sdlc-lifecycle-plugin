# SDLC Lifecycle Rules & Engineering Principles

When this plugin is active, adhere to the following spec-driven engineering rules across all feature planning, execution, and verification tasks:

## 1. The 3-Document Anchoring Protocol

For any non-trivial feature, complex task, or architectural refactor, maintain these three synchronized artifacts:
- **`conversation-context.md`** (Session Memory): Ask the user at the start of new sessions whether to maintain it. Update it synchronously after key decisions and at the end of every active turn.
- **`PLAN.md`** (Architectural Specification): Align on architecture, interfaces, and scope boundaries before writing production code.
- **`TRACKER.md`** (Execution Dashboard): Decompose `PLAN.md` into numbered milestones (`M1`, `M2`, etc.) with explicit checkboxes (`- [ ]` / `- [x]`) and percentage completion tracking.

## 2. Scope Boundary Protection

- Clearly distinguish newly created modules from existing legacy code.
- Never modify or refactor legacy components designated as out-of-scope without explicit user approval.
- Isolate new feature code into dedicated directories or sub-packages.

## 3. Visual & UX Prototyping First

- When building visual or user-facing applications (mobile, web, desktop), generate visual UI prototypes (e.g. using Stitch MCP) before writing front-end code.
- Extract design tokens (color palette, typography, layout states, progress indicators) directly from generated screens to avoid UI drift.

## 4. Multi-Tier Quality Verification Gates

Never consider a milestone or feature complete without passing all relevant quality gates:
1. **Static Analysis Gate**: Zero errors or warnings on project linters (`flutter analyze`, `eslint`, `ruff`, etc.).
2. **Automated Test Gate**: 100% pass rate on unit, integration, or parity test suites.
3. **Runtime / Device Gate**: When developing mobile or client apps, verify on connected physical hardware (or emulators) with display mirroring (e.g. `scrcpy` / ADB).
4. **Build Optimization Gate**: For release artifacts, configure proper obfuscation, keep rules (ProGuard/R8), and verify minified binary output.

## 5. Version Control & Repository Hygiene

- Refine `.gitignore` to prevent committing build caches, IDE metadata, temporary MCP assets, secret keys, or local session notes.
- Use atomic, descriptive conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Always verify working tree cleanliness (`git status`) before and after operations.
