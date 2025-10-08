# Master script to run all Phase 1 analysis
# Executes all analysis scripts in sequence

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Carmen.NET - Phase 1 Analysis Suite" -ForegroundColor Cyan
Write-Host "  Recursive Code Scanning & Analysis" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Script execution order
$scripts = @(
    @{ Name = "Controller Scanner"; Script = "scripts/analysis/scan-controllers.ps1" }
    @{ Name = "Model Scanner"; Script = "scripts/analysis/scan-models.ps1" }
    @{ Name = "Dependency Analyzer"; Script = "scripts/analysis/analyze-dependencies.ps1" }
    @{ Name = "API Endpoint Extractor"; Script = "scripts/analysis/extract-api-endpoints.ps1" }
    @{ Name = "Code Metrics Calculator"; Script = "scripts/analysis/calculate-metrics.ps1" }
)

$completed = 0
$failed = 0
$results = @()

foreach ($scriptInfo in $scripts) {
    $scriptNum = $completed + $failed + 1
    $totalScripts = $scripts.Count

    Write-Host "`n[$scriptNum/$totalScripts] Running: $($scriptInfo.Name)" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor DarkGray

    try {
        if (Test-Path $scriptInfo.Script) {
            $scriptStart = Get-Date
            & $scriptInfo.Script
            $scriptEnd = Get-Date
            $duration = ($scriptEnd - $scriptStart).TotalSeconds

            $completed++
            $results += @{
                Name = $scriptInfo.Name
                Status = "Success"
                Duration = "{0:N2}s" -f $duration
            }

            Write-Host "`n✓ Completed in $("{0:N2}s" -f $duration)" -ForegroundColor Green
        } else {
            throw "Script not found: $($scriptInfo.Script)"
        }
    } catch {
        $failed++
        $results += @{
            Name = $scriptInfo.Name
            Status = "Failed"
            Error = $_.Exception.Message
        }

        Write-Host "`n✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

Write-Host "`n`n==========================================" -ForegroundColor Cyan
Write-Host "  Analysis Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

foreach ($result in $results) {
    $status = if ($result.Status -eq "Success") { "✓" } else { "✗" }
    $color = if ($result.Status -eq "Success") { "Green" } else { "Red" }

    Write-Host "$status $($result.Name)" -ForegroundColor $color -NoNewline
    if ($result.Duration) {
        Write-Host " ($($result.Duration))" -ForegroundColor Gray
    } else {
        Write-Host " - $($result.Error)" -ForegroundColor Red
    }
}

Write-Host "`nTotal Time: $("{0:N2}s" -f $totalDuration)" -ForegroundColor Cyan
Write-Host "Completed: $completed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Phase 1 Deliverables" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$deliverables = @(
    "analysis/controllers/controller-inventory.json"
    "analysis/models/model-inventory.json"
    "analysis/dependencies/dependency-graph.json"
    "analysis/api/api-endpoints.json"
    "analysis/code-metrics.json"
    "analysis/code-metrics.txt"
)

foreach ($file in $deliverables) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        $sizeKB = [math]::Round($size / 1KB, 2)
        Write-Host "✓ $file" -ForegroundColor Green -NoNewline
        Write-Host " ($sizeKB KB)" -ForegroundColor Gray
    } else {
        Write-Host "✗ $file" -ForegroundColor Red -NoNewline
        Write-Host " (missing)" -ForegroundColor DarkGray
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. Review analysis results in analysis/ directory" -ForegroundColor White
Write-Host "2. Check analysis/code-metrics.txt for summary" -ForegroundColor White
Write-Host "3. Proceed to Phase 2: Architecture & Data Modeling" -ForegroundColor White
Write-Host ""

if ($failed -eq 0) {
    Write-Host "Phase 1 Analysis: COMPLETE ✓" -ForegroundColor Green
} else {
    Write-Host "Phase 1 Analysis: COMPLETED WITH ERRORS" -ForegroundColor Yellow
    Write-Host "Please review error messages above and re-run failed scripts." -ForegroundColor Yellow
}

Write-Host ""
