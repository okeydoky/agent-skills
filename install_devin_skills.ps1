# Install Devin/Windsurf skills and workflows
# Copies workflows and skill folders to ~/.codeium/windsurf directories

param(
    [switch]$Verbose = $false
)

# Get the directory where this script is located
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define source and target paths
$baseDir = Join-Path $env:USERPROFILE ".codeium\windsurf"
$workflowsDir = Join-Path $baseDir "global_workflows"
$skillsDir = Join-Path $baseDir "skills"

# Define what to copy
$workflows = @("bootstrap-context", "draft-pr", "execute-plan", "review-plan", "ticket-to-plan")
$skills = @("github-manager", "jira-manager", "planner")

# Track what was copied
$copiedItems = @()

# Create directories if they don't exist
if (-not (Test-Path $workflowsDir)) {
    New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
    if ($Verbose) { Write-Host "Created directory: $workflowsDir" }
}

if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    if ($Verbose) { Write-Host "Created directory: $skillsDir" }
}

# Copy workflows
Write-Host "Copying workflows..."
foreach ($workflow in $workflows) {
    $sourcePath = Join-Path $scriptRoot "skills\$workflow\$workflow.md"

    if (Test-Path $sourcePath) {
        $destPath = Join-Path $workflowsDir "$workflow.md"
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        $copiedItems += "✓ Workflow: $workflow.md"
        if ($Verbose) { Write-Host "  Copied: $sourcePath → $destPath" }
    } else {
        Write-Warning "Workflow not found: $sourcePath"
    }
}

# Copy skills
Write-Host "Copying skills..."
foreach ($skill in $skills) {
    $sourcePath = Join-Path $scriptRoot "skills\$skill"

    if (Test-Path $sourcePath) {
        $destPath = Join-Path $skillsDir $skill

        # Remove existing destination if it exists
        if (Test-Path $destPath) {
            Remove-Item -Path $destPath -Recurse -Force
        }

        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
        $copiedItems += "✓ Skill: $skill\ (folder)"
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
Write-Host "Location: $baseDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copied items:" -ForegroundColor Yellow
foreach ($item in $copiedItems) {
    Write-Host $item
}
Write-Host ""
Write-Host "Directories:" -ForegroundColor Yellow
Write-Host "  Workflows: $workflowsDir"
Write-Host "  Skills:    $skillsDir"
Write-Host ""
