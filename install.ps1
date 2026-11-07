<#
.SYNOPSIS
    SDLC Lifecycle Plugin - Multi-Harness Universal Installer for Windows PowerShell.
.DESCRIPTION
    Installs the SDLC Lifecycle skill and rules to Claude Code, OpenAI Codex, OpenCode,
    jcode, Cursor, Antigravity, and open-standard Agent Skills (.agents/).
.EXAMPLE
    .\install.ps1 -All
    .\install.ps1 -Claude -OpenCode -Jcode
    .\install.ps1 -Project "C:\path\to\repo"
    .\install.ps1 -Status
    .\install.ps1 -Uninstall -All
#>

[CmdletBinding()]
param (
    [switch]$Claude,
    [switch]$Codex,
    [switch]$OpenCode,
    [switch]$Jcode,
    [switch]$Cursor,
    [switch]$Antigravity,
    [switch]$Agents,
    [switch]$All,
    [ValidateSet("global", "project")]
    [string]$Scope = "global",
    [string]$Project = "",
    [ValidateSet("symlink", "copy")]
    [string]$Mode = "symlink",
    [switch]$Status,
    [switch]$Uninstall,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillDir = Join-Path $ScriptDir "skills\sdlc-lifecycle"
$RulesFile = Join-Path $ScriptDir "AGENTS.md"
$ClaudeFile = Join-Path $ScriptDir "CLAUDE.md"
$CursorRule = Join-Path $ScriptDir ".cursor\rules\sdlc-lifecycle.mdc"
$ClaudeCommand = Join-Path $ScriptDir "commands\sdlc.md"
$UserHome = [System.Environment]::GetFolderPath("UserProfile")

function Safe-LinkOrCopy {
    param (
        [string]$Source,
        [string]$Destination,
        [bool]$IsDirectory = $false
    )

    if ($DryRun) {
        Write-Host "  [DRY-RUN] $Mode '$Source' -> '$Destination'" -ForegroundColor Cyan
        return
    }

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $Destination) {
        Remove-Item -Path $Destination -Recurse -Force | Out-Null
    }

    if ($Mode -eq "symlink") {
        try {
            if ($IsDirectory) {
                New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
            } else {
                New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
            }
            Write-Host "  ✓ Linked: $Destination -> $Source" -ForegroundColor Green
        } catch {
            Write-Host "  ! Symlink privilege not available. Falling back to copy." -ForegroundColor Yellow
            if ($IsDirectory) {
                Copy-Item -Path $Source -Destination $Destination -Recurse -Force | Out-Null
            } else {
                Copy-Item -Path $Source -Destination $Destination -Force | Out-Null
            }
            Write-Host "  ✓ Copied: $Destination" -ForegroundColor Green
        }
    } else {
        if ($IsDirectory) {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force | Out-Null
        } else {
            Copy-Item -Path $Source -Destination $Destination -Force | Out-Null
        }
        Write-Host "  ✓ Copied: $Destination" -ForegroundColor Green
    }
}

function Safe-Remove {
    param ([string]$Target)
    if ($DryRun) {
        Write-Host "  [DRY-RUN] Remove '$Target'" -ForegroundColor Cyan
        return
    }
    if (Test-Path $Target) {
        Remove-Item -Path $Target -Recurse -Force | Out-Null
        Write-Host "  ✗ Removed: $Target" -ForegroundColor Yellow
    }
}

# Auto-detect harnesses
function Detect-Harnesses {
    $detected = @()
    if ((Get-Command "claude" -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $UserHome ".claude"))) {
        $detected += "claude"
    }
    if ((Get-Command "codex" -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $UserHome ".codex"))) {
        $detected += "codex"
    }
    if ((Get-Command "opencode" -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $UserHome ".config\opencode"))) {
        $detected += "opencode"
    }
    if ((Get-Command "jcode" -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $UserHome ".jcode"))) {
        $detected += "jcode"
    }
    if (Test-Path (Join-Path $UserHome ".cursor")) {
        $detected += "cursor"
    }
    if (Test-Path (Join-Path $UserHome ".gemini")) {
        $detected += "antigravity"
    }
    $detected += "agents"
    return $detected
}

