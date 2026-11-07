#!/usr/bin/env bash
# ==============================================================================
# SDLC Lifecycle Plugin - Multi-Harness Universal Installer
# Supports: Claude Code, OpenAI Codex, OpenCode, jcode, Cursor, Antigravity,
#           and open-standard Agent Skills (.agents/).
# ==============================================================================

set -eo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
DIM="\033[2m"
NC="\033[0m"

REPO_URL="https://github.com/sivanesan1098/sdlc-lifecycle-plugin.git"
REPO_NAME="sdlc-lifecycle-plugin"

# Execution state
SCOPE="global"
PROJECT_DIR=""
MODE="symlink"
ACTION="install"
DRY_RUN=0

# Target selectors
TARGET_ALL=0
TARGET_CLAUDE=0
TARGET_CODEX=0
TARGET_OPENCODE=0
TARGET_JCODE=0
TARGET_CURSOR=0
TARGET_ANTIGRAVITY=0
TARGET_AGENTS=0

print_banner() {
    printf "${CYAN}${BOLD}"
    cat << 'EOF'
  ____  ____  _      ____   _     _  __                  _      
 / ___||  _ \| |    / ___| | |   (_)/ _| ___  ___ _   _  | | ___ 
 \___ \| | | | |   | |     | |   | | |_ / _ \/ __| | | | | |/ _ \
  ___) | |_| | |___| |___  | |___| |  _|  __/ (__| |_| | | |  __/
 |____/|____/|_____|\____| |_____|_|_|  \___|\___|\__, | |_|\___|
                                                  |___/          
EOF
    printf "${NC}"
    printf "${BOLD}Universal Multi-Harness Agent Installer${NC}\n"
    printf "${DIM}Spec-driven 3-Document Anchoring & 7-Stage SDLC Pipeline${NC}\n\n"
}

show_help() {
    print_banner
    cat << EOF
Usage: ./install.sh [OPTIONS]

Harness Selection:
  --all                 Install across all detected agent harnesses
  --claude              Install for Claude Code
  --codex               Install for OpenAI Codex
  --opencode            Install for OpenCode
  --jcode               Install for jcode
  --cursor              Install for Cursor IDE
  --antigravity         Install for Google Antigravity
  --agents              Install to open standard Agent Skills (.agents/)
  --target <name>       Explicit single target (all, claude, codex, opencode, jcode, cursor, antigravity, agents)

Installation Scope:
  --global              Install globally to user home configs (default)
  --project <dir>       Install into a specific project workspace directory

Mode & Actions:
  --symlink             Create symlinks (default)
  --copy                Copy files instead of symlinking
  --dry-run             Simulate changes without modifying filesystem
  --status, --verify    Report installation health across harnesses
  --uninstall           Remove installed SDLC plugin configurations
  -h, --help            Show this help message

Examples:
  ./install.sh --all                         # Install to all harnesses
  ./install.sh --claude --cursor             # Install for Claude Code & Cursor
  ./install.sh --project ./my-repo --all     # Install into local repository workspace
  ./install.sh --status                      # Check global installation status
  ./install.sh --status --project ./my-repo  # Check project installation status
  ./install.sh --uninstall --all             # Remove all global installations
EOF
    exit 0
}

