#!/usr/bin/env bash
# ==============================================================================
# Multi-Harness Installer Automated Test Suite
# Tests dry-run, global installation, project-level installation, symlink/copy,
# status reporting, and clean uninstallation across all harnesses.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="${SCRIPT_DIR}/install.sh"
TEMP_TEST_ROOT="$(mktemp -d -t sdlc-test-XXXXXX)"

cleanup() {
  rm -rf "${TEMP_TEST_ROOT}"
}
trap cleanup EXIT

echo "=== Running Multi-Harness Installer Test Suite ==="
echo "Test workspace: ${TEMP_TEST_ROOT}"

# Assert helper
assert_exists() {
  local target="$1"
  local label="$2"
  if [ -e "${target}" ] || [ -L "${target}" ]; then
    echo "  [PASS] ${label} exists: ${target}"
  else
    echo "  [FAIL] ${label} MISSING: ${target}" >&2
    exit 1
  fi
}

assert_not_exists() {
  local target="$1"
  local label="$2"
  if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
    echo "  [PASS] ${label} cleanly removed: ${target}"
  else
    echo "  [FAIL] ${label} STILL EXISTS: ${target}" >&2
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Test 1: Help and dry-run output
# ------------------------------------------------------------------------------
echo ""
echo "Test 1: Help & Dry-Run flags"
"${INSTALLER}" --help >/dev/null
echo "  [PASS] --help exited with code 0"

"${INSTALLER}" --dry-run --all >/dev/null
echo "  [PASS] --dry-run --all exited with code 0"

# ------------------------------------------------------------------------------
# Test 2: Project-level installation (symlink mode)
# ------------------------------------------------------------------------------
echo ""
echo "Test 2: Project-level installation (symlink mode)"
MOCK_PROJECT="${TEMP_TEST_ROOT}/mock-project-symlink"
mkdir -p "${MOCK_PROJECT}"

"${INSTALLER}" --project "${MOCK_PROJECT}" --all --symlink >/dev/null

assert_exists "${MOCK_PROJECT}/.claude/skills/sdlc-lifecycle/SKILL.md" "Claude Code skill"
assert_exists "${MOCK_PROJECT}/commands/sdlc.md" "Claude Code command"
assert_exists "${MOCK_PROJECT}/CLAUDE.md" "Claude Code project instructions"
assert_exists "${MOCK_PROJECT}/.codex/skills/sdlc-lifecycle/SKILL.md" "OpenAI Codex skill"
assert_exists "${MOCK_PROJECT}/.opencode/skills/sdlc-lifecycle/SKILL.md" "OpenCode skill"
assert_exists "${MOCK_PROJECT}/.jcode/skills/sdlc-lifecycle/SKILL.md" "jcode skill"
assert_exists "${MOCK_PROJECT}/.cursor/rules/sdlc-lifecycle.mdc" "Cursor MDC rule"
assert_exists "${MOCK_PROJECT}/.agents/skills/sdlc-lifecycle/SKILL.md" "Agent Skills standard"
assert_exists "${MOCK_PROJECT}/AGENTS.md" "Root AGENTS.md rules"

# Check status reporting on project
"${INSTALLER}" --status --project "${MOCK_PROJECT}" >/dev/null
echo "  [PASS] --status on project exited with code 0"

# ------------------------------------------------------------------------------
# Test 3: Project-level uninstall
# ------------------------------------------------------------------------------
echo ""
echo "Test 3: Project-level uninstallation"
"${INSTALLER}" --project "${MOCK_PROJECT}" --uninstall --all >/dev/null

assert_not_exists "${MOCK_PROJECT}/.claude/skills/sdlc-lifecycle" "Claude Code skill"
assert_not_exists "${MOCK_PROJECT}/commands/sdlc.md" "Claude Code command"
assert_not_exists "${MOCK_PROJECT}/.codex/skills/sdlc-lifecycle" "OpenAI Codex skill"
assert_not_exists "${MOCK_PROJECT}/.opencode/skills/sdlc-lifecycle" "OpenCode skill"
assert_not_exists "${MOCK_PROJECT}/.jcode/skills/sdlc-lifecycle" "jcode skill"
assert_not_exists "${MOCK_PROJECT}/.cursor/rules/sdlc-lifecycle.mdc" "Cursor rule"
assert_not_exists "${MOCK_PROJECT}/.agents/skills/sdlc-lifecycle" "Agent Skills directory"

# ------------------------------------------------------------------------------
# Test 4: Project-level installation (copy mode)
# ------------------------------------------------------------------------------
echo ""
echo "Test 4: Project-level installation (copy mode)"
MOCK_PROJECT_COPY="${TEMP_TEST_ROOT}/mock-project-copy"
mkdir -p "${MOCK_PROJECT_COPY}"

"${INSTALLER}" --project "${MOCK_PROJECT_COPY}" --claude --cursor --opencode --copy >/dev/null

assert_exists "${MOCK_PROJECT_COPY}/.claude/skills/sdlc-lifecycle/SKILL.md" "Claude Code copied skill"
assert_exists "${MOCK_PROJECT_COPY}/commands/sdlc.md" "Claude Code copied command"
assert_exists "${MOCK_PROJECT_COPY}/.cursor/rules/sdlc-lifecycle.mdc" "Cursor copied rule"
assert_exists "${MOCK_PROJECT_COPY}/.opencode/skills/sdlc-lifecycle/SKILL.md" "OpenCode copied skill"

# Verify they are regular files, not symlinks
if [ -L "${MOCK_PROJECT_COPY}/commands/sdlc.md" ]; then
  echo "  [FAIL] Expected regular copied file, found symlink!" >&2
  exit 1
fi
echo "  [PASS] Confirmed files copied cleanly without symlinks"

# ------------------------------------------------------------------------------
# Test 5: Global mock installation (overriding HOME)
# ------------------------------------------------------------------------------
echo ""
echo "Test 5: Global mock installation"
MOCK_HOME="${TEMP_TEST_ROOT}/mock-home"
mkdir -p "${MOCK_HOME}"

# Run installer in mock home
HOME="${MOCK_HOME}" "${INSTALLER}" --global --all --symlink >/dev/null

assert_exists "${MOCK_HOME}/.claude/skills/sdlc-lifecycle/SKILL.md" "Global Claude Code skill"
assert_exists "${MOCK_HOME}/.claude/commands/sdlc.md" "Global Claude Code command"
assert_exists "${MOCK_HOME}/.claude/plugins/sdlc-lifecycle/.claude-plugin/plugin.json" "Global Claude Code plugin manifest"
assert_exists "${MOCK_HOME}/.codex/skills/sdlc-lifecycle/SKILL.md" "Global OpenAI Codex skill"
assert_exists "${MOCK_HOME}/.config/opencode/skills/sdlc-lifecycle/SKILL.md" "Global OpenCode skill"
assert_exists "${MOCK_HOME}/.jcode/skills/sdlc-lifecycle/SKILL.md" "Global jcode skill"
assert_exists "${MOCK_HOME}/.gemini/config/plugins/sdlc-lifecycle-plugin/plugin.json" "Global Antigravity plugin"
assert_exists "${MOCK_HOME}/.agents/skills/sdlc-lifecycle/SKILL.md" "Global Agent Skills"

# Test global uninstall
echo ""
echo "Test 6: Global mock uninstallation"
HOME="${MOCK_HOME}" "${INSTALLER}" --global --uninstall --all >/dev/null

assert_not_exists "${MOCK_HOME}/.claude/skills/sdlc-lifecycle" "Global Claude Code skill"
assert_not_exists "${MOCK_HOME}/.claude/commands/sdlc.md" "Global Claude Code command"
assert_not_exists "${MOCK_HOME}/.codex/skills/sdlc-lifecycle" "Global Codex skill"
assert_not_exists "${MOCK_HOME}/.config/opencode/skills/sdlc-lifecycle" "Global OpenCode skill"
assert_not_exists "${MOCK_HOME}/.jcode/skills/sdlc-lifecycle" "Global jcode skill"
assert_not_exists "${MOCK_HOME}/.gemini/config/plugins/sdlc-lifecycle-plugin" "Global Antigravity plugin"
assert_not_exists "${MOCK_HOME}/.agents/skills/sdlc-lifecycle" "Global Agent Skills"

echo ""
echo "=== All Installer Tests Passed Successfully (100%) ==="
