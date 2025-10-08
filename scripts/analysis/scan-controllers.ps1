# Recursively scan all controllers
# Output: analysis/controllers/controller-inventory.json

param(
    [string]$ControllersPath = "Carmen.WebApi/Controllers",
    [string]$AreasPath = "Carmen.WebApi/Areas",
    [string]$OutputFile = "analysis/controllers/controller-inventory.json"
)

Write-Host "=== Controller Scanner ===" -ForegroundColor Cyan
Write-Host "Scanning controllers..." -ForegroundColor Yellow

$controllers = @()
$totalControllers = 0

# Function to extract controller metadata
function Get-ControllerMetadata {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

    # Extract SwaggerControllerOrder
    $order = "N/A"
    if ($content -match '\[SwaggerControllerOrder\((\d+)\)\]') {
        $order = [int]$Matches[1]
    }

    # Extract routes
    $routes = @()
    $routeMatches = [regex]::Matches($content, '\[Route\("([^"]+)"\)\]')
    foreach ($match in $routeMatches) {
        $routes += $match.Groups[1].Value
    }

    # Extract HTTP methods
    $httpMethods = @()
    $methodMatches = [regex]::Matches($content, '\[Http(Get|Post|Put|Delete|Patch)\]')
    foreach ($match in $methodMatches) {
        if ($httpMethods -notcontains $match.Groups[1].Value) {
            $httpMethods += $match.Groups[1].Value
        }
    }

    # Extract endpoint methods
    $endpoints = @()
    $endpointMatches = [regex]::Matches($content, 'public\s+(?:async\s+)?Task<[^>]+>\s+(\w+)\s*\(')
    foreach ($match in $endpointMatches) {
        $methodName = $match.Groups[1].Value
        if ($methodName -ne "Dispose" -and $methodName -ne "ToString") {
            $endpoints += $methodName
        }
    }

    # Extract permissions
    $permissions = @()
    $permMatches = [regex]::Matches($content, 'GetPermissionInfoByPermissionNameAsync\("([^"]+)"\)')
    foreach ($match in $permMatches) {
        if ($permissions -notcontains $match.Groups[1].Value) {
            $permissions += $match.Groups[1].Value
        }
    }

    # Count lines
    $lineCount = (Get-Content $FilePath).Count

    return @{
        Name = $fileName
        Path = $FilePath -replace '\\', '/'
        Order = $order
        Routes = $routes
        HttpMethods = $httpMethods
        Endpoints = $endpoints
        EndpointCount = $endpoints.Count
        Permissions = $permissions
        LineCount = $lineCount
        Area = $null
    }
}

# Scan main controllers
if (Test-Path $ControllersPath) {
    Write-Host "Scanning main controllers in $ControllersPath..." -ForegroundColor Gray

    Get-ChildItem -Path $ControllersPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
        $metadata = Get-ControllerMetadata -FilePath $_.FullName
        $controllers += $metadata
        $totalControllers++
        Write-Host "  [$totalControllers] $($metadata.Name) - Order: $($metadata.Order), Endpoints: $($metadata.EndpointCount)" -ForegroundColor DarkGray
    }
}

# Scan area controllers
if (Test-Path $AreasPath) {
    Write-Host "`nScanning area controllers in $AreasPath..." -ForegroundColor Gray

    Get-ChildItem -Path $AreasPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
        $metadata = Get-ControllerMetadata -FilePath $_.FullName

        # Extract area name from path
        $pathParts = $_.FullName -split '[\\/]'
        $areaIndex = [array]::IndexOf($pathParts, "Areas")
        if ($areaIndex -ge 0 -and $areaIndex + 1 -lt $pathParts.Count) {
            $metadata.Area = $pathParts[$areaIndex + 1]
        }

        $controllers += $metadata
        $totalControllers++
        Write-Host "  [$totalControllers] $($metadata.Name) (Area: $($metadata.Area)) - Endpoints: $($metadata.EndpointCount)" -ForegroundColor DarkGray
    }
}

# Create summary
$summary = @{
    TotalControllers = $totalControllers
    MainControllers = ($controllers | Where-Object { $_.Area -eq $null }).Count
    AreaControllers = ($controllers | Where-Object { $_.Area -ne $null }).Count
    TotalEndpoints = ($controllers | ForEach-Object { $_.EndpointCount } | Measure-Object -Sum).Sum
    TotalLines = ($controllers | ForEach-Object { $_.LineCount } | Measure-Object -Sum).Sum
    UniquePermissions = ($controllers | ForEach-Object { $_.Permissions } | Select-Object -Unique).Count
    ScanDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Prepare output
$output = @{
    Summary = $summary
    Controllers = $controllers
}

# Ensure output directory exists
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save to JSON
$output | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Encoding UTF8

Write-Host "`n=== Scan Complete ===" -ForegroundColor Green
Write-Host "Total Controllers: $totalControllers" -ForegroundColor Cyan
Write-Host "  Main Controllers: $($summary.MainControllers)" -ForegroundColor Gray
Write-Host "  Area Controllers: $($summary.AreaControllers)" -ForegroundColor Gray
Write-Host "Total Endpoints: $($summary.TotalEndpoints)" -ForegroundColor Cyan
Write-Host "Total Lines: $($summary.TotalLines)" -ForegroundColor Cyan
Write-Host "Unique Permissions: $($summary.UniquePermissions)" -ForegroundColor Cyan
Write-Host "`nOutput saved to: $OutputFile" -ForegroundColor Green