if ($Status) {
    Write-Host "================================================================" -ForegroundColor White
    Write-Host "       SDLC Lifecycle Plugin - Harness Installation Status       " -ForegroundColor White
    Write-Host "================================================================" -ForegroundColor White
    
    $checkPaths = @(
        @{ Name = "Claude Code"; Path = (Join-Path $UserHome ".claude\skills\sdlc-lifecycle"); Scope = "Global" },
        @{ Name = "OpenAI Codex"; Path = (Join-Path $UserHome ".codex\skills\sdlc-lifecycle"); Scope = "Global" },
        @{ Name = "OpenCode"; Path = (Join-Path $UserHome ".config\opencode\skills\sdlc-lifecycle"); Scope = "Global" },
        @{ Name = "jcode"; Path = (Join-Path $UserHome ".jcode\skills\sdlc-lifecycle"); Scope = "Global" },
        @{ Name = "Antigravity"; Path = (Join-Path $UserHome ".gemini\config\plugins\sdlc-lifecycle-plugin"); Scope = "Global" },
        @{ Name = "Agent Skills"; Path = (Join-Path $UserHome ".agents\skills\sdlc-lifecycle"); Scope = "Global" }
    )

    foreach ($item in $checkPaths) {
        $exists = Test-Path $item.Path
        $statusStr = if ($exists) { "Installed" } else { "Not installed" }
        $color = if ($exists) { "Green" } else { "DarkGray" }
        Write-Host ("{0,-15} [{1,-8}] : {2}" -f $item.Name, $statusStr, $item.Path) -ForegroundColor $color
    }

    if ($Project -ne "") {
        Write-Host "----------------------------------------------------------------"
        Write-Host "Project Scope: $Project" -ForegroundColor Cyan
        $projChecks = @(
            @{ Name = "Claude Code"; Path = (Join-Path $Project ".claude\skills\sdlc-lifecycle") },
            @{ Name = "OpenAI Codex"; Path = (Join-Path $Project ".codex\skills\sdlc-lifecycle") },
            @{ Name = "OpenCode"; Path = (Join-Path $Project ".opencode\skills\sdlc-lifecycle") },
            @{ Name = "jcode"; Path = (Join-Path $Project ".jcode\skills\sdlc-lifecycle") },
            @{ Name = "Cursor"; Path = (Join-Path $Project ".cursor\rules\sdlc-lifecycle.mdc") },
            @{ Name = "Agent Skills"; Path = (Join-Path $Project ".agents\skills\sdlc-lifecycle") }
        )
        foreach ($item in $projChecks) {
            $exists = Test-Path $item.Path
            $statusStr = if ($exists) { "Installed" } else { "Not installed" }
            $color = if ($exists) { "Green" } else { "DarkGray" }
            Write-Host ("{0,-15} [{1,-8}] : {2}" -f $item.Name, $statusStr, $item.Path) -ForegroundColor $color
        }
    }
    Write-Host "================================================================" -ForegroundColor White
    exit 0
}

# Resolve targets
$activeTargets = @()
if ($Claude) { $activeTargets += "claude" }
if ($Codex) { $activeTargets += "codex" }
if ($OpenCode) { $activeTargets += "opencode" }
if ($Jcode) { $activeTargets += "jcode" }
if ($Cursor) { $activeTargets += "cursor" }
if ($Antigravity) { $activeTargets += "antigravity" }
if ($Agents) { $activeTargets += "agents" }

if ($All) {
    if ($Uninstall) {
        $activeTargets = @("claude", "codex", "opencode", "jcode", "cursor", "antigravity", "agents")
    } else {
        $activeTargets = Detect-Harnesses
    }
} elseif ($activeTargets.Count -eq 0) {
    $activeTargets = Detect-Harnesses
    Write-Host "ℹ Auto-detected agent harnesses: $($activeTargets -join ', ')" -ForegroundColor Blue
}

if ($Project -ne "") {
    $Scope = "project"
}

