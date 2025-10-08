# Carmen.NET Reverse Engineering Execution Plan

## Overview

This execution plan provides a systematic, automated approach to reverse engineering the Carmen.NET ERP system with **recursive code scanning** to ensure complete coverage and comprehensive documentation.

---

## Execution Strategy

### Core Principles
1. **Automation-First**: Automate recursive scanning and analysis
2. **Bottom-Up + Top-Down**: Combine code analysis with architecture discovery
3. **Incremental Delivery**: Produce documentation progressively
4. **Validation Gates**: Quality checks at each phase
5. **Tool-Assisted**: Leverage automated analysis tools

### Success Criteria
- ✅ 100% controller coverage
- ✅ 100% model/entity mapping
- ✅ All business rules extracted
- ✅ Complete dependency graph
- ✅ All API endpoints documented
- ✅ Database schema fully mapped
- ✅ All workflows visualized

---

## Phase 0: Setup & Preparation (Week 1, Days 1-2)

### Objectives
- Set up analysis environment
- Install and configure tools
- Establish documentation repository
- Create automation scripts

### Tasks

#### 0.1 Environment Setup
```bash
# Create documentation structure
mkdir -p docs/{executive,architecture,requirements,workflows,business-rules,api,development,database,design,operations,analysis}

# Create analysis output directories
mkdir -p analysis/{controllers,models,enums,dependencies,database,api,workflows,business-rules}

# Initialize tools
dotnet tool install --global dotnet-script
dotnet tool install --global dotnet-outdated
dotnet tool install --global dotnet-depends
```

#### 0.2 Tool Installation

**Code Analysis Tools**:
- [x] Visual Studio 2022 (or Rider)
- [x] ReSharper / Rider (code analysis)
- [x] NDepend (architecture analysis) - Optional but recommended
- [x] dotnet-script (C# scripting)
- [x] Roslyn API (programmatic code analysis)

**Documentation Tools**:
- [x] DocFX (API documentation)
- [x] Mermaid CLI (diagram generation)
- [x] PlantUML (UML diagrams)
- [x] Swagger UI (already in project)

**Database Tools**:
- [x] SQL Server Management Studio / Azure Data Studio
- [x] Entity Framework Power Tools
- [x] SchemaSpy (database documentation)

**Utilities**:
- [x] PowerShell / Bash scripting
- [x] jq (JSON processing)
- [x] ripgrep (fast code search)

#### 0.3 Create Analysis Scripts

**Script 1: Recursive Controller Scanner** (`scripts/scan-controllers.ps1`)
```powershell
# Recursively scan all controllers
$controllersPath = "Carmen.WebApi/Controllers"
$areasPath = "Carmen.WebApi/Areas"
$outputFile = "analysis/controllers/controller-inventory.json"

$controllers = @()

# Scan main controllers
Get-ChildItem -Path $controllersPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Extract controller metadata
    $controllerName = $_.BaseName
    $order = if ($content -match '\[SwaggerControllerOrder\((\d+)\)\]') { $Matches[1] } else { "N/A" }
    $routes = [regex]::Matches($content, '\[Route\("([^"]+)"\)\]') | ForEach-Object { $_.Groups[1].Value }
    $methods = [regex]::Matches($content, '\[Http(Get|Post|Put|Delete|Patch)\]') | ForEach-Object { $_.Groups[1].Value }

    $controllers += @{
        Name = $controllerName
        Path = $_.FullName
        Order = $order
        Routes = $routes
        HttpMethods = $methods
        LineCount = (Get-Content $_.FullName).Count
    }
}

# Scan area controllers
Get-ChildItem -Path $areasPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
    $area = $_.FullName -replace '.*Areas[\\/]([^\\/]+)[\\/].*', '$1'
    $controllerName = $_.BaseName

    $controllers += @{
        Name = $controllerName
        Path = $_.FullName
        Area = $area
        LineCount = (Get-Content $_.FullName).Count
    }
}

$controllers | ConvertTo-Json -Depth 10 | Out-File $outputFile
Write-Host "Found $($controllers.Count) controllers"
```

**Script 2: Recursive Model Scanner** (`scripts/scan-models.csx`)
```csharp
#r "nuget: Microsoft.CodeAnalysis.CSharp, 4.0.1"

using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.IO;
using System.Text.Json;

var modelsPath = "Carmen.Models";
var outputFile = "analysis/models/model-inventory.json";

var models = new List<object>();

// Recursively scan all .cs files
foreach (var file in Directory.GetFiles(modelsPath, "*.cs", SearchOption.AllDirectories))
{
    var code = File.ReadAllText(file);
    var tree = CSharpSyntaxTree.ParseText(code);
    var root = tree.GetRoot();

    // Find all class declarations
    var classes = root.DescendantNodes().OfType<ClassDeclarationSyntax>();

    foreach (var classNode in classes)
    {
        var className = classNode.Identifier.Text;
        var properties = classNode.Members.OfType<PropertyDeclarationSyntax>()
            .Select(p => new {
                Name = p.Identifier.Text,
                Type = p.Type.ToString(),
                HasGetter = p.AccessorList?.Accessors.Any(a => a.Kind() == SyntaxKind.GetAccessorDeclaration) ?? false,
                HasSetter = p.AccessorList?.Accessors.Any(a => a.Kind() == SyntaxKind.SetAccessorDeclaration) ?? false
            }).ToList();

        var interfaces = classNode.BaseList?.Types
            .Select(t => t.ToString())
            .Where(t => t.StartsWith("I"))
            .ToList() ?? new List<string>();

        models.Add(new {
            FileName = Path.GetFileName(file),
            FilePath = file,
            ClassName = className,
            IsInterface = className.StartsWith("I"),
            IsView = className.StartsWith("View"),
            IsParam = className.StartsWith("Param"),
            PropertyCount = properties.Count,
            Properties = properties,
            Interfaces = interfaces,
            LineCount = code.Split('\n').Length
        });
    }
}

var json = JsonSerializer.Serialize(models, new JsonSerializerOptions { WriteIndented = true });
File.WriteAllText(outputFile, json);
Console.WriteLine($"Scanned {models.Count} models from {Directory.GetFiles(modelsPath, "*.cs", SearchOption.AllDirectories).Length} files");
```

**Script 3: Recursive Dependency Analyzer** (`scripts/analyze-dependencies.ps1`)
```powershell
# Analyze project dependencies recursively
$solutionFile = "Carmen.NET.sln"
$outputFile = "analysis/dependencies/dependency-graph.json"

$projects = @()
$dependencies = @()

# Parse solution file for projects
$solutionContent = Get-Content $solutionFile
$projectPattern = 'Project\("[^"]+"\)\s*=\s*"([^"]+)",\s*"([^"]+)"'

$solutionContent | Select-String -Pattern $projectPattern -AllMatches | ForEach-Object {
    $_.Matches | ForEach-Object {
        $projectName = $_.Groups[1].Value
        $projectPath = $_.Groups[2].Value

        if ($projectPath -match '\.csproj$') {
            $projects += @{
                Name = $projectName
                Path = $projectPath
            }
        }
    }
}

# Analyze each project for dependencies
foreach ($project in $projects) {
    if (Test-Path $project.Path) {
        [xml]$csproj = Get-Content $project.Path

        # Project references
        $projectRefs = $csproj.Project.ItemGroup.ProjectReference.Include
        foreach ($ref in $projectRefs) {
            if ($ref) {
                $refName = [System.IO.Path]::GetFileNameWithoutExtension($ref)
                $dependencies += @{
                    From = $project.Name
                    To = $refName
                    Type = "ProjectReference"
                }
            }
        }

        # NuGet packages
        $packages = $csproj.Project.ItemGroup.PackageReference
        foreach ($pkg in $packages) {
            if ($pkg.Include) {
                $dependencies += @{
                    From = $project.Name
                    To = $pkg.Include
                    Version = $pkg.Version
                    Type = "NuGetPackage"
                }
            }
        }
    }
}

$result = @{
    Projects = $projects
    Dependencies = $dependencies
    ProjectCount = $projects.Count
    DependencyCount = $dependencies.Count
}

$result | ConvertTo-Json -Depth 10 | Out-File $outputFile
Write-Host "Analyzed $($projects.Count) projects with $($dependencies.Count) dependencies"
```

**Script 4: Recursive API Endpoint Extractor** (`scripts/extract-api-endpoints.ps1`)
```powershell
# Extract all API endpoints recursively
$controllersPath = "Carmen.WebApi/Controllers"
$outputFile = "analysis/api/api-endpoints.json"

$endpoints = @()

Get-ChildItem -Path $controllersPath -Filter "*Controller.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $controllerName = $_.BaseName -replace 'Controller$', ''

    # Extract route attributes
    $routeMatches = [regex]::Matches($content, '\[Route\("([^"]+)"\)\]\s+public\s+(?:async\s+)?Task<[^>]+>\s+(\w+)\s*\(([^)]*)\)')

    foreach ($match in $routeMatches) {
        $route = $match.Groups[1].Value
        $methodName = $match.Groups[2].Value
        $parameters = $match.Groups[3].Value

        # Extract HTTP method
        $httpMethod = "GET" # default
        if ($content -match "\[Http(Get|Post|Put|Delete|Patch)\]\s+(?:\[Route[^\]]+\]\s+)?public\s+(?:async\s+)?Task<[^>]+>\s+$methodName") {
            $httpMethod = $Matches[1].ToUpper()
        }

        # Extract permissions
        $permission = if ($content -match "GetPermissionInfoByPermissionNameAsync\(`"([^`"]+)`"\)") { $Matches[1] } else { $null }

        $endpoints += @{
            Controller = $controllerName
            Route = $route
            HttpMethod = $httpMethod
            MethodName = $methodName
            Parameters = $parameters
            Permission = $permission
            File = $_.Name
        }
    }
}

$endpoints | ConvertTo-Json -Depth 10 | Out-File $outputFile
Write-Host "Extracted $($endpoints.Count) API endpoints"
```

