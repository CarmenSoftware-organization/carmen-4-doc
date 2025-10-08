# Calculate comprehensive code metrics
# Output: analysis/code-metrics.json

param(
    [string]$OutputFileJson = "analysis/code-metrics.json",
    [string]$OutputFileTxt = "analysis/code-metrics.txt"
)

Write-Host "=== Code Metrics Calculator ===" -ForegroundColor Cyan
Write-Host "Calculating code metrics..." -ForegroundColor Yellow

# Initialize metrics
$metrics = @{}

# Count files by type
Write-Host "`nCounting files..." -ForegroundColor Gray
$metrics.Files = @{
    Controllers = 0
    Models = 0
    Enums = 0
    Utils = 0
    Tests = 0
    TotalCSharp = 0
    TotalProjects = 0
}

if (Test-Path "Carmen.WebApi/Controllers") {
    $metrics.Files.Controllers = (Get-ChildItem "Carmen.WebApi/Controllers" -Filter "*.cs" -Recurse).Count
}

if (Test-Path "Carmen.Models") {
    $metrics.Files.Models = (Get-ChildItem "Carmen.Models" -Filter "*.cs" -Recurse).Count
}

if (Test-Path "Carmen.Enum") {
    $metrics.Files.Enums = (Get-ChildItem "Carmen.Enum" -Filter "*.cs" -Recurse).Count
}

if (Test-Path "Carmen.Utils") {
    $metrics.Files.Utils = (Get-ChildItem "Carmen.Utils" -Filter "*.cs" -Recurse).Count
}

if (Test-Path "Carmen.WebApi.Test") {
    $metrics.Files.Tests = (Get-ChildItem "Carmen.WebApi.Test" -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue).Count
}

$allCsFiles = Get-ChildItem -Path . -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue
$metrics.Files.TotalCSharp = $allCsFiles.Count

$metrics.Files.TotalProjects = (Get-ChildItem -Path . -Filter "*.csproj" -Recurse).Count

# Count lines of code
Write-Host "Counting lines of code..." -ForegroundColor Gray
$totalLines = 0
$codeLines = 0
$commentLines = 0
$blankLines = 0

foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName
    $totalLines += $content.Count

    foreach ($line in $content) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "") {
            $blankLines++
        } elseif ($trimmed.StartsWith("//") -or $trimmed.StartsWith("/*") -or $trimmed.StartsWith("*")) {
            $commentLines++
        } else {
            $codeLines++
        }
    }
}

$metrics.LinesOfCode = @{
    Total = $totalLines
    Code = $codeLines
    Comments = $commentLines
    Blank = $blankLines
}

# Calculate complexity (simplified)
Write-Host "Analyzing complexity..." -ForegroundColor Gray
$complexityScore = 0
$methodCount = 0

$controllerFiles = Get-ChildItem "Carmen.WebApi/Controllers" -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue

foreach ($file in $controllerFiles) {
    $content = Get-Content $file.FullName -Raw

    # Count decision points
    $ifCount = ([regex]::Matches($content, '\bif\s*\(')).Count
    $forCount = ([regex]::Matches($content, '\b(for|foreach|while)\s*\(')).Count
    $switchCount = ([regex]::Matches($content, '\bswitch\s*\(')).Count
    $catchCount = ([regex]::Matches($content, '\bcatch\s*\(')).Count

    # Count methods
    $methods = ([regex]::Matches($content, 'public\s+(?:async\s+)?Task<[^>]+>\s+\w+\s*\(')).Count
    $methodCount += $methods

    $complexityScore += $ifCount + $forCount + $switchCount + $catchCount
}

$avgComplexity = if ($methodCount -gt 0) { [math]::Round($complexityScore / $methodCount, 2) } else { 0 }

$metrics.Complexity = @{
    AverageCyclomaticComplexity = $avgComplexity
    TotalDecisionPoints = $complexityScore
    TotalMethods = $methodCount
}

# Load analysis results if available
$metrics.Analysis = @{
    ControllersScanned = $false
    ModelsScanned = $false
    DependenciesAnalyzed = $false
    EndpointsExtracted = $false
}

if (Test-Path "analysis/controllers/controller-inventory.json") {
    $ctrlData = Get-Content "analysis/controllers/controller-inventory.json" | ConvertFrom-Json
    $metrics.Analysis.ControllersScanned = $true
    $metrics.Analysis.TotalControllers = $ctrlData.Summary.TotalControllers
    $metrics.Analysis.TotalEndpointsFromControllers = $ctrlData.Summary.TotalEndpoints
}

