# Extract all API endpoints recursively
# Output: analysis/api/api-endpoints.json

param(
    [string]$ControllersPath = "Carmen.WebApi/Controllers",
    [string]$AreasPath = "Carmen.WebApi/Areas",
    [string]$OutputFile = "analysis/api/api-endpoints.json"
)

Write-Host "=== API Endpoint Extractor ===" -ForegroundColor Cyan
Write-Host "Extracting API endpoints..." -ForegroundColor Yellow

$endpoints = @()
$totalEndpoints = 0

# Function to extract endpoints from controller
function Get-ControllerEndpoints {
    param([string]$FilePath, [string]$AreaName = $null)

    $content = Get-Content $FilePath -Raw
    $controllerName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath) -replace 'Controller$', ''

    # Extract all route methods
    $pattern = '\[Route\("([^"]+)"\)\]\s+(?:\[[^\]]+\]\s+)*public\s+(?:async\s+)?Task<[^>]+>\s+(\w+)\s*\(([^)]*)\)'
    $matches = [regex]::Matches($content, $pattern)

    $controllerEndpoints = @()

    foreach ($match in $matches) {
        $route = $match.Groups[1].Value
        $methodName = $match.Groups[2].Value
        $parameters = $match.Groups[3].Value

        # Find HTTP method before this route
        $position = $match.Index
        $beforeRoute = $content.Substring(0, $position)
        $httpMethod = "GET" # default

        if ($beforeRoute -match '\[HttpPost\][^\[]*$') { $httpMethod = "POST" }
        elseif ($beforeRoute -match '\[HttpPut\][^\[]*$') { $httpMethod = "PUT" }
        elseif ($beforeRoute -match '\[HttpDelete\][^\[]*$') { $httpMethod = "DELETE" }
        elseif ($beforeRoute -match '\[HttpPatch\][^\[]*$') { $httpMethod = "PATCH" }
        elseif ($beforeRoute -match '\[HttpGet\][^\[]*$') { $httpMethod = "GET" }

        # Extract permission
        $permission = $null
        $permPattern = "GetPermissionInfoByPermissionNameAsync\(`"([^`"]+)`"\)"
        if ($content.Substring($position) -match $permPattern) {
            $permission = $Matches[1]
        } elseif ($beforeRoute -match "$permPattern[^{]*$") {
            $permission = $Matches[1]
        }

        # Check for Authorize attribute
        $requiresAuth = $content -match '\[Authorize\]'

        # Extract swagger response types
        $responses = @()
        $responsePattern = '\[SwaggerResponse\(HttpStatusCode\.(\w+)'
        $respMatches = [regex]::Matches($content.Substring([Math]::Max(0, $position - 500), 500), $responsePattern)
        foreach ($resp in $respMatches) {
            $responses += $resp.Groups[1].Value
        }

        $controllerEndpoints += @{
            Controller = $controllerName
            Area = $AreaName
            Route = $route
            HttpMethod = $httpMethod
            MethodName = $methodName
            Parameters = $parameters
            Permission = $permission
            RequiresAuth = $requiresAuth
            Responses = $responses
            File = [System.IO.Path]::GetFileName($FilePath)
        }
    }

    return $controllerEndpoints
}

# Scan main controllers
if (Test-Path $ControllersPath) {
    Write-Host "Scanning main controllers..." -ForegroundColor Gray

    Get-ChildItem -Path $ControllersPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
        $eps = Get-ControllerEndpoints -FilePath $_.FullName
        if ($eps.Count -gt 0) {
            $endpoints += $eps
            $totalEndpoints += $eps.Count
            Write-Host "  $($_.Name): $($eps.Count) endpoints" -ForegroundColor DarkGray
        }
    }
}

# Scan area controllers
if (Test-Path $AreasPath) {
    Write-Host "`nScanning area controllers..." -ForegroundColor Gray

    Get-ChildItem -Path $AreasPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
        # Extract area name
        $pathParts = $_.FullName -split '[\\/]'
        $areaIndex = [array]::IndexOf($pathParts, "Areas")
        $areaName = $null
        if ($areaIndex -ge 0 -and $areaIndex + 1 -lt $pathParts.Count) {
            $areaName = $pathParts[$areaIndex + 1]
        }

        $eps = Get-ControllerEndpoints -FilePath $_.FullName -AreaName $areaName
        if ($eps.Count -gt 0) {
            $endpoints += $eps
            $totalEndpoints += $eps.Count
            Write-Host "  $($_.Name) (Area: $areaName): $($eps.Count) endpoints" -ForegroundColor DarkGray
        }
    }
}

# Create summary
$summary = @{
    TotalEndpoints = $totalEndpoints
    ByHttpMethod = @{
        GET = ($endpoints | Where-Object { $_.HttpMethod -eq "GET" }).Count
        POST = ($endpoints | Where-Object { $_.HttpMethod -eq "POST" }).Count
        PUT = ($endpoints | Where-Object { $_.HttpMethod -eq "PUT" }).Count
        DELETE = ($endpoints | Where-Object { $_.HttpMethod -eq "DELETE" }).Count
        PATCH = ($endpoints | Where-Object { $_.HttpMethod -eq "PATCH" }).Count
    }
    RequireAuth = ($endpoints | Where-Object { $_.RequiresAuth }).Count
    UniquePermissions = ($endpoints | Where-Object { $_.Permission } | Select-Object -ExpandProperty Permission -Unique).Count
    UniqueControllers = ($endpoints | Select-Object -ExpandProperty Controller -Unique).Count
    ScanDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Prepare output
$output = @{
    Summary = $summary
    Endpoints = $endpoints
}

# Ensure output directory exists
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save to JSON
$output | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Encoding UTF8

Write-Host "`n=== Extraction Complete ===" -ForegroundColor Green
Write-Host "Total Endpoints: $totalEndpoints" -ForegroundColor Cyan
Write-Host "HTTP Methods:" -ForegroundColor Cyan
Write-Host "  GET: $($summary.ByHttpMethod.GET)" -ForegroundColor Gray
Write-Host "  POST: $($summary.ByHttpMethod.POST)" -ForegroundColor Gray
Write-Host "  PUT: $($summary.ByHttpMethod.PUT)" -ForegroundColor Gray
Write-Host "  DELETE: $($summary.ByHttpMethod.DELETE)" -ForegroundColor Gray
Write-Host "  PATCH: $($summary.ByHttpMethod.PATCH)" -ForegroundColor Gray
Write-Host "Require Auth: $($summary.RequireAuth)" -ForegroundColor Cyan
Write-Host "Unique Permissions: $($summary.UniquePermissions)" -ForegroundColor Cyan
Write-Host "Unique Controllers: $($summary.UniqueControllers)" -ForegroundColor Cyan
Write-Host "`nOutput saved to: $OutputFile" -ForegroundColor Green