**Script 5: Business Rule Extractor** (`scripts/extract-business-rules.ps1`)
```powershell
# Extract business rules from code
$controllersPath = "Carmen.WebApi/Controllers"
$outputFile = "analysis/business-rules/extracted-rules.json"

$rules = @()

Get-ChildItem -Path $controllersPath -Filter "*.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Extract validation patterns
    $validations = [regex]::Matches($content, 'if\s*\(([^)]+)\)\s*(?:return|throw)[^;]+;')
    foreach ($match in $validations) {
        $rules += @{
            Type = "Validation"
            Condition = $match.Groups[1].Value.Trim()
            File = $_.Name
            Location = "Controller"
        }
    }

    # Extract permission checks
    $permissions = [regex]::Matches($content, 'if\s*\(!\s*permission\.(\w+)\)\s*return')
    foreach ($match in $permissions) {
        $rules += @{
            Type = "Permission"
            Action = $match.Groups[1].Value
            File = $_.Name
            Location = "Controller"
        }
    }
}

$rules | ConvertTo-Json -Depth 10 | Out-File $outputFile
Write-Host "Extracted $($rules.Count) business rules"
```

#### 0.4 Validation Checklist
- [ ] All tools installed and verified
- [ ] Scripts tested and working
- [ ] Documentation structure created
- [ ] Team access to repositories configured
- [ ] Backup of source code created

---

## Phase 1: Automated Code Discovery (Week 1, Days 3-5)

### Objectives
- Recursively scan entire codebase
- Generate comprehensive inventory
- Map all relationships and dependencies
- Extract metadata from all files

### Tasks

#### 1.1 Recursive Code Scanning

**Execute All Analysis Scripts**:
```bash
# Run all scanners in parallel
./scripts/scan-controllers.ps1 &
dotnet script scripts/scan-models.csx &
./scripts/analyze-dependencies.ps1 &
./scripts/extract-api-endpoints.ps1 &
./scripts/extract-business-rules.ps1 &

wait

# Generate summary report
./scripts/generate-summary.ps1
```

**Expected Outputs**:
- `analysis/controllers/controller-inventory.json` (101 controllers)
- `analysis/models/model-inventory.json` (600+ models)
- `analysis/dependencies/dependency-graph.json`
- `analysis/api/api-endpoints.json` (500+ endpoints)
- `analysis/business-rules/extracted-rules.json`

#### 1.2 Deep Code Analysis (Recursive)

**Script: Recursive Code Analyzer** (`scripts/deep-analysis.csx`)
```csharp
#r "nuget: Microsoft.CodeAnalysis.CSharp.Workspaces, 4.0.1"

using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.MSBuild;
using System.IO;
using System.Text.Json;

var workspace = MSBuildWorkspace.Create();
var solution = await workspace.OpenSolutionAsync("Carmen.NET.sln");

var analysis = new {
    Projects = new List<object>(),
    Classes = new List<object>(),
    Methods = new List<object>(),
    Dependencies = new List<object>()
};

foreach (var project in solution.Projects)
{
    Console.WriteLine($"Analyzing project: {project.Name}");

    var compilation = await project.GetCompilationAsync();

    foreach (var syntaxTree in compilation.SyntaxTrees)
    {
        var root = await syntaxTree.GetRootAsync();
        var semanticModel = compilation.GetSemanticModel(syntaxTree);

        // Recursively analyze all class declarations
        var classes = root.DescendantNodes().OfType<ClassDeclarationSyntax>();

        foreach (var classNode in classes)
        {
            var classSymbol = semanticModel.GetDeclaredSymbol(classNode);

            // Extract class metadata
            analysis.Classes.Add(new {
                Project = project.Name,
                ClassName = classSymbol?.Name,
                Namespace = classSymbol?.ContainingNamespace?.ToDisplayString(),
                BaseType = classSymbol?.BaseType?.Name,
                Interfaces = classSymbol?.Interfaces.Select(i => i.Name).ToList(),
                IsAbstract = classSymbol?.IsAbstract,
                IsSealed = classSymbol?.IsSealed,
                AccessModifier = classSymbol?.DeclaredAccessibility.ToString()
            });

            // Recursively analyze methods
            var methods = classNode.Members.OfType<MethodDeclarationSyntax>();

            foreach (var method in methods)
            {
                var methodSymbol = semanticModel.GetDeclaredSymbol(method);

                analysis.Methods.Add(new {
                    Project = project.Name,
                    Class = classSymbol?.Name,
                    MethodName = methodSymbol?.Name,
                    ReturnType = methodSymbol?.ReturnType?.Name,
                    Parameters = methodSymbol?.Parameters.Select(p => new {
                        p.Name,
                        Type = p.Type.Name
                    }).ToList(),
                    IsAsync = methodSymbol?.IsAsync,
                    IsPublic = methodSymbol?.DeclaredAccessibility == Accessibility.Public
                });
            }
        }
    }
}

// Save analysis results
var json = JsonSerializer.Serialize(analysis, new JsonSerializerOptions { WriteIndented = true });
File.WriteAllText("analysis/deep-analysis.json", json);

Console.WriteLine($"Analysis complete: {analysis.Classes.Count} classes, {analysis.Methods.Count} methods");
```

