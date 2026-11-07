# Feature Plan Template & Alignment Protocol

The `PLAN.md` file is the foundational architectural specification and requirements blueprint for a feature. It is authored prior to writing any implementation code and updated when major architectural pivots occur.

---

## 1. Creation Protocol

1. **Conduct Design Alignment First**:
   - Use interactive alignment techniques (such as `/grill-me` interviews or structured Q&A) to resolve design decisions, user stories, edge cases, and scope boundaries.
2. **Mandate Architecture Scope**:
   - Explicitly establish whether the architecture is standalone client-side (on-device), client-server, or hybrid.
   - Clarify which legacy files, databases, or existing backends must remain untouched.
3. **Define Clear Verification Gates**:
   - Define exact exit criteria for every phase (e.g., static analysis score, unit test coverage, real-world device tests).

---

## 2. Document Template

```markdown
# [Feature Name] Implementation Plan

> **Scope**: [Summary of what is being built]  
> **Architecture**: [e.g. 100% On-Device Standalone Mobile Execution]  
> **Status**: [Draft | In Progress | Completed]  
> **Last Updated**: [YYYY-MM-DD]  

---

## 1. Executive Summary & Goals
- [Core user problem being solved]
- [Primary business/technical objectives]
- [Key architectural constraints (e.g. Zero external server dependencies)]

---

## 2. Scope & Boundaries
### In Scope
- [Feature capability 1]
- [Feature capability 2]

### Out of Scope (Untouched Components)
- [List files, directories, or legacy services that must not be altered]

---

## 3. Architecture & Data Flow
- [Mermaid diagram or high-level ASCII data pipeline]
- **Component Breakdown**:
  1. **UI Layer**: [Framework, theming tokens, screens]
  2. **State Management**: [State container, reactivity model]
  3. **Domain Services**: [Network, Scraper, Parser, Cache]
  4. **Hardware / Platform Engines**: [On-device ML Kit, OCR, Camera, Storage]

---

## 4. UI / UX Design Specifications
- Reference design mockups or Stitch screens (e.g., `stitch/screens/screen_1_home.png`)
- Define theme palette (primary, secondary, surface, error)
- Define interaction states: Empty, Loading (Progress Stepper), Success/Results, Error/Diagnostics

---

## 5. Technical Specifications & Dependencies
- Core libraries, frameworks, SDK minimum versions
- Permissions required (e.g. AndroidManifest.xml / Info.plist)
- ProGuard / R8 minification keep rules

---

## 6. Testing & Quality Verification Strategy
1. **Static Analysis**: Linting and formatting with 0 errors/warnings (`flutter analyze` / `ruff` / `eslint`)
2. **Automated Unit Tests**: Parity tests comparing mobile and reference extraction logic
3. **Physical / Virtual Device Validation**: Real hardware execution via ADB + `scrcpy`
4. **Production Build Verification**: Release APK/bundle size & minification checks
```

