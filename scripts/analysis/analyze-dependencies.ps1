# Analyze project dependencies recursively
# Output: analysis/dependencies/dependency-graph.json

param(
    [string]$SolutionFile = "Carmen.NET.sln",
    [string]$OutputFile = "analysis/dependencies/dependency-graph.json"
)

Write-Host "=== Dependency Analyzer ===" -ForegroundColor Cyan
Write-Host "Analyzing dependencies from $SolutionFile..." -ForegroundColor Yellow

$projects = @()
$dependencies = @()

# Parse solution file for projects
if (Test-Path $SolutionFile) {
    $solutionContent = Get-Content $SolutionFile
    $projectPattern = 'Project\("[^"]+"\)\s*=\s*"([^"]+)",\s*"([^"]+)"'

    Write-Host "Parsing solution file..." -ForegroundColor Gray

    $matches = $solutionContent | Select-String -Pattern $projectPattern -AllMatches

    foreach ($match in $matches.Matches) {
        $projectName = $match.Groups[1].Value
        $projectPath = $match.Groups[2].Value

        if ($projectPath -match '\.csproj$') {
            $projects += @{
                Name = $projectName
                Path = $projectPath -replace '\\', '/'
            }
            Write-Host "  Found project: $projectName" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`nAnalyzing project dependencies..." -ForegroundColor Gray

# Analyze each project for dependencies
$projectCount = 0
foreach ($project in $projects) {
    $projectCount++
    Write-Host "  [$projectCount/$($projects.Count)] $($project.Name)" -ForegroundColor DarkGray

    if (Test-Path $project.Path) {
        [xml]$csproj = Get-Content $project.Path

        # Project references
        $projectRefs = $csproj.Project.ItemGroup.ProjectReference
        if ($projectRefs) {
            foreach ($ref in $projectRefs) {
                if ($ref.Include) {
                    $refName = [System.IO.Path]::GetFileNameWithoutExtension($ref.Include)
                    $dependencies += @{
                        From = $project.Name
                        To = $refName
                        Type = "ProjectReference"
                    }
                }
            }
        }

        # NuGet packages
        $packages = $csproj.Project.ItemGroup.PackageReference
        if ($packages) {
            foreach ($pkg in $packages) {
                if ($pkg.Include) {
                    $version = if ($pkg.Version) { $pkg.Version } else { "Unknown" }
                    $dependencies += @{
                        From = $project.Name
                        To = $pkg.Include
                        Version = $version
                        Type = "NuGetPackage"
                    }
                }
            }
        }
    }
}

# Create summary
$projectDeps = $dependencies | Where-Object { $_.Type -eq "ProjectReference" }
$nugetDeps = $dependencies | Where-Object { $_.Type -eq "NuGetPackage" }

$summary = @{
    TotalProjects = $projects.Count
    ProjectReferences = $projectDeps.Count
    NuGetPackages = ($nugetDeps | Select-Object -ExpandProperty To -Unique).Count
    TotalDependencies = $dependencies.Count
    ScanDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Prepare output
$output = @{
    Summary = $summary
    Projects = $projects
    Dependencies = $dependencies
}

# Ensure output directory exists
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save to JSON
$output | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Encoding UTF8

Write-Host "`n=== Analysis Complete ===" -ForegroundColor Green
Write-Host "Total Projects: $($projects.Count)" -ForegroundColor Cyan
Write-Host "Project References: $($projectDeps.Count)" -ForegroundColor Cyan
Write-Host "Unique NuGet Packages: $($summary.NuGetPackages)" -ForegroundColor Cyan
Write-Host "Total Dependencies: $($dependencies.Count)" -ForegroundColor Cyan
Write-Host "`nOutput saved to: $OutputFile" -ForegroundColor Green