**Execute**:
```bash
dotnet script scripts/deep-analysis.csx
```

#### 1.3 Database Schema Reverse Engineering

**Using EF Power Tools or Manual Analysis**:
```bash
# Generate database context from existing database
Scaffold-DbContext "Server=.;Database=Carmen;Trusted_Connection=True;" Microsoft.EntityFrameworkCore.SqlServer -OutputDir analysis/database/generated -Context CarmenDbContext

# Or analyze models to infer schema
./scripts/infer-database-schema.ps1
```

**Script: Schema Inference** (`scripts/infer-database-schema.ps1`)
```powershell
# Infer database schema from model classes
$modelsJson = Get-Content "analysis/models/model-inventory.json" | ConvertFrom-Json

$tables = @()

foreach ($model in $modelsJson) {
    if (-not ($model.ClassName.StartsWith("View") -or $model.ClassName.StartsWith("Param") -or $model.ClassName.StartsWith("I"))) {
        $tables += @{
            TableName = $model.ClassName
            Columns = $model.Properties | ForEach-Object {
                @{
                    Name = $_.Name
                    DataType = $_.Type
                    Nullable = $_.Type -match '\?$'
                }
            }
            ForeignKeys = $model.Properties | Where-Object { $_.Name -match 'Code$' -or $_.Name -match 'Id$' } | ForEach-Object { $_.Name }
        }
    }
}

$tables | ConvertTo-Json -Depth 10 | Out-File "analysis/database/inferred-schema.json"
Write-Host "Inferred schema for $($tables.Count) tables"
```

#### 1.4 Workflow & State Machine Extraction

**Script: Extract State Machines** (`scripts/extract-workflows.ps1`)
```powershell
# Extract status enums and workflow transitions
$enumsPath = "Carmen.Enum"
$controllersPath = "Carmen.WebApi/Controllers"
$outputFile = "analysis/workflows/state-machines.json"

$stateMachines = @()

# Find all status enums
Get-ChildItem -Path $enumsPath -Filter "Enum*Status.cs" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $enumName = $_.BaseName

    # Extract enum values
    $values = [regex]::Matches($content, '(\w+)\s*(?:=\s*\d+)?,?\s*(?://.*)?') |
        Where-Object { $_.Groups[1].Value -notmatch '^(public|enum|namespace)' } |
        ForEach-Object { $_.Groups[1].Value }

    $stateMachines += @{
        EnumName = $enumName
        States = $values
        Module = if ($enumName -match '^EnumAp') { "AP" }
                 elseif ($enumName -match '^EnumAr') { "AR" }
                 elseif ($enumName -match '^EnumGl') { "GL" }
                 elseif ($enumName -match '^EnumAsset') { "Asset" }
                 else { "General" }
    }
}

$stateMachines | ConvertTo-Json -Depth 10 | Out-File $outputFile
Write-Host "Extracted $($stateMachines.Count) state machines"
```

#### 1.5 Generate Dependency Graphs

**Using Roslyn and GraphViz**:
```bash
# Generate visual dependency graph
./scripts/generate-dependency-graph.ps1
dot -Tpng analysis/dependencies/dependency-graph.dot -o docs/architecture/dependency-graph.png
dot -Tsvg analysis/dependencies/dependency-graph.dot -o docs/architecture/dependency-graph.svg
```

**Script: Generate Dependency Graph** (`scripts/generate-dependency-graph.ps1`)
```powershell
$depsJson = Get-Content "analysis/dependencies/dependency-graph.json" | ConvertFrom-Json
$outputDot = "analysis/dependencies/dependency-graph.dot"

$dot = @"
digraph Carmen {
    rankdir=LR;
    node [shape=box, style=rounded];

"@

# Add project nodes
foreach ($project in $depsJson.Projects) {
    $dot += "    `"$($project.Name)`" [fillcolor=lightblue, style=`"rounded,filled`"];`n"
}

