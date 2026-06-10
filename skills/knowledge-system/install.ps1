# One-time global install (Windows PowerShell). Run from the cloned repo: `./install.ps1 [claude|windsurf|all]`
#
# Installs:
#   1) the shared assets (contract, tools, templates, workflow procedures) -> ~\.knowledge-system\
#   2) thin platform front-ends:
#        Claude Code            -> ~\.claude\commands\            (/knowledge-init, /knowledge-materialize)
#        Windsurf/Devin Desktop -> ~\.codeium\windsurf\global_workflows\
#
# With no argument, platforms are auto-detected (~\.claude and/or ~\.codeium\windsurf present).
# Re-run anytime to update — initialized repos never need touching (they carry content only).
param([string]$Target = "detect")
$ErrorActionPreference = "Stop"

$Src    = $PSScriptRoot
$Assets = Join-Path $HOME ".knowledge-system"

# 1) shared assets (refresh on re-run)
New-Item -ItemType Directory -Force -Path $Assets | Out-Null
foreach ($d in "contract","tools","templates","workflows") {
  $dest = Join-Path $Assets $d
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  Copy-Item (Join-Path $Src $d) $dest -Recurse -Force
}
Write-Host "assets   -> $Assets"

function Want($name) { $Target -eq "all" -or $Target -eq $name }
function Detected($dir) { $Target -eq "detect" -and (Test-Path $dir) }
$installedAny = $false

# 2a) Claude Code front-ends
$claudeDir = Join-Path $HOME ".claude"
if ((Want "claude") -or (Detected $claudeDir)) {
  $cmds = Join-Path $claudeDir "commands"
  New-Item -ItemType Directory -Force -Path $cmds | Out-Null
  Copy-Item (Join-Path $Src "frontends\claude\*.md") $cmds -Force
  # legacy asset location from the pre-v1.3 installer
  $legacy = Join-Path $claudeDir "knowledge-system"
  if (Test-Path $legacy) {
    Remove-Item $legacy -Recurse -Force
    Write-Host "cleaned  -> $legacy (legacy asset dir; replaced by $Assets)"
  }
  Write-Host "claude   -> $cmds  (/knowledge-init, /knowledge-materialize)"
  $installedAny = $true
}

# 2b) Windsurf / Devin Desktop front-ends (global workflows)
$windsurfDir = Join-Path $HOME ".codeium\windsurf"
if ((Want "windsurf") -or (Detected $windsurfDir)) {
  $wf = Join-Path $windsurfDir "global_workflows"
  New-Item -ItemType Directory -Force -Path $wf | Out-Null
  Copy-Item (Join-Path $Src "frontends\windsurf\*.md") $wf -Force
  Write-Host "windsurf -> $wf  (/knowledge-init, /knowledge-materialize)"
  $installedAny = $true
}

if (-not $installedAny) {
  Write-Host "No platform detected (~\.claude or ~\.codeium\windsurf). Assets installed;"
  Write-Host "re-run with an explicit target: ./install.ps1 claude | windsurf | all"
} else {
  Write-Host ""
  Write-Host "Next: cd into a repo and run /knowledge-init"
}
