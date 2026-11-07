# Conversation Context

## Objectives
- Make `sdlc-lifecycle-plugin` installable and usable across major AI agent harnesses:
  - Claude Code
  - OpenAI Codex
  - OpenCode
  - jcode
  - Cursor
  - Antigravity
  - Windsurf & GitHub Copilot
  - Universal open-standard Agent Skills harnesses (`.agents/`)
- Provide multi-harness manifests, discovery paths, rule files, and commands.
- Provide a robust cross-platform automated installer (`install.sh` and `install.ps1`) for seamless global and project-level installation.
- Update documentation (`README.md`) with explicit installation and usage guides for each harness.

## Background & Assumptions
- Current repository was originally an Antigravity plugin containing `plugin.json`, `rules/AGENTS.md`, and `skills/sdlc-lifecycle/`.
- Major AI agent harnesses have distinct discovery paths:
  - **Claude Code**: `.claude-plugin/plugin.json`, `marketplace.json`, `commands/sdlc.md`, `CLAUDE.md`, `~/.claude/skills/`.
  - **OpenAI Codex**: `codex.json`, `~/.codex/skills/`, root `AGENTS.md`.
  - **OpenCode**: `opencode.json`, `~/.config/opencode/skills/`, `.opencode/skills/`, fallback to `.agents/skills/` and `AGENTS.md`.
  - **jcode**: Rust terminal agent discovering `~/.jcode/skills/`, `.jcode/skills/`, `.agents/skills/`, and root `AGENTS.md`.
  - **Cursor**: `.cursor/rules/*.mdc` and `.cursorrules`.
  - **Windsurf & Copilot**: `.windsurfrules` and `.github/copilot-instructions.md`.
  - **Universal Standard**: `.agents/skills/sdlc-lifecycle/SKILL.md` and root `AGENTS.md`.

## Decisions Made
- **Cross-Harness Polyglot Architecture**: Maintained single canonical skill source (`skills/sdlc-lifecycle/`) while adding dedicated adapter manifests:
  - `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` for Claude Code plugin marketplace.
  - `commands/sdlc.md` for `/sdlc` slash command.
  - `codex.json` for OpenAI Codex.
  - `opencode.json` for OpenCode.
  - Root `AGENTS.md` and `CLAUDE.md` for zero-configuration repository detection.
  - `.cursor/rules/sdlc-lifecycle.mdc` for Cursor IDE.
  - `.windsurfrules` and `.github/copilot-instructions.md` for additional IDE assistants.
- **Universal Installer Engine**:
  - `install.sh`: Fully featured POSIX script supporting `--all`, `--claude`, `--codex`, `--opencode`, `--jcode`, `--cursor`, `--antigravity`, `--target <name>`, `--global`, `--project <dir>`, `--symlink`, `--copy`, `--status`, `--uninstall`, and `--dry-run`.
  - `install.ps1`: Feature-equivalent PowerShell installer for Windows developers.
- **Automated Verification Gate**: Built `test/test_installer.sh` that validates dry-run, project symlink/copy, global mock installation, status reporting, and uninstallation across mock harnesses.

## Preferences / Working Style
- Strict adherence to the 3-Document Anchoring Protocol (`conversation-context.md`, `PLAN.md`, `TRACKER.md`).
- Multi-tier quality verification: syntax validation, script linting, end-to-end installer dry-run / execution verification.
- Version control hygiene: conventional commits, clean git working tree.

## Key Facts & Constraints
- Working Directory: `/Users/sivanesandharumadurai/Projects/sdlc-lifecycle-plugin`
- Test suite pass rate: 100% across all 6 test suites.
- JSON validity: 100% valid on all 5 manifests.

## Open Questions / Risks / Dependencies
- None. All harnesses verified and tested cleanly.

## Action Items & Next Steps
- [x] Query user for `conversation-context.md` confirmation.
- [x] Initialize `conversation-context.md`.
- [x] Create `PLAN.md` defining multi-harness architecture and verification gates.
- [x] Create `TRACKER.md` tracking milestones M1 to M5.
- [x] Implement Claude Code manifest (`.claude-plugin/plugin.json`, `marketplace.json`) and command (`commands/sdlc.md`).
- [x] Implement root `AGENTS.md`, `CLAUDE.md`, and Cursor rule (`.cursor/rules/sdlc-lifecycle.mdc`).
- [x] Implement `codex.json` and `opencode.json`.
- [x] Implement universal installer script (`install.sh` and `install.ps1`).
- [x] Author automated test suite `test/test_installer.sh` and pass 100% of quality verification gates.
- [x] Update `README.md` with multi-harness installation documentation and Windows PowerShell guide.
- [x] Commit all changes with atomic conventional commits.

## Chronological Summary
- **Turn 1**: Asked user for confirmation to maintain `conversation-context.md`.
- **Turn 2**: User confirmed "yes". Researched ecosystem requirements for Claude Code, Codex, OpenCode, and jcode. Established `conversation-context.md`, `PLAN.md`, and `TRACKER.md`. Implemented multi-harness manifests, root rules, slash commands, installer scripts (`install.sh`, `install.ps1`), test suite, and updated documentation. Verified 100% test pass rate.