if (Test-Path "analysis/models/model-inventory.json") {
    $modelData = Get-Content "analysis/models/model-inventory.json" | ConvertFrom-Json
    $metrics.Analysis.ModelsScanned = $true
    $metrics.Analysis.TotalModels = $modelData.Summary.TotalModels
}

if (Test-Path "analysis/dependencies/dependency-graph.json") {
    $depData = Get-Content "analysis/dependencies/dependency-graph.json" | ConvertFrom-Json
    $metrics.Analysis.DependenciesAnalyzed = $true
    $metrics.Analysis.TotalProjects = $depData.Summary.TotalProjects
    $metrics.Analysis.TotalDependencies = $depData.Summary.TotalDependencies
}

if (Test-Path "analysis/api/api-endpoints.json") {
    $apiData = Get-Content "analysis/api/api-endpoints.json" | ConvertFrom-Json
    $metrics.Analysis.EndpointsExtracted = $true
    $metrics.Analysis.TotalEndpoints = $apiData.Summary.TotalEndpoints
}

# Add timestamp
$metrics.GeneratedAt = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Ensure output directory exists
$outputDir = Split-Path $OutputFileJson -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save to JSON
$metrics | ConvertTo-Json -Depth 10 | Out-File $OutputFileJson -Encoding UTF8

# Save to text format
$textOutput = @"
===========================================
Carmen.NET Code Metrics Report
===========================================
Generated: $($metrics.GeneratedAt)

FILES
-------------------------------------------
Total C# Files:        $($metrics.Files.TotalCSharp)
  Controllers:         $($metrics.Files.Controllers)
  Models:              $($metrics.Files.Models)
  Enums:               $($metrics.Files.Enums)
  Utils:               $($metrics.Files.Utils)
  Tests:               $($metrics.Files.Tests)
Total Projects:        $($metrics.Files.TotalProjects)

LINES OF CODE
-------------------------------------------
Total Lines:           $($metrics.LinesOfCode.Total)
  Code:                $($metrics.LinesOfCode.Code)
  Comments:            $($metrics.LinesOfCode.Comments)
  Blank:               $($metrics.LinesOfCode.Blank)

COMPLEXITY
-------------------------------------------
Avg Cyclomatic:        $($metrics.Complexity.AverageCyclomaticComplexity)
Total Decision Points: $($metrics.Complexity.TotalDecisionPoints)
Total Methods:         $($metrics.Complexity.TotalMethods)

ANALYSIS RESULTS
-------------------------------------------
"@

if ($metrics.Analysis.ControllersScanned) {
    $textOutput += "`nControllers:           $($metrics.Analysis.TotalControllers)"
}
if ($metrics.Analysis.ModelsScanned) {
    $textOutput += "`nModels:                $($metrics.Analysis.TotalModels)"
}
if ($metrics.Analysis.EndpointsExtracted) {
    $textOutput += "`nAPI Endpoints:         $($metrics.Analysis.TotalEndpoints)"
}
if ($metrics.Analysis.DependenciesAnalyzed) {
    $textOutput += "`nDependencies:          $($metrics.Analysis.TotalDependencies)"
}

$textOutput += "`n`n==========================================="

$textOutput | Out-File $OutputFileTxt -Encoding UTF8

Write-Host "`n=== Metrics Complete ===" -ForegroundColor Green
Write-Host "`nFILES:" -ForegroundColor Cyan
Write-Host "  Total C# Files: $($metrics.Files.TotalCSharp)" -ForegroundColor White
Write-Host "  Controllers: $($metrics.Files.Controllers)" -ForegroundColor Gray
Write-Host "  Models: $($metrics.Files.Models)" -ForegroundColor Gray
Write-Host "  Total Projects: $($metrics.Files.TotalProjects)" -ForegroundColor Gray

Write-Host "`nLINES OF CODE:" -ForegroundColor Cyan
Write-Host "  Total: $($metrics.LinesOfCode.Total)" -ForegroundColor White
Write-Host "  Code: $($metrics.LinesOfCode.Code)" -ForegroundColor Gray
Write-Host "  Comments: $($metrics.LinesOfCode.Comments)" -ForegroundColor Gray

Write-Host "`nCOMPLEXITY:" -ForegroundColor Cyan
Write-Host "  Avg Cyclomatic: $($metrics.Complexity.AverageCyclomaticComplexity)" -ForegroundColor White

Write-Host "`nOutput saved to:" -ForegroundColor Green
Write-Host "  $OutputFileJson" -ForegroundColor White
Write-Host "  $OutputFileTxt" -ForegroundColor White
