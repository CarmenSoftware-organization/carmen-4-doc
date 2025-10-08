# Recursively scan all model files
# Output: analysis/models/model-inventory.json

param(
    [string]$ModelsPath = "Carmen.Models",
    [string]$OutputFile = "analysis/models/model-inventory.json"
)

Write-Host "=== Model Scanner ===" -ForegroundColor Cyan
Write-Host "Scanning models in $ModelsPath..." -ForegroundColor Yellow

$models = @()
$totalModels = 0

# Function to parse C# class file
function Get-ClassMetadata {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

    # Extract namespace
    $namespace = "Unknown"
    if ($content -match 'namespace\s+([\w.]+)') {
        $namespace = $Matches[1]
    }

    # Extract class name
    $className = $fileName
    if ($content -match 'public\s+(?:class|interface|enum)\s+(\w+)') {
        $className = $Matches[1]
    }

    # Determine type
    $isInterface = $className.StartsWith("I") -and ($content -match 'public\s+interface')
    $isEnum = $content -match 'public\s+enum'
    $isView = $className.StartsWith("View")
    $isParam = $className.StartsWith("Param")

    # Extract properties
    $properties = @()
    $propMatches = [regex]::Matches($content, '(?:public|internal)\s+([\w<>?,\[\]]+)\s+(\w+)\s*{\s*get')
    foreach ($match in $propMatches) {
        $properties += @{
            Type = $match.Groups[1].Value
            Name = $match.Groups[2].Value
        }
    }

    # Extract base class/interfaces
    $baseTypes = @()
    if ($content -match 'public\s+(?:class|interface)\s+\w+\s*:\s*([^{]+)') {
        $inheritance = $Matches[1].Trim()
        $baseTypes = $inheritance -split ',\s*' | ForEach-Object { $_.Trim() }
    }

    return @{
        FileName = [System.IO.Path]::GetFileName($FilePath)
        FilePath = $FilePath -replace '\\', '/'
        ClassName = $className
        Namespace = $namespace
        IsInterface = $isInterface
        IsEnum = $isEnum
        IsView = $isView
        IsParam = $isParam
        PropertyCount = $properties.Count
        Properties = $properties
        BaseTypes = $baseTypes
        LineCount = (Get-Content $FilePath).Count
    }
}

# Scan all .cs files
if (Test-Path $ModelsPath) {
    $files = Get-ChildItem -Path $ModelsPath -Filter "*.cs" -Recurse

    Write-Host "Found $($files.Count) C# files to analyze..." -ForegroundColor Gray

    foreach ($file in $files) {
        $metadata = Get-ClassMetadata -FilePath $file.FullName
        $models += $metadata
        $totalModels++

        $typeLabel = if ($metadata.IsInterface) { "Interface" }
                     elseif ($metadata.IsEnum) { "Enum" }
                     elseif ($metadata.IsView) { "View" }
                     elseif ($metadata.IsParam) { "Param" }
                     else { "Model" }

        Write-Host "  [$totalModels] $($metadata.ClassName) ($typeLabel) - $($metadata.PropertyCount) properties" -ForegroundColor DarkGray
    }
}

# Create summary
$summary = @{
    TotalModels = $totalModels
    Interfaces = ($models | Where-Object { $_.IsInterface }).Count
    Enums = ($models | Where-Object { $_.IsEnum }).Count
    ViewModels = ($models | Where-Object { $_.IsView }).Count
    ParamModels = ($models | Where-Object { $_.IsParam }).Count
    RegularModels = ($models | Where-Object { -not $_.IsInterface -and -not $_.IsEnum -and -not $_.IsView -and -not $_.IsParam }).Count
    TotalProperties = ($models | ForEach-Object { $_.PropertyCount } | Measure-Object -Sum).Sum
    TotalLines = ($models | ForEach-Object { $_.LineCount } | Measure-Object -Sum).Sum
    ScanDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Prepare output
$output = @{
    Summary = $summary
    Models = $models
}

# Ensure output directory exists
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save to JSON
$output | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Encoding UTF8

Write-Host "`n=== Scan Complete ===" -ForegroundColor Green
Write-Host "Total Models: $totalModels" -ForegroundColor Cyan
Write-Host "  Interfaces: $($summary.Interfaces)" -ForegroundColor Gray
Write-Host "  Enums: $($summary.Enums)" -ForegroundColor Gray
Write-Host "  View Models: $($summary.ViewModels)" -ForegroundColor Gray
Write-Host "  Param Models: $($summary.ParamModels)" -ForegroundColor Gray
Write-Host "  Regular Models: $($summary.RegularModels)" -ForegroundColor Gray
Write-Host "Total Properties: $($summary.TotalProperties)" -ForegroundColor Cyan
Write-Host "Total Lines: $($summary.TotalLines)" -ForegroundColor Cyan
Write-Host "`nOutput saved to: $OutputFile" -ForegroundColor Green
