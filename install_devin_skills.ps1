# Install GitHub Copilot for VS Code (+ Devin CLI) skills.
# Copies every skill folder (SKILL.md) to ~/.copilot/skills
# (or $env:COPILOT_HOME/skills if set).
#
# Note: Devin CLI imports skills directly from GitHub Copilot's global skill
# directory (~/.copilot/skills), so it is intentionally NOT installed to a
# separate %APPDATA%\devin\skills location — that would just duplicate the
# same files. See: https://docs.devin.ai/cli/reference/configuration/read-config-from

param(
    [switch]$Verbose = $false
)

# Get the directory where this script is located
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define source and target paths
$copilotBaseDir = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE ".copilot" }
$copilotSkillsDir = Join-Path $copilotBaseDir "skills"

# Define what to copy: every skill folder (each contains a SKILL.md)
$skills = @("archetype-discover", "archetype-invoker", "bootstrap-context", "draft-jira", "draft-pr", "execute-plan", "review-plan", "ticket-to-plan", "github-manager", "jira-manager", "planner")

# Track what was copied
$copiedItems = @()

# Create directory if it doesn't exist
if (-not (Test-Path $copilotSkillsDir)) {
    New-Item -ItemType Directory -Path $copilotSkillsDir -Force | Out-Null
    if ($Verbose) { Write-Host "Created directory: $copilotSkillsDir" }
}

# Copy GitHub Copilot skills (folders) — also picked up by Devin CLI
Write-Host "Copying GitHub Copilot skills..."
foreach ($skill in $skills) {
    $sourcePath = Join-Path $scriptRoot "skills\$skill"

    if (Test-Path $sourcePath) {
        $destPath = Join-Path $copilotSkillsDir $skill

        # Remove existing destination if it exists
        if (Test-Path $destPath) {
            Remove-Item -Path $destPath -Recurse -Force
        }

        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
        $copiedItems += "✓ Copilot skill: $skill\ (folder)"
        if ($Verbose) { Write-Host "  Copied: $sourcePath → $destPath" }
    } else {
        Write-Warning "Skill folder not found: $sourcePath"
    }
}

# Report results
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Copied items:" -ForegroundColor Yellow
foreach ($item in $copiedItems) {
    Write-Host $item
}
Write-Host ""
Write-Host "Directory: $copilotSkillsDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Devin CLI reads skills from the Copilot skills dir above automatically;"
Write-Host "no separate Devin install step is needed."
Write-Host ""