# Parse flags
while [ $# -gt 0 ]; do
    case "$1" in
        --all)
            TARGET_ALL=1
            shift
            ;;
        --claude)
            TARGET_CLAUDE=1
            shift
            ;;
        --codex)
            TARGET_CODEX=1
            shift
            ;;
        --opencode)
            TARGET_OPENCODE=1
            shift
            ;;
        --jcode)
            TARGET_JCODE=1
            shift
            ;;
        --cursor)
            TARGET_CURSOR=1
            shift
            ;;
        --antigravity)
            TARGET_ANTIGRAVITY=1
            shift
            ;;
        --agents)
            TARGET_AGENTS=1
            shift
            ;;
        --target)
            case "$2" in
                all) TARGET_ALL=1 ;;
                claude) TARGET_CLAUDE=1 ;;
                codex) TARGET_CODEX=1 ;;
                opencode) TARGET_OPENCODE=1 ;;
                jcode) TARGET_JCODE=1 ;;
                cursor) TARGET_CURSOR=1 ;;
                antigravity) TARGET_ANTIGRAVITY=1 ;;
                agents) TARGET_AGENTS=1 ;;
                *) printf "${RED}Unknown target: $2${NC}\n"; exit 1 ;;
            esac
            shift 2
            ;;
        --global)
            SCOPE="global"
            shift
            ;;
        --project)
            SCOPE="project"
            PROJECT_DIR="$2"
            shift 2
            ;;
        --symlink)
            MODE="symlink"
            shift
            ;;
        --copy)
            MODE="copy"
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --status|--verify)
            ACTION="status"
            shift
            ;;
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            printf "${RED}Unknown option: $1${NC}\n"
            show_help
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
SKILL_DIR="${SCRIPT_DIR}/skills/sdlc-lifecycle"
RULES_FILE="${SCRIPT_DIR}/AGENTS.md"
CLAUDE_FILE="${SCRIPT_DIR}/CLAUDE.md"
CURSOR_RULE="${SCRIPT_DIR}/.cursor/rules/sdlc-lifecycle.mdc"
CLAUDE_COMMAND="${SCRIPT_DIR}/commands/sdlc.md"
PLUGIN_MANIFEST="${SCRIPT_DIR}/plugin.json"
CLAUDE_PLUGIN_DIR="${SCRIPT_DIR}/.claude-plugin"

detect_harnesses() {
    detected=()
    if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]; then
        detected+=("claude")
    fi
    if command -v codex >/dev/null 2>&1 || [ -d "$HOME/.codex" ]; then
        detected+=("codex")
    fi
    if command -v opencode >/dev/null 2>&1 || [ -d "$HOME/.config/opencode" ]; then
        detected+=("opencode")
    fi
    if command -v jcode >/dev/null 2>&1 || [ -d "$HOME/.jcode" ]; then
        detected+=("jcode")
    fi
    if command -v cursor >/dev/null 2>&1 || [ -d "$HOME/.cursor" ]; then
        detected+=("cursor")
    fi
    if [ -d "$HOME/.gemini" ] || command -v agy >/dev/null 2>&1; then
        detected+=("antigravity")
    fi
    detected+=("agents")
}

safe_link_or_copy() {
    local src="$1"
    local dest="$2"
    local is_dir="${3:-false}"

    if [ "$DRY_RUN" -eq 1 ]; then
        printf "  ${CYAN}[DRY-RUN]${NC} %s '%s' -> '%s'\n" "$MODE" "$src" "$dest"
        return 0
    fi

    local parent
    parent="$(dirname "$dest")"
    mkdir -p "$parent"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    if [ "$MODE" = "symlink" ]; then
        ln -s "$src" "$dest"
        printf "  ${GREEN}✓${NC} Linked: %s -> %s\n" "$dest" "$src"
    else
        if [ "$is_dir" = "true" ]; then
            cp -R "$src" "$dest"
        else
            cp "$src" "$dest"
        fi
        printf "  ${GREEN}✓${NC} Copied: %s\n" "$dest"
    fi
}