foreach ($t in $activeTargets) {
    Write-Host ""
    switch ($t) {
        "claude" {
            Write-Host "→ Target: Claude Code" -ForegroundColor White
            if ($Scope -eq "global") {
                $destSkill = Join-Path $UserHome ".claude\skills\sdlc-lifecycle"
                $destCmd = Join-Path $UserHome ".claude\commands\sdlc.md"
                $destPlug = Join-Path $UserHome ".claude\plugins\sdlc-lifecycle"
                if ($Uninstall) {
                    Safe-Remove $destSkill
                    Safe-Remove $destCmd
                    Safe-Remove $destPlug
                } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $ClaudeCommand -Destination $destCmd -IsDirectory $false
                    Safe-LinkOrCopy -Source $ScriptDir -Destination $destPlug -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destSkill = Join-Path $pdir ".claude\skills\sdlc-lifecycle"
                $destCmd = Join-Path $pdir "commands\sdlc.md"
                $destClaude = Join-Path $pdir "CLAUDE.md"
                if ($Uninstall) {
                    Safe-Remove $destSkill
                    Safe-Remove $destCmd
                } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $ClaudeCommand -Destination $destCmd -IsDirectory $false
                    Safe-LinkOrCopy -Source $ClaudeFile -Destination $destClaude -IsDirectory $false
                }
            }
        }
        "codex" {
            Write-Host "→ Target: OpenAI Codex" -ForegroundColor White
            if ($Scope -eq "global") {
                $destSkill = Join-Path $UserHome ".codex\skills\sdlc-lifecycle"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destSkill = Join-Path $pdir ".codex\skills\sdlc-lifecycle"
                $destAgents = Join-Path $pdir "AGENTS.md"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $RulesFile -Destination $destAgents -IsDirectory $false
                }
            }
        }
        "opencode" {
            Write-Host "→ Target: OpenCode" -ForegroundColor White
            if ($Scope -eq "global") {
                $destSkill = Join-Path $UserHome ".config\opencode\skills\sdlc-lifecycle"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destSkill = Join-Path $pdir ".opencode\skills\sdlc-lifecycle"
                $destAgents = Join-Path $pdir "AGENTS.md"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $RulesFile -Destination $destAgents -IsDirectory $false
                }
            }
        }
        "jcode" {
            Write-Host "→ Target: jcode" -ForegroundColor White
            if ($Scope -eq "global") {
                $destSkill = Join-Path $UserHome ".jcode\skills\sdlc-lifecycle"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destSkill = Join-Path $pdir ".jcode\skills\sdlc-lifecycle"
                $destAgents = Join-Path $pdir "AGENTS.md"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $RulesFile -Destination $destAgents -IsDirectory $false
                }
            }
        }
        "cursor" {
            Write-Host "→ Target: Cursor IDE" -ForegroundColor White
            $pdir = if ($Project) { $Project } else { "." }
            $destRule = Join-Path $pdir ".cursor\rules\sdlc-lifecycle.mdc"
            if ($Uninstall) { Safe-Remove $destRule } else {
                Safe-LinkOrCopy -Source $CursorRule -Destination $destRule -IsDirectory $false
            }
        }
        "antigravity" {
            Write-Host "→ Target: Antigravity" -ForegroundColor White
            if ($Scope -eq "global") {
                $destPlugin = Join-Path $UserHome ".gemini\config\plugins\sdlc-lifecycle-plugin"
                if ($Uninstall) { Safe-Remove $destPlugin } else {
                    Safe-LinkOrCopy -Source $ScriptDir -Destination $destPlugin -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destPlugin = Join-Path $pdir ".agents\plugins\sdlc-lifecycle-plugin"
                if ($Uninstall) { Safe-Remove $destPlugin } else {
                    Safe-LinkOrCopy -Source $ScriptDir -Destination $destPlugin -IsDirectory $true
                }
            }
        }
        "agents" {
            Write-Host "→ Target: Universal Agent Skills (.agents/)" -ForegroundColor White
            if ($Scope -eq "global") {
                $destSkill = Join-Path $UserHome ".agents\skills\sdlc-lifecycle"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                }
            } else {
                $pdir = if ($Project) { $Project } else { "." }
                $destSkill = Join-Path $pdir ".agents\skills\sdlc-lifecycle"
                $destAgents = Join-Path $pdir "AGENTS.md"
                if ($Uninstall) { Safe-Remove $destSkill } else {
                    Safe-LinkOrCopy -Source $SkillDir -Destination $destSkill -IsDirectory $true
                    Safe-LinkOrCopy -Source $RulesFile -Destination $destAgents -IsDirectory $false
                }
            }
        }
    }
}

Write-Host ""
if ($Uninstall) {
    Write-Host "✓ Uninstallation complete!" -ForegroundColor Green
} else {
    Write-Host "✓ Installation complete!" -ForegroundColor Green
    Write-Host "Tip: Run .\install.ps1 -Status at any time to inspect harness installation status." -ForegroundColor Cyan
}