# Add dependency edges
foreach ($dep in $depsJson.Dependencies | Where-Object { $_.Type -eq "ProjectReference" }) {
    $dot += "    `"$($dep.From)`" -> `"$($dep.To)`";`n"
}

$dot += "}"

$dot | Out-File $outputDot
Write-Host "Dependency graph generated at $outputDot"
```

#### 1.6 Quality Metrics Collection

**Script: Calculate Code Metrics** (`scripts/calculate-metrics.ps1`)
```powershell
# Calculate comprehensive code metrics
$metrics = @{
    Controllers = (Get-ChildItem "Carmen.WebApi/Controllers" -Filter "*.cs" -Recurse).Count
    Models = (Get-ChildItem "Carmen.Models" -Filter "*.cs" -Recurse).Count
    Enums = (Get-ChildItem "Carmen.Enum" -Filter "*.cs" -Recurse).Count
    TotalFiles = (Get-ChildItem -Path . -Filter "*.cs" -Recurse).Count
    TotalLines = (Get-ChildItem -Path . -Filter "*.cs" -Recurse | Get-Content | Measure-Object -Line).Lines
    Projects = ([xml](Get-Content "Carmen.NET.sln")).Project.ItemGroup.ProjectReference.Count
}

# Complexity analysis (simple heuristic)
$avgComplexity = 0
Get-ChildItem -Path "Carmen.WebApi/Controllers" -Filter "*.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $ifCount = ([regex]::Matches($content, '\bif\s*\(')).Count
    $forCount = ([regex]::Matches($content, '\b(for|foreach|while)\s*\(')).Count
    $switchCount = ([regex]::Matches($content, '\bswitch\s*\(')).Count
    $avgComplexity += $ifCount + $forCount + $switchCount
}
$metrics.AverageCyclomaticComplexity = [math]::Round($avgComplexity / $metrics.Controllers, 2)

$metrics | ConvertTo-Json -Depth 10 | Out-File "analysis/code-metrics.json"
$metrics | Format-Table | Out-File "analysis/code-metrics.txt"

Write-Host "Code Metrics:"
$metrics | Format-List
```

### Deliverables (Phase 1)
- ✅ Complete code inventory (JSON format)
- ✅ Dependency graphs (visual + data)
- ✅ API endpoint catalog
- ✅ Business rules extraction
- ✅ Code quality metrics
- ✅ Database schema inference

---

## Phase 2: Architecture & Data Modeling (Week 2)

### Objectives
- Generate architecture diagrams
- Create ERD diagrams
- Map integration points
- Document security model

### Tasks

#### 2.1 Generate Architecture Diagrams

**Script: Auto-Generate C4 Diagrams** (`scripts/generate-c4-diagrams.ps1`)
```powershell
# Generate PlantUML C4 diagrams from analysis data

# System Context Diagram
$c4Context = @"
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

LAYOUT_WITH_LEGEND()

title System Context Diagram - Carmen.NET ERP

Person(user, "Business User", "AP/AR/GL clerk, Manager, Accountant")
Person(admin, "System Admin", "IT administrator")

System(carmen, "Carmen.NET ERP", "Multi-tenant financial ERP system")

System_Ext(bank, "Banking System", "Payment file exchange")
System_Ext(tax, "Tax Authority", "Tax filing integration")
System_Ext(excel, "Microsoft Excel", "Excel add-in integration")

Rel(user, carmen, "Uses", "HTTPS")
Rel(admin, carmen, "Configures", "HTTPS")
Rel(carmen, bank, "Exchanges payment files", "File/API")
Rel(carmen, tax, "Submits tax reports", "File/API")
Rel(excel, carmen, "Integrates with", "REST API")

@enduml
"@

$c4Context | Out-File "docs/architecture/c4-context.puml"

# Container Diagram
$c4Container = @"
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title Container Diagram - Carmen.NET

Person(user, "User")

System_Boundary(carmen, "Carmen.NET") {
    Container(webapp, "Web Application", "ASP.NET MVC", "User interface")
    Container(webapi, "Web API", "ASP.NET Web API", "REST API (101 endpoints)")
    Container(functions, "Business Logic", ".NET Classes", "Business rules & workflows")
    ContainerDb(db, "Database", "SQL Server", "Multi-tenant data storage")
    Container(licenseApi, "License API", "ASP.NET Web API", "License validation")
}

Rel(user, webapp, "Uses", "HTTPS")
Rel(webapp, webapi, "Calls", "HTTPS/JSON")
Rel(webapi, functions, "Uses")
Rel(functions, db, "Reads/Writes", "ADO.NET/EF")
Rel(webapi, licenseApi, "Validates", "HTTPS")

@enduml
"@

$c4Container | Out-File "docs/architecture/c4-container.puml"

Write-Host "C4 diagrams generated. Render with: plantuml docs/architecture/*.puml"
```

**Generate Component Diagram**:
```bash
# Auto-generate from dependency analysis
./scripts/generate-component-diagram.ps1
```

#### 2.2 Generate ERD Diagrams

**Script: Auto-Generate ERD** (`scripts/generate-erd.ps1`)
```powershell
# Generate ERD from model analysis
$modelsJson = Get-Content "analysis/models/model-inventory.json" | ConvertFrom-Json

$erdModules = @("Ap", "Ar", "Gl", "Asset", "Income")

foreach ($module in $erdModules) {
    $erdContent = "@startuml`n"
    $erdContent += "title $module Module - Entity Relationship Diagram`n`n"

    # Filter models for this module
    $moduleModels = $modelsJson | Where-Object {
        $_.ClassName -match "^$module" -and
        -not ($_.ClassName.StartsWith("View") -or $_.ClassName.StartsWith("Param") -or $_.IsInterface)
    }

    foreach ($model in $moduleModels) {
        $erdContent += "entity `"$($model.ClassName)`" {`n"
        foreach ($prop in $model.Properties) {
            $erdContent += "  * $($prop.Name) : $($prop.Type)`n"
        }
        $erdContent += "}`n`n"
    }

    # Add relationships (inferred from naming conventions)
    foreach ($model in $moduleModels) {
        foreach ($prop in $model.Properties) {
            if ($prop.Name -match '(\w+)Code$' -or $prop.Name -match '(\w+)Id$') {
                $relatedEntity = $Matches[1]
                $erdContent += "`"$($model.ClassName)`" }o--|| `"$relatedEntity`"`n"
            }
        }
    }

    $erdContent += "@enduml"

    $erdContent | Out-File "docs/database/erd-$module.puml"
}

Write-Host "ERD diagrams generated for $($erdModules.Count) modules"
```

#### 2.3 Security Architecture Documentation

**Script: Extract Security Model** (`scripts/analyze-security.ps1`)
```powershell
# Analyze authentication and authorization patterns
$controllersPath = "Carmen.WebApi/Controllers"
$outputFile = "docs/architecture/security-model.md"

$securityDoc = @"
# Carmen.NET Security Architecture

## Authentication

### Login Flow
"@

# Extract login controller logic
$loginController = Get-Content "$controllersPath/LoginController.cs" -Raw
$securityDoc += @"

Based on LoginController analysis:
- Token-based authentication (JWT inferred)
- Username/password authentication
- Token endpoint: ``/api/login``

## Authorization

### Permission Model
"@

# Extract permission checks
$permissions = @()
Get-ChildItem -Path $controllersPath -Filter "*.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $permMatches = [regex]::Matches($content, 'GetPermissionInfoByPermissionNameAsync\("([^"]+)"\)')
    foreach ($match in $permMatches) {
        $permissions += $match.Groups[1].Value
    }
}

$uniquePermissions = $permissions | Select-Object -Unique | Sort-Object

$securityDoc += "`n`n### Permission List ($($uniquePermissions.Count) unique permissions):`n`n"
foreach ($perm in $uniquePermissions) {
    $securityDoc += "- ``$perm```n"
}

$securityDoc += @"

## Multi-Tenant Security

### Tenant Isolation
- Tenant context applied via ``useTenant`` parameter
- ``FncBase.ApplyTenantIfUseTenant(useTenant)`` pattern used throughout
- Data segregation at database level (inferred)

## API Security

### Endpoint Protection
- All endpoints marked with ``[Authorize]`` attribute
- Permission checks before data access
- Standardized error responses (no information leakage)
"@

$securityDoc | Out-File $outputFile
Write-Host "Security architecture documented at $outputFile"
```

#### 2.4 Integration Architecture

**Script: Map Integration Points** (`scripts/map-integrations.ps1`)
```powershell
# Analyze integration capabilities
$interfaceModelsPath = "Carmen.Models.Interface"
$outputFile = "docs/architecture/integration-architecture.md"

$integrationDoc = @"
# Carmen.NET Integration Architecture

## Integration Types

Based on Carmen.Models.Interface analysis:
"@

Get-ChildItem -Path $interfaceModelsPath -Filter "*.cs" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $className = $_.BaseName

    $integrationDoc += "`n### $className`n"
    $integrationDoc += "``````csharp`n"
    $integrationDoc += $content
    $integrationDoc += "`n```````n"
}

$integrationDoc += @"

## Integration Patterns

### File-Based Integration
- CSV import/export
- Excel integration
- Banking file formats

### Database Integration
- Direct database-to-database sync
- SQL Server linked servers (inferred)

### API Integration
- REST API endpoints (101 controllers)
- Swagger documentation
- JSON request/response

### Banking Integration
- Payment file generation
- Bank statement import
- Reconciliation automation
"@

$integrationDoc | Out-File $outputFile
Write-Host "Integration architecture documented"
```

### Deliverables (Phase 2)
- ✅ C4 architecture diagrams (Context, Container, Component)
- ✅ ERD diagrams per module (AP, AR, GL, Asset, Income)
- ✅ Security architecture documentation
- ✅ Integration architecture documentation
- ✅ Deployment architecture diagram

---

## Phase 3: Business Logic & Workflow Analysis (Week 3)

### Objectives
- Extract and document all business rules
- Map workflow state machines
- Document approval processes
- Create business process flows

### Tasks

#### 3.1 Comprehensive Business Rule Extraction

**Script: Advanced Rule Extractor** (`scripts/extract-all-business-rules.csx`)
```csharp
#r "nuget: Microsoft.CodeAnalysis.CSharp, 4.0.1"

using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Text.Json;

var rules = new List<object>();

// Scan Functions folder for business logic
var functionsPath = "Carmen.WebApi/Functions";
var controllerPath = "Carmen.WebApi/Controllers";

void AnalyzeFile(string filePath, string location)
{
    var code = File.ReadAllText(filePath);
    var tree = CSharpSyntaxTree.ParseText(code);
    var root = tree.GetRoot();

    // Extract validation rules
    var ifStatements = root.DescendantNodes().OfType<IfStatementSyntax>();
    foreach (var ifStmt in ifStatements)
    {
        var condition = ifStmt.Condition.ToString();
        var consequence = ifStmt.Statement.ToString();

        // Check if it's a validation
        if (consequence.Contains("throw") || consequence.Contains("return") || consequence.Contains("error"))
        {
            rules.Add(new {
                Type = "Validation",
                Condition = condition,
                Action = consequence.Length > 100 ? consequence.Substring(0, 100) + "..." : consequence,
                File = Path.GetFileName(filePath),
                Location = location,
                LineNumber = ifStmt.GetLocation().GetLineSpan().StartLinePosition.Line
            });
        }
    }

    // Extract switch statements (often contain business rules)
    var switchStatements = root.DescendantNodes().OfType<SwitchStatementSyntax>();
    foreach (var switchStmt in switchStatements)
    {
        rules.Add(new {
            Type = "BusinessLogic",
            Pattern = "SwitchStatement",
            Expression = switchStmt.Expression.ToString(),
            Cases = switchStmt.Sections.Count,
            File = Path.GetFileName(filePath),
            Location = location,
            LineNumber = switchStmt.GetLocation().GetLineSpan().StartLinePosition.Line
        });
    }

    // Extract calculation methods
    var methods = root.DescendantNodes().OfType<MethodDeclarationSyntax>()
        .Where(m => m.Identifier.Text.Contains("Calculate") ||
                    m.Identifier.Text.Contains("Compute") ||
                    m.Identifier.Text.Contains("Total"));

    foreach (var method in methods)
    {
        rules.Add(new {
            Type = "Calculation",
            MethodName = method.Identifier.Text,
            ReturnType = method.ReturnType.ToString(),
            Parameters = method.ParameterList.Parameters.Count,
            File = Path.GetFileName(filePath),
            Location = location,
            LineNumber = method.GetLocation().GetLineSpan().StartLinePosition.Line
        });
    }
}

// Analyze all C# files
foreach (var file in Directory.GetFiles(functionsPath, "*.cs", SearchOption.AllDirectories))
{
    AnalyzeFile(file, "Functions");
}

foreach (var file in Directory.GetFiles(controllerPath, "*.cs", SearchOption.AllDirectories))
{
    AnalyzeFile(file, "Controllers");
}

var json = JsonSerializer.Serialize(rules, new JsonSerializerOptions { WriteIndented = true });
File.WriteAllText("analysis/business-rules/comprehensive-rules.json", json);

Console.WriteLine($"Extracted {rules.Count} business rules");
```

#### 3.2 Workflow State Machine Generator

**Script: Generate Workflow Diagrams** (`scripts/generate-workflow-diagrams.ps1`)
```powershell
# Generate Mermaid state diagrams for all workflows
$workflowsJson = Get-Content "analysis/workflows/state-machines.json" | ConvertFrom-Json

foreach ($workflow in $workflowsJson) {
    $mermaid = @"
# $($workflow.EnumName) Workflow

``````mermaid
stateDiagram-v2
    [*] --> $($workflow.States[0])
"@

    # Generate transitions (simplified heuristic based on typical patterns)
    for ($i = 0; $i -lt $workflow.States.Count - 1; $i++) {
        $current = $workflow.States[$i]
        $next = $workflow.States[$i + 1]
        $mermaid += "`n    $current --> $next"
    }

    $mermaid += "`n    $($workflow.States[-1]) --> [*]"
    $mermaid += "`n``````"

    $fileName = $workflow.EnumName -replace "^Enum", "" -replace "Status$", ""
    $mermaid | Out-File "docs/workflows/$fileName-workflow.md"
}

Write-Host "Generated workflow diagrams for $($workflowsJson.Count) state machines"
```

#### 3.3 Approval Process Documentation

**Script: Extract Approval Logic** (`scripts/extract-approval-logic.ps1`)
```powershell
# Search for workflow and approval patterns
$controllersPath = "Carmen.WebApi/Controllers"
$workflowController = Get-Content "$controllersPath/WorkflowController.cs" -Raw

$approvalDoc = @"
# Approval Workflows

## Workflow Modules

Based on EnumWorkflowModule:
- AP_VENDOR: Vendor approval workflow
- AP_INVOICE: Invoice approval workflow
- AP_PAYMENT: Payment approval workflow
- AR_INVOICE: Customer invoice approval
- AR_RECEIPT: Receipt approval workflow

## Approval Patterns

### Detected Approval Logic:
"@

# Extract approval-related code
$approvalMethods = [regex]::Matches($workflowController, 'public\s+(?:async\s+)?Task<[^>]+>\s+(Approve\w*|Reject\w*)\s*\([^)]*\)')
foreach ($match in $approvalMethods) {
    $approvalDoc += "`n- ``$($match.Groups[1].Value)``"
}

$approvalDoc | Out-File "docs/workflows/approval-processes.md"
Write-Host "Approval processes documented"
```

### Deliverables (Phase 3)
- ✅ Comprehensive business rules catalog (1000+ rules)
- ✅ Workflow state diagrams (Mermaid format)
- ✅ Approval process documentation
- ✅ Calculation formulas extracted
- ✅ Validation rules catalog

---

## Phase 4: API & Integration Documentation (Week 4)

### Objectives
- Generate complete API documentation
- Create integration guides
- Document data formats
- Provide code examples

### Tasks

#### 4.1 Enhanced Swagger Documentation

**Script: Enhance Swagger with Examples** (`scripts/enhance-swagger.csx`)
```csharp
// This would integrate with Swashbuckle to add examples
// For now, we'll generate supplementary API documentation

using System.Text.Json;

var endpointsJson = File.ReadAllText("analysis/api/api-endpoints.json");
var endpoints = JsonSerializer.Deserialize<List<Dictionary<string, object>>>(endpointsJson);

var apiDoc = "# Carmen.NET API Reference\n\n";
apiDoc += $"Total Endpoints: {endpoints.Count}\n\n";

// Group by controller
var grouped = endpoints.GroupBy(e => e["Controller"].ToString());

foreach (var group in grouped.OrderBy(g => g.Key))
{
    apiDoc += $"\n## {group.Key} API\n\n";

    foreach (var endpoint in group)
    {
        apiDoc += $"### {endpoint["HttpMethod"]} {endpoint["Route"]}\n\n";
        apiDoc += $"**Method**: `{endpoint["MethodName"]}`\n\n";

        if (endpoint.ContainsKey("Permission") && endpoint["Permission"] != null)
        {
            apiDoc += $"**Required Permission**: `{endpoint["Permission"]}`\n\n";
        }

        apiDoc += $"**Parameters**: `{endpoint["Parameters"]}`\n\n";
        apiDoc += "---\n\n";
    }
}

File.WriteAllText("docs/api/api-reference-complete.md", apiDoc);
Console.WriteLine($"API documentation generated for {endpoints.Count} endpoints");
```

#### 4.2 Generate Postman Collection

**Script: Auto-Generate Postman Collection** (`scripts/generate-postman-collection.ps1`)
```powershell
# Generate Postman collection from API analysis
$endpointsJson = Get-Content "analysis/api/api-endpoints.json" | ConvertFrom-Json

$collection = @{
    info = @{
        name = "Carmen.NET API"
        description = "Auto-generated API collection"
        schema = "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    }
    item = @()
}

# Group by controller
$grouped = $endpointsJson | Group-Object -Property Controller

foreach ($group in $grouped) {
    $folder = @{
        name = $group.Name
        item = @()
    }

    foreach ($endpoint in $group.Group) {
        $request = @{
            name = $endpoint.MethodName
            request = @{
                method = $endpoint.HttpMethod
                header = @(
                    @{ key = "Authorization"; value = "Bearer {{token}}" }
                    @{ key = "Content-Type"; value = "application/json" }
                )
                url = @{
                    raw = "{{baseUrl}}$($endpoint.Route)"
                    host = @("{{baseUrl}}")
                    path = $endpoint.Route -split '/' | Where-Object { $_ -ne '' }
                }
            }
        }

        if ($endpoint.HttpMethod -eq "POST" -or $endpoint.HttpMethod -eq "PUT") {
            $request.request.body = @{
                mode = "raw"
                raw = "{}"
            }
        }

        $folder.item += $request
    }

    $collection.item += $folder
}

$collection | ConvertTo-Json -Depth 10 | Out-File "docs/api/carmen-api-postman-collection.json"
Write-Host "Postman collection generated with $($endpointsJson.Count) requests"
```

#### 4.3 Integration Examples

**Create Integration Guide**:
```markdown
# docs/api/integration-guide.md

# Carmen.NET Integration Guide

## Authentication

### Obtain Access Token
\`\`\`http
POST /api/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password"
}
\`\`\`

**Response**:
\`\`\`json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600
}
\`\`\`

### Use Token
\`\`\`http
GET /api/apInvoice
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
\`\`\`

## Common Integration Scenarios

### Scenario 1: Create AP Invoice
[Step-by-step with code examples]

### Scenario 2: Process Payment
[Step-by-step with code examples]

### Scenario 3: Export Financial Reports
[Step-by-step with code examples]
```

### Deliverables (Phase 4)
- ✅ Complete API reference documentation
- ✅ Postman collection (importable)
- ✅ Integration guide with examples
- ✅ Authentication & authorization guide
- ✅ Error code catalog

---

## Phase 5: Audience-Specific Documentation (Weeks 5-6)

### Objectives
- Generate stakeholder documentation
- Create architect documentation
- Write BA functional specs
- Produce developer guides
- Design UI/UX documentation

### Tasks

#### 5.1 Auto-Generate Executive Summary

**Script: Generate Executive Summary** (`scripts/generate-executive-summary.ps1`)
```powershell
# Compile metrics and insights into executive summary
$metrics = Get-Content "analysis/code-metrics.json" | ConvertFrom-Json
$controllers = Get-Content "analysis/controllers/controller-inventory.json" | ConvertFrom-Json
$deps = Get-Content "analysis/dependencies/dependency-graph.json" | ConvertFrom-Json

$execSummary = @"
# Carmen.NET Executive Summary

## System Overview
Carmen.NET is a comprehensive multi-tenant financial ERP system built on .NET technology.

## Key Metrics
- **Total Code Lines**: $($metrics.TotalLines.ToString('N0'))
- **Projects**: $($deps.ProjectCount)
- **API Endpoints**: $($controllers.Count)
- **Business Modules**: 11 core modules
- **Sub-Modules**: 78+ functional areas

## Technology Stack
- Platform: .NET Framework
- API: ASP.NET Web API
- Database: SQL Server (inferred)
- Authentication: Token-based (JWT)

## Business Capabilities
✓ Accounts Payable Management
✓ Accounts Receivable Management
✓ General Ledger & Financial Reporting
✓ Fixed Asset Management
✓ Tax Compliance (VAT/WHT)
✓ Multi-tenant SaaS Architecture

## Technical Health
- Code Quality: Moderate complexity (Avg cyclomatic: $($metrics.AverageCyclomaticComplexity))
- Architecture: Well-structured 3-tier architecture
- API Design: RESTful with Swagger documentation
- Security: Role-based access control

## Modernization Recommendations
1. Migrate to .NET 8+ (from .NET Framework)
2. Implement comprehensive unit test coverage
3. Enhance API documentation with examples
4. Consider microservices architecture for scalability
5. Implement CI/CD pipelines

## Risk Assessment
- **Technical Debt**: Moderate (legacy .NET Framework)
- **Documentation**: Limited (requires comprehensive documentation)
- **Testing**: Unknown coverage (needs assessment)
- **Scalability**: Good (multi-tenant ready)

## Strategic Roadmap
### Phase 1: Documentation (Current)
Complete reverse engineering and documentation

### Phase 2: Modernization
Migrate to modern .NET platform

### Phase 3: Enhancement
Add new features and improve UX

### Phase 4: Optimization
Performance tuning and scaling
"@

$execSummary | Out-File "docs/executive/executive-summary.md"
Write-Host "Executive summary generated"
```

#### 5.2 Generate Complete Architecture Documentation

```bash
# Consolidate all architecture artifacts
./scripts/consolidate-architecture-docs.ps1
```

#### 5.3 Generate Functional Requirements

**Script: Auto-Generate Functional Requirements** (`scripts/generate-functional-requirements.ps1`)
```powershell
# Generate functional requirements from code analysis
$controllers = Get-Content "analysis/controllers/controller-inventory.json" | ConvertFrom-Json
$rules = Get-Content "analysis/business-rules/comprehensive-rules.json" | ConvertFrom-Json

$funcReqs = @"
# Carmen.NET Functional Requirements

## Reverse Engineered Requirements

This document contains functional requirements extracted from the source code.
"@

# Group by module
$modules = @("Ap", "Ar", "Gl", "Asset", "Income")

foreach ($module in $modules) {
    $funcReqs += "`n## $module Module`n`n"

    # Find controllers for this module
    $moduleControllers = $controllers | Where-Object { $_.Name -match "^$module" }

    foreach ($ctrl in $moduleControllers) {
        $funcReqs += "`n### $($ctrl.Name)`n`n"
        $funcReqs += "**Endpoints**: $($ctrl.Routes.Count)`n"
        $funcReqs += "**HTTP Methods**: $($ctrl.HttpMethods -join ', ')`n`n"

        # Add business rules for this controller
        $ctrlRules = $rules | Where-Object { $_.File -eq "$($ctrl.Name).cs" }
        if ($ctrlRules.Count -gt 0) {
            $funcReqs += "**Business Rules**: $($ctrlRules.Count) identified`n`n"
        }
    }
}

$funcReqs | Out-File "docs/requirements/functional-requirements.md"
Write-Host "Functional requirements generated"
```

#### 5.4 Generate Developer Guide

**Create comprehensive developer guide with code examples**:
```bash
./scripts/generate-developer-guide.ps1
```

#### 5.5 Generate UI/UX Documentation

**Script: Extract UI Patterns** (would require actual frontend analysis)
```powershell
# Placeholder for UI pattern extraction
# This would analyze Razor views, JavaScript, CSS
# For now, create template

$uiDoc = @"
# Carmen.NET UI/UX Documentation

## UI Framework
[To be analyzed from frontend code]

## Screen Catalog
[Generated from view analysis]

## Component Library
[Extracted from UI code]

## Design Patterns
[Identified from CSS/JS]
"@

$uiDoc | Out-File "docs/design/ui-documentation.md"
```

### Deliverables (Phase 5)
- ✅ Executive summary
- ✅ Complete architecture documentation
- ✅ Functional requirements (all modules)
- ✅ Developer guide with examples
- ✅ UI/UX documentation (template)

---

## Phase 6: Validation & Quality Assurance (Week 7)

### Objectives
- Validate all documentation
- Verify code-to-doc accuracy
- Conduct stakeholder reviews
- Identify gaps

### Tasks

#### 6.1 Automated Documentation Validation

**Script: Validate Documentation** (`scripts/validate-documentation.ps1`)
```powershell
# Check documentation completeness
$validationReport = @{
    ExecutiveDocsComplete = Test-Path "docs/executive/executive-summary.md"
    ArchitectureDocsComplete = Test-Path "docs/architecture/system-architecture.md"
    APIDocsComplete = Test-Path "docs/api/api-reference-complete.md"
    FunctionalReqsComplete = Test-Path "docs/requirements/functional-requirements.md"
    WorkflowDocsComplete = (Get-ChildItem "docs/workflows" -Filter "*.md").Count -gt 0
    DatabaseDocsComplete = Test-Path "docs/database/inferred-schema.json"
    DeveloperGuideComplete = Test-Path "docs/development/code-structure.md"
    TotalDocuments = (Get-ChildItem "docs" -Filter "*.md" -Recurse).Count
    TotalDiagrams = (Get-ChildItem "docs" -Filter "*.puml" -Recurse).Count +
                     (Get-ChildItem "docs" -Filter "*.mermaid" -Recurse).Count
}

$validationReport | ConvertTo-Json | Out-File "analysis/documentation-validation.json"

# Generate validation report
$report = @"
# Documentation Validation Report

## Completeness Check
- Executive Documentation: $(if ($validationReport.ExecutiveDocsComplete) { '✅' } else { '❌' })
- Architecture Documentation: $(if ($validationReport.ArchitectureDocsComplete) { '✅' } else { '❌' })
- API Documentation: $(if ($validationReport.APIDocsComplete) { '✅' } else { '❌' })
- Functional Requirements: $(if ($validationReport.FunctionalReqsComplete) { '✅' } else { '❌' })
- Workflow Documentation: $(if ($validationReport.WorkflowDocsComplete) { '✅' } else { '❌' })
- Database Documentation: $(if ($validationReport.DatabaseDocsComplete) { '✅' } else { '❌' })
- Developer Guide: $(if ($validationReport.DeveloperGuideComplete) { '✅' } else { '❌' })

## Statistics
- Total Documents: $($validationReport.TotalDocuments)
- Total Diagrams: $($validationReport.TotalDiagrams)

## Status
$(if ($validationReport.ExecutiveDocsComplete -and
     $validationReport.ArchitectureDocsComplete -and
     $validationReport.APIDocsComplete) {
    '✅ Documentation package is COMPLETE'
} else {
    '⚠️ Documentation package is INCOMPLETE - review missing items above'
})
"@

$report | Out-File "docs/validation-report.md"
Write-Host "Validation complete. See docs/validation-report.md"
```

#### 6.2 Code-to-Documentation Traceability

**Script: Verify Traceability** (`scripts/verify-traceability.ps1`)
```powershell
# Verify all controllers are documented
$controllers = Get-Content "analysis/controllers/controller-inventory.json" | ConvertFrom-Json
$apiDocs = Get-Content "docs/api/api-reference-complete.md" -Raw

$undocumented = @()
foreach ($ctrl in $controllers) {
    if ($apiDocs -notmatch $ctrl.Name) {
        $undocumented += $ctrl.Name
    }
}

if ($undocumented.Count -gt 0) {
    Write-Host "WARNING: $($undocumented.Count) controllers not documented:"
    $undocumented | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host "✅ All controllers documented"
}
```

#### 6.3 Stakeholder Review Checklist

```markdown
# Stakeholder Review Checklist

## Executive Review
- [ ] Executive summary is clear and non-technical
- [ ] Business value is articulated
- [ ] Strategic roadmap is realistic
- [ ] ROI analysis is complete

## Architecture Review
- [ ] System architecture diagrams are accurate
- [ ] Technology stack is correctly identified
- [ ] Integration points are documented
- [ ] Security model is comprehensive

## Business Analyst Review
- [ ] All modules are functionally documented
- [ ] Workflows match actual system behavior
- [ ] Business rules are complete
- [ ] Permission matrix is accurate

## Developer Review
- [ ] Code structure guide is helpful
- [ ] API documentation is accurate
- [ ] Examples work as documented
- [ ] Technical debt is identified

## Designer Review
- [ ] UI components are cataloged
- [ ] Screen flows are accurate
- [ ] Design patterns are identified
```

### Deliverables (Phase 6)
- ✅ Documentation validation report
- ✅ Traceability matrix
- ✅ Stakeholder review checklist
- ✅ Gap analysis report
- ✅ Quality metrics

---

## Phase 7: Publication & Maintenance (Week 8+)

### Objectives
- Publish documentation
- Set up maintenance processes
- Enable searchability
- Establish update cadence

### Tasks

#### 7.1 Generate Static Documentation Site

**Using DocFX or MkDocs**:
```bash
# Option 1: MkDocs
pip install mkdocs mkdocs-material
mkdocs new carmen-docs
# Copy all MD files to docs/
mkdocs build
mkdocs serve

# Option 2: DocFX
docfx init
# Configure docfx.json
docfx build
docfx serve
```

**MkDocs Configuration** (`mkdocs.yml`):
```yaml
site_name: Carmen.NET Documentation
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - search.suggest

nav:
  - Home: index.md
  - Executive:
    - Summary: executive/executive-summary.md
    - Business Processes: executive/business-processes.md
  - Architecture:
    - System Architecture: architecture/system-architecture.md
    - Data Architecture: architecture/data-architecture.md
    - Security: architecture/security-architecture.md
  - Requirements:
    - Functional Requirements: requirements/functional-requirements.md
    - Permission Matrix: requirements/permission-matrix.md
  - API:
    - API Reference: api/api-reference-complete.md
    - Integration Guide: api/integration-guide.md
  - Workflows:
    - Approval Processes: workflows/approval-processes.md
  - Development:
    - Code Structure: development/code-structure.md
    - Design Patterns: development/design-patterns.md
  - Database:
    - Schema: database/inferred-schema.md

plugins:
  - search
  - mermaid2

markdown_extensions:
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:mermaid2.fence_mermaid
```

#### 7.2 Set Up CI/CD for Documentation

**GitHub Actions Workflow** (`.github/workflows/docs.yml`):
```yaml
name: Documentation

on:
  push:
    branches: [ main ]
    paths:
      - 'docs/**'
      - 'scripts/**'
      - '**.cs'

jobs:
  regenerate-docs:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '6.0.x'

      - name: Run code analysis
        run: |
          pwsh scripts/scan-controllers.ps1
          dotnet script scripts/scan-models.csx
          pwsh scripts/analyze-dependencies.ps1

      - name: Generate documentation
        run: |
          pwsh scripts/generate-executive-summary.ps1
          pwsh scripts/generate-api-docs.ps1

      - name: Build documentation site
        run: |
          pip install mkdocs-material
          mkdocs build

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
```

#### 7.3 Documentation Maintenance Plan

**Quarterly Update Schedule**:
```markdown
# Documentation Maintenance Plan

## Update Frequency

### Real-time Updates (Automated)
- API documentation (on code commit via CI/CD)
- Code metrics (on code commit)
- Dependency graphs (on dependency changes)

### Monthly Updates
- Business rules catalog (manual review)
- Workflow diagrams (on process changes)

### Quarterly Updates
- Architecture diagrams (review and update)
- Executive summary (update metrics)
- Functional requirements (validate completeness)

### Annual Updates
- Complete documentation review
- Stakeholder validation sessions
- Gap analysis and improvement plan

## Update Process
1. Automated scripts run on code commits
2. Documentation team reviews generated docs
3. Subject matter experts validate accuracy
4. Documentation published to site
5. Stakeholders notified of updates

## Ownership
- **Executive Docs**: Business Analyst + Product Owner
- **Architecture Docs**: Solution Architect
- **API Docs**: Automated + Dev Team validation
- **Functional Reqs**: Business Analyst
- **Developer Docs**: Senior Developers
- **UI/UX Docs**: Design Team
```

### Deliverables (Phase 7)
- ✅ Published documentation website
- ✅ CI/CD pipeline for auto-updates
- ✅ Maintenance plan
- ✅ Search functionality enabled
- ✅ Access controls configured

---

## Automation Scripts Summary

### Core Analysis Scripts (Required)

| Script | Purpose | Output | Execution Time |
|--------|---------|--------|----------------|
| `scan-controllers.ps1` | Scan all controllers | `controller-inventory.json` | ~30 sec |
| `scan-models.csx` | Scan all models | `model-inventory.json` | ~1 min |
| `analyze-dependencies.ps1` | Map dependencies | `dependency-graph.json` | ~30 sec |
| `extract-api-endpoints.ps1` | Extract API endpoints | `api-endpoints.json` | ~45 sec |
| `extract-business-rules.ps1` | Extract business rules | `extracted-rules.json` | ~1 min |
| `deep-analysis.csx` | Roslyn deep analysis | `deep-analysis.json` | ~5 min |
| `calculate-metrics.ps1` | Code metrics | `code-metrics.json` | ~1 min |

### Documentation Generation Scripts

| Script | Purpose | Output | Execution Time |
|--------|---------|--------|----------------|
| `generate-executive-summary.ps1` | Executive summary | `executive-summary.md` | ~10 sec |
| `generate-c4-diagrams.ps1` | C4 architecture diagrams | `*.puml` files | ~5 sec |
| `generate-erd.ps1` | ERD diagrams | `erd-*.puml` files | ~30 sec |
| `generate-workflow-diagrams.ps1` | Workflow diagrams | `*-workflow.md` | ~15 sec |
| `generate-postman-collection.ps1` | Postman collection | `postman-collection.json` | ~10 sec |
| `generate-functional-requirements.ps1` | Functional requirements | `functional-requirements.md` | ~30 sec |

### Validation Scripts

| Script | Purpose | Output | Execution Time |
|--------|---------|--------|----------------|
| `validate-documentation.ps1` | Check completeness | `validation-report.md` | ~5 sec |
| `verify-traceability.ps1` | Code-to-doc traceability | Console output | ~10 sec |

---

## Execution Timeline

### Week 1
- **Day 1-2**: Setup (Phase 0)
- **Day 3-5**: Automated scanning (Phase 1)

### Week 2
- Architecture & data modeling (Phase 2)

### Week 3
- Business logic & workflows (Phase 3)

### Week 4
- API & integration docs (Phase 4)

### Week 5-6
- Audience-specific docs (Phase 5)

### Week 7
- Validation & QA (Phase 6)

### Week 8+
- Publication & maintenance (Phase 7)

---

## Master Execution Command

**Run All Analysis Scripts**:
```powershell
# scripts/run-all-analysis.ps1
Write-Host "=== Carmen.NET Reverse Engineering - Full Analysis ==="

Write-Host "`n[1/10] Scanning controllers..."
./scripts/scan-controllers.ps1

Write-Host "`n[2/10] Scanning models..."
dotnet script scripts/scan-models.csx

Write-Host "`n[3/10] Analyzing dependencies..."
./scripts/analyze-dependencies.ps1

Write-Host "`n[4/10] Extracting API endpoints..."
./scripts/extract-api-endpoints.ps1

Write-Host "`n[5/10] Extracting business rules..."
./scripts/extract-business-rules.ps1

Write-Host "`n[6/10] Deep code analysis (Roslyn)..."
dotnet script scripts/deep-analysis.csx

Write-Host "`n[7/10] Calculating metrics..."
./scripts/calculate-metrics.ps1

Write-Host "`n[8/10] Extracting workflows..."
./scripts/extract-workflows.ps1

Write-Host "`n[9/10] Inferring database schema..."
./scripts/infer-database-schema.ps1

Write-Host "`n[10/10] Analyzing security model..."
./scripts/analyze-security.ps1

Write-Host "`n=== Analysis Complete ==="
Write-Host "Results saved in analysis/ directory"
Write-Host "`nNext steps:"
Write-Host "1. Review analysis/code-metrics.txt"
Write-Host "2. Run ./scripts/generate-all-documentation.ps1"
Write-Host "3. Validate with ./scripts/validate-documentation.ps1"
```

**Run All Documentation Generation**:
```powershell
# scripts/generate-all-documentation.ps1
Write-Host "=== Generating All Documentation ==="

Write-Host "`n[1/8] Generating executive summary..."
./scripts/generate-executive-summary.ps1

Write-Host "`n[2/8] Generating architecture diagrams..."
./scripts/generate-c4-diagrams.ps1
./scripts/generate-dependency-graph.ps1

Write-Host "`n[3/8] Generating ERD diagrams..."
./scripts/generate-erd.ps1

Write-Host "`n[4/8] Generating workflow diagrams..."
./scripts/generate-workflow-diagrams.ps1

Write-Host "`n[5/8] Generating API documentation..."
dotnet script scripts/enhance-swagger.csx
./scripts/generate-postman-collection.ps1

Write-Host "`n[6/8] Generating functional requirements..."
./scripts/generate-functional-requirements.ps1

Write-Host "`n[7/8] Generating developer guide..."
./scripts/generate-developer-guide.ps1

Write-Host "`n[8/8] Rendering diagrams..."
plantuml docs/architecture/*.puml
plantuml docs/database/*.puml

Write-Host "`n=== Documentation Generation Complete ==="
Write-Host "Documentation available in docs/ directory"
Write-Host "`nNext: ./scripts/validate-documentation.ps1"
```

---

## Success Metrics

### Quantitative Metrics
- ✅ 100% controller coverage
- ✅ 100% model documentation
- ✅ 100% API endpoint documentation
- ✅ 500+ business rules extracted
- ✅ 50+ diagrams generated
- ✅ 100+ documentation pages

### Qualitative Metrics
- ✅ Stakeholder approval
- ✅ Developer onboarding time < 2 days
- ✅ BA can write requirements from docs
- ✅ SA can design new features
- ✅ Executives can make strategic decisions

---

## Conclusion

This execution plan provides:
1. **Automated recursive scanning** of entire codebase
2. **Comprehensive documentation** for all audiences
3. **Reproducible process** via scripts
4. **Validation gates** for quality assurance
5. **Maintenance plan** for long-term sustainability

All scripts are designed to be **recursive** and **comprehensive**, ensuring no code is left undocumented.

**Total Estimated Effort**: 8 weeks (with automation)
**Manual Effort Saved**: ~60% through automation
**Documentation Artifacts**: 100+ files
