# Portable Jira API Client for Skills (Native Windows/PowerShell)
# Usage: .\jira.ps1 <endpoint> [payload_json_or_file] [METHOD]

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Endpoint,
    
    [Parameter(Position=1)]
    [string]$Payload,
    
    [Parameter(Position=2)]
    [string]$Method
)

# 1. Load configuration from ~/.levelup
$envPath = Join-Path $env:USERPROFILE ".levelup"
if (-not $env:USERPROFILE) {
    $envPath = Join-Path $HOME ".levelup"
}

if (-not (Test-Path $envPath)) {
    Write-Error "Error: ~/.levelup file not found. Create it in your home directory with JIRA_URL, JIRA_USER_EMAIL, and JIRA_TOKEN."
    exit 1
}

# Parse ~/.levelup
$config = @{}
Get-Content $envPath | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim().Trim("'").Trim('"')
            $config[$key] = $value
        }
    }
}

$JIRA_URL = $config["JIRA_URL"]
$JIRA_TOKEN = $config["JIRA_TOKEN"]
$JIRA_USER_EMAIL = $config["JIRA_USER_EMAIL"]

if (-not $JIRA_URL -or -not $JIRA_TOKEN) {
    Write-Error "Error: JIRA_URL and JIRA_TOKEN must be defined in ~/.levelup"
    exit 1
}

$baseUrl = $JIRA_URL.TrimEnd('/')
$fullUrl = "$baseUrl$Endpoint"

# 2. Prepare Request
$httpMethod = "GET"
if ($Method) {
    $httpMethod = $Method.ToUpper()
} elseif ($Payload) {
    $httpMethod = "POST"
}

$body = $null
if ($Payload) {
    if ($Payload.StartsWith("{") -or $Payload.StartsWith("[")) {
        $body = $Payload
    } elseif (Test-Path $Payload) {
        $body = Get-Content $Payload -Raw
    } else {
        Write-Error "Error: Payload must be a JSON string or a valid file path."
        exit 1
    }
}

# 3. Request Function
function Make-Request {
    param($authHeader)
    
    $headers = @{
        "Authorization" = $authHeader
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-Atlassian-Token" = "no-check"
    }

    try {
        $response = Invoke-WebRequest -Uri $fullUrl -Method $httpMethod -Headers $headers -Body $body -ErrorAction Stop
        Write-Host "Debug: Status $($response.StatusCode)" -ForegroundColor Cyan
        if ($response.Content) {
            $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
        }
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode -eq "Unauthorized") {
            return "401"
        }
        Write-Error "Error: Status $($_.Exception.Response.StatusCode)"
        $respBody = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
        Write-Error $respBody
        return $false
    }
}

# 4. Try Bearer first, fallback to Basic
$result = Make-Request "Bearer $JIRA_TOKEN"

if ($result -eq "401" -and $JIRA_USER_EMAIL) {
    Write-Host "Debug: Bearer Auth failed (401). Retrying with Basic Auth..." -ForegroundColor Yellow
    $pair = "$($JIRA_USER_EMAIL):$($JIRA_TOKEN)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [Convert]::ToBase64String($bytes)
    $result = Make-Request "Basic $base64"
}

if ($result -ne $true) { exit 1 }
