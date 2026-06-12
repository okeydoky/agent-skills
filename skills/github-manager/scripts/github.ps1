# Portable GitHub API Client for Skills (Native Windows/PowerShell)
# Usage: .\github.ps1 <endpoint> [payload_json_or_file] [METHOD]

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
    Write-Error "Error: ~/.levelup file not found. Create it in your home directory with GH_TOKEN."
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

$GH_TOKEN = $config["GH_TOKEN"]

if (-not $GH_TOKEN) {
    Write-Error "Error: GH_TOKEN must be defined in ~/.levelup"
    exit 1
}

$baseUrl = "https://api.github.com"
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

# 3. Build headers
$headers = @{
    "Authorization"        = "token $GH_TOKEN"
    "Accept"               = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

if ($body) {
    $headers["Content-Type"] = "application/json"
}

# 4. Execute request
try {
    $params = @{
        Uri     = $fullUrl
        Method  = $httpMethod
        Headers = $headers
        ErrorAction = "Stop"
    }
    if ($body) {
        $params["Body"] = $body
    }

    $response = Invoke-WebRequest @params
    Write-Host "Debug: Status $($response.StatusCode)" -ForegroundColor Cyan

    if ($response.Content) {
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
    }
} catch {
    $statusCode = $null
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }
    Write-Error "Error: Status $statusCode"

    # Check for rate limiting
    if ($statusCode -eq 403) {
        $rateLimitRemaining = $_.Exception.Response.Headers["X-RateLimit-Remaining"]
        if ($rateLimitRemaining -eq "0") {
            $resetTime = $_.Exception.Response.Headers["X-RateLimit-Reset"]
            Write-Error "Rate limit exceeded. Resets at Unix time: $resetTime"
        }
    }

    # Read error body
    try {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $respBody = $reader.ReadToEnd()
        $reader.Close()
        Write-Error $respBody
    } catch {
        Write-Error $_.Exception.Message
    }
    exit 1
}
