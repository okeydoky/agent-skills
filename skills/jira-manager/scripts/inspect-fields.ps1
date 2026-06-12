# Jira Field Inspector (Native Windows/PowerShell)
# Usage: .\inspect-fields.ps1 <mode: createmeta|issue> <key_or_project> [issuetype]

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Mode,
    
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Target,
    
    [Parameter(Position=2)]
    [string]$IssueType
)

$scriptDir = $PSScriptRoot
$jiraClient = Join-Path $scriptDir "jira.ps1"

if ($Mode -eq "createmeta") {
    $displayType = if ($IssueType) { $IssueType } else { "All" }
    Write-Host "Inspecting creation metadata for Project: $Target, IssueType: $displayType..." -ForegroundColor Cyan
    $endpoint = "/rest/api/2/issue/createmeta?projectKeys=$Target&expand=projects.issuetypes.fields"
    if ($IssueType) {
        $encodedType = [uri]::EscapeDataString($IssueType)
        $endpoint += "&issuetypeNames=$encodedType"
    }

    $json = & $jiraClient -Endpoint $endpoint
    if (-not $json) { exit 1 }

    $data = $json | ConvertFrom-Json
    $res = @{}

    foreach ($project in $data.projects) {
        foreach ($it in $project.issuetypes) {
            $fields = @{}
            foreach ($fid in $it.fields.PSObject.Properties.Name) {
                $info = $it.fields.$fid
                $fields[$info.name] = @{
                    id = $fid
                    required = $info.required
                    type = if ($info.schema) { $info.schema.type } else { $null }
                    custom = if ($info.schema) { $info.schema.custom } else { $null }
                    operations = $info.operations
                }
            }
            $res[$it.name] = $fields
        }
    }
    $res | ConvertTo-Json -Depth 10
} elseif ($Mode -eq "issue") {
    Write-Host "Inspecting existing issue: $Target..." -ForegroundColor Cyan
    $endpoint = "/rest/api/2/issue/$Target?expand=names,schema"
    $json = & $jiraClient -Endpoint $endpoint
    if (-not $json) { exit 1 }

    $data = $json | ConvertFrom-Json
    $names = $data.names
    $schema = $data.schema
    $fields = $data.fields
    $res = @{}

    foreach ($fid in $names.PSObject.Properties.Name) {
        $name = $names.$fid
        $res[$name] = @{
            id = $fid
            type = if ($schema.$fid) { $schema.$fid.type } else { $null }
            custom = if ($schema.$fid) { $schema.$fid.custom } else { $null }
            value = $fields.$fid
        }
    }
    $res | ConvertTo-Json -Depth 10
} else {
    Write-Error "Error: Invalid mode '$Mode'. Use 'createmeta' or 'issue'."
    exit 1
}