safe_remove() {
    local target="$1"
    case "$target" in
        "$SCRIPT_DIR"/*|"$SCRIPT_DIR"|"$SCRIPT_DIR/."*)
            return 0
            ;;
    esac
    if [ "$DRY_RUN" -eq 1 ]; then
        printf "  ${CYAN}[DRY-RUN]${NC} Remove '%s'\n" "$target"
        return 0
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
        printf "  ${YELLOW}✗${NC} Removed: %s\n" "$target"
    fi
}

report_status() {
    printf "${BOLD}================================================================${NC}\n"
    printf "${BOLD}       SDLC Lifecycle Plugin - Harness Installation Status       ${NC}\n"
    printf "${BOLD}================================================================${NC}\n"

    check_row() {
        local name="$1"
        local path="$2"
        if [ -e "$path" ] || [ -L "$path" ]; then
            printf "  ${GREEN}✓${NC} %-18s [Installed]     : %s\n" "$name" "$path"
        else
            printf "  ${DIM}○${NC} %-18s [Not installed] : %s\n" "$name" "$path"
        fi
    }

    if [ -n "$PROJECT_DIR" ]; then
        printf "${CYAN}Project Scope: %s${NC}\n" "$PROJECT_DIR"
        check_row "Claude Code Skill" "${PROJECT_DIR}/.claude/skills/sdlc-lifecycle/SKILL.md"
        check_row "Claude Command"    "${PROJECT_DIR}/commands/sdlc.md"
        check_row "Claude Config"     "${PROJECT_DIR}/CLAUDE.md"
        check_row "OpenAI Codex"      "${PROJECT_DIR}/.codex/skills/sdlc-lifecycle/SKILL.md"
        check_row "OpenCode"          "${PROJECT_DIR}/.opencode/skills/sdlc-lifecycle/SKILL.md"
        check_row "jcode"             "${PROJECT_DIR}/.jcode/skills/sdlc-lifecycle/SKILL.md"
        check_row "Cursor Rule"       "${PROJECT_DIR}/.cursor/rules/sdlc-lifecycle.mdc"
        check_row "Agent Skills"      "${PROJECT_DIR}/.agents/skills/sdlc-lifecycle/SKILL.md"
        check_row "Root AGENTS.md"    "${PROJECT_DIR}/AGENTS.md"
    else
        printf "${CYAN}Global Scope (~/)${NC}\n"
        check_row "Claude Code Skill" "$HOME/.claude/skills/sdlc-lifecycle/SKILL.md"
        check_row "Claude Command"    "$HOME/.claude/commands/sdlc.md"
        check_row "Claude Plugin"     "$HOME/.claude/plugins/sdlc-lifecycle/plugin.json"
        check_row "OpenAI Codex"      "$HOME/.codex/skills/sdlc-lifecycle/SKILL.md"
        check_row "OpenCode"          "$HOME/.config/opencode/skills/sdlc-lifecycle/SKILL.md"
        check_row "jcode"             "$HOME/.jcode/skills/sdlc-lifecycle/SKILL.md"
        check_row "Antigravity"       "$HOME/.gemini/config/plugins/sdlc-lifecycle-plugin/plugin.json"
        check_row "Agent Skills"      "$HOME/.agents/skills/sdlc-lifecycle/SKILL.md"
    fi
    printf "${BOLD}================================================================${NC}\n"
}

main() {
    if [ "$ACTION" = "status" ]; then
        report_status
        exit 0
    fi

    # Determine target list
    ACTIVE_TARGETS=()
    if [ "$TARGET_ALL" -eq 1 ]; then
        ACTIVE_TARGETS=("claude" "codex" "opencode" "jcode" "cursor" "antigravity" "agents")
    else
        [ "$TARGET_CLAUDE" -eq 1 ] && ACTIVE_TARGETS+=("claude")
        [ "$TARGET_CODEX" -eq 1 ] && ACTIVE_TARGETS+=("codex")
        [ "$TARGET_OPENCODE" -eq 1 ] && ACTIVE_TARGETS+=("opencode")
        [ "$TARGET_JCODE" -eq 1 ] && ACTIVE_TARGETS+=("jcode")
        [ "$TARGET_CURSOR" -eq 1 ] && ACTIVE_TARGETS+=("cursor")
        [ "$TARGET_ANTIGRAVITY" -eq 1 ] && ACTIVE_TARGETS+=("antigravity")
        [ "$TARGET_AGENTS" -eq 1 ] && ACTIVE_TARGETS+=("agents")

        if [ ${#ACTIVE_TARGETS[@]} -eq 0 ]; then
            detect_harnesses
            ACTIVE_TARGETS=("${detected[@]}")
            printf "${BLUE}ℹ Auto-detected agent harnesses: %s${NC}\n" "${ACTIVE_TARGETS[*]}"
        fi
    fi

    if [ -n "$PROJECT_DIR" ]; then
        SCOPE="project"
    fi

    for t in "${ACTIVE_TARGETS[@]}"; do
        printf "\n"
        case "$t" in
            claude)
                printf "${BOLD}→ Target: Claude Code${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_skill="$HOME/.claude/skills/sdlc-lifecycle"
                    dest_cmd="$HOME/.claude/commands/sdlc.md"
                    dest_plug="$HOME/.claude/plugins/sdlc-lifecycle"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                        safe_remove "$dest_cmd"
                        safe_remove "$dest_plug"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$CLAUDE_COMMAND" "$dest_cmd" false
                        safe_link_or_copy "$SCRIPT_DIR" "$dest_plug" true
                        # Ensure plugin.json exists at root of plugin directory for Claude verification
                        if [ -f "$CLAUDE_PLUGIN_DIR/plugin.json" ] && [ ! -f "$dest_plug/plugin.json" ]; then
                            safe_link_or_copy "$CLAUDE_PLUGIN_DIR/plugin.json" "$dest_plug/plugin.json" false
                        fi
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_skill="${pdir}/.claude/skills/sdlc-lifecycle"
                    dest_cmd="${pdir}/commands/sdlc.md"
                    dest_claude="${pdir}/CLAUDE.md"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                        safe_remove "$dest_cmd"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$CLAUDE_COMMAND" "$dest_cmd" false
                        safe_link_or_copy "$CLAUDE_FILE" "$dest_claude" false
                    fi
                fi
                ;;
            codex)
                printf "${BOLD}→ Target: OpenAI Codex${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_skill="$HOME/.codex/skills/sdlc-lifecycle"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_skill="${pdir}/.codex/skills/sdlc-lifecycle"
                    dest_agents="${pdir}/AGENTS.md"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$RULES_FILE" "$dest_agents" false
                    fi
                fi
                ;;
            opencode)
                printf "${BOLD}→ Target: OpenCode${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_skill="$HOME/.config/opencode/skills/sdlc-lifecycle"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_skill="${pdir}/.opencode/skills/sdlc-lifecycle"
                    dest_agents="${pdir}/AGENTS.md"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$RULES_FILE" "$dest_agents" false
                    fi
                fi
                ;;
            jcode)
                printf "${BOLD}→ Target: jcode${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_skill="$HOME/.jcode/skills/sdlc-lifecycle"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_skill="${pdir}/.jcode/skills/sdlc-lifecycle"
                    dest_agents="${pdir}/AGENTS.md"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$RULES_FILE" "$dest_agents" false
                    fi
                fi
                ;;
            cursor)
                printf "${BOLD}→ Target: Cursor IDE${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_rule="$HOME/.cursor/rules/sdlc-lifecycle.mdc"
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_rule="${pdir}/.cursor/rules/sdlc-lifecycle.mdc"
                fi
                if [ "$ACTION" = "uninstall" ]; then
                    safe_remove "$dest_rule"
                else
                    safe_link_or_copy "$CURSOR_RULE" "$dest_rule" false
                fi
                ;;
            antigravity)
                printf "${BOLD}→ Target: Antigravity${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_plug="$HOME/.gemini/config/plugins/sdlc-lifecycle-plugin"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_plug"
                    else
                        safe_link_or_copy "$SCRIPT_DIR" "$dest_plug" true
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_plug="${pdir}/.agents/plugins/sdlc-lifecycle-plugin"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_plug"
                    else
                        safe_link_or_copy "$SCRIPT_DIR" "$dest_plug" true
                    fi
                fi
                ;;
            agents)
                printf "${BOLD}→ Target: Universal Agent Skills (.agents/)${NC}\n"
                if [ "$SCOPE" = "global" ]; then
                    dest_skill="$HOME/.agents/skills/sdlc-lifecycle"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                    fi
                else
                    pdir="${PROJECT_DIR:-.}"
                    dest_skill="${pdir}/.agents/skills/sdlc-lifecycle"
                    dest_agents="${pdir}/AGENTS.md"
                    if [ "$ACTION" = "uninstall" ]; then
                        safe_remove "$dest_skill"
                    else
                        safe_link_or_copy "$SKILL_DIR" "$dest_skill" true
                        safe_link_or_copy "$RULES_FILE" "$dest_agents" false
                    fi
                fi
                ;;
        esac
    done

    printf "\n"
    if [ "$ACTION" = "uninstall" ]; then
        printf "${GREEN}${BOLD}✓ Uninstallation complete!${NC}\n"
    else
        printf "${GREEN}${BOLD}✓ Installation complete!${NC}\n"
        printf "${CYAN}Tip: Run ./install.sh --status at any time to inspect harness installation status.${NC}\n"
    fi
}

main "$@"
