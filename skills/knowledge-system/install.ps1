# One-time global install (Windows PowerShell). Run from the cloned repo: `./install.ps1`
# Makes /knowledge-init and /knowledge-materialize available in EVERY repo, and drops the
# assets that /knowledge-init copies into each repo.
$ErrorActionPreference = "Stop"

$Src  = $PSScriptRoot
$Dest = Join-Path $HOME ".claude"

New-Item -ItemType Directory -Force -Path (Join-Path $Dest "commands") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Dest "knowledge-system") | Out-Null

# 1) global slash commands
Copy-Item (Join-Path $Src "commands\*.md") (Join-Path $Dest "commands") -Force

# 2) assets that /knowledge-init copies into each target repo (refresh on re-run)
foreach ($d in "contract","tools","templates","commands") {
  $target = Join-Path $Dest "knowledge-system\$d"
  if (Test-Path $target) { Remove-Item $target -Recurse -Force }
  Copy-Item (Join-Path $Src $d) $target -Recurse -Force
}

Write-Host "Installed."
Write-Host "  commands -> $(Join-Path $Dest 'commands')  (/knowledge-init, /knowledge-materialize now work in any repo)"
Write-Host "  assets   -> $(Join-Path $Dest 'knowledge-system')"
Write-Host ""
Write-Host "Next: cd into a repo and run /knowledge-init"
