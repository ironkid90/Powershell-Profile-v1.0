# PowerShell Profile Evaluation Framework
# Comprehensive assessment of workspace health, syntax, performance, and modularity

<#
.SYNOPSIS
    Complete evaluation framework for PowerShell profile workspace.

.DESCRIPTION
    Provides structured testing, validation, and health reporting for:
    - Syntax correctness
    - Module loading
    - Command availability
    - Performance metrics
    - Best practices compliance
    
.USAGE
    . .\Evaluation-Framework.ps1
    Invoke-WorkspaceEvaluation -Detailed
#>

# ===========================
# 1. SYNTAX VALIDATION
# ===========================

function Test-ProfileSyntax {
    <#
    .SYNOPSIS
        Validates PowerShell syntax without execution.
    #>
    param(
        [string]$ProfilePath = (Join-Path $PSScriptRoot "Profile.ps1")
    )
    
    $result = @{
        Path     = $ProfilePath
        Valid    = $false
        Errors   = @()
        Warnings = @()
    }
    
    if (-not (Test-Path $ProfilePath)) {
        $result.Errors += "Profile file not found: $ProfilePath"
        return $result
    }
    
    try {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $ProfilePath, [ref]$tokens, [ref]$parseErrors
        )
        
        if ($parseErrors.Count -gt 0) {
            $result.Errors = $parseErrors | ForEach-Object { $_.ToString() }
        } else {
            $result.Valid = $true
        }
    } catch {
        $result.Errors += "Parse exception: $($_.Exception.Message)"
    }
    
    return $result
}

function Test-ProfileDSyntax {
    <#
    .SYNOPSIS
        Validates all scripts in profile.d directory.
    #>
    param(
        [string]$ProfileDPath = (Join-Path $PSScriptRoot "profile.d")
    )
    
    $results = @()
    
    if (-not (Test-Path $ProfileDPath)) {
        return @{ Path = $ProfileDPath; Error = "profile.d directory not found" }
    }
    
    Get-ChildItem $ProfileDPath -Filter "*.ps1" | ForEach-Object {
        $tokens = $null
        $parseErrors = $null
        
        try {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $_.FullName, [ref]$tokens, [ref]$parseErrors
            )
            
            $result = @{
                FileName = $_.Name
                Valid    = $parseErrors.Count -eq 0
                Errors   = @()
            }
            
            if ($parseErrors.Count -gt 0) {
                $result.Errors = $parseErrors | ForEach-Object { $_.Message }
            }
            
            $results += $result
        } catch {
            $results += @{
                FileName = $_.Name
                Valid    = $false
                Errors   = @("Parse exception: $($_.Exception.Message)")
            }
        }
    }
    
    return $results
}

# ===========================
# 2. MODULE LOADING TESTS
# ===========================

function Test-ModuleLoadability {
    <#
    .SYNOPSIS
        Tests if all profile.d modules can be loaded.
    #>
    param(
        [string]$ProfileDPath = (Join-Path $PSScriptRoot "profile.d")
    )
    
    $results = @()
    
    if (-not (Test-Path $ProfileDPath)) {
        return @{ Status = "Failed"; Error = "profile.d directory not found" }
    }
    
    Get-ChildItem $ProfileDPath -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
        $startTime = [System.Diagnostics.Stopwatch]::StartNew()
        
        try {
            . $_.FullName
            $startTime.Stop()
            
            $results += [pscustomobject]@{
                Module      = $_.Name
                Loadable    = $true
                Error       = $null
                LoadTimeMs  = $startTime.ElapsedMilliseconds
            }
        } catch {
            $startTime.Stop()
            $results += [pscustomobject]@{
                Module      = $_.Name
                Loadable    = $false
                Error       = $_.Exception.Message
                LoadTimeMs  = $startTime.ElapsedMilliseconds
            }
        }
    }
    
    return $results
}

# ===========================
# 3. CONTEXT DETECTION TEST
# ===========================

function Test-ContextDetection {
    <#
    .SYNOPSIS
        Validates ProfileContext global variable.
    #>
    
    $result = @{
        ContextExists = $false
        Properties    = @()
        Valid         = $false
        Issues        = @()
    }
    
    if (-not (Get-Variable ProfileContext -Scope Global -ErrorAction SilentlyContinue)) {
        $result.Issues += "ProfileContext global variable not found"
        return $result
    }
    
    $result.ContextExists = $true
    $ctx = $global:ProfileContext
    
    $expectedProps = @("IsAdmin", "IsSystem", "IsInteractive", "IsVSCode", "IsWindowsTerminal", "IsSSH", "HostName", "PSVersion")
    
    foreach ($prop in $expectedProps) {
        $hasProp = $null -ne ($ctx | Select-Object -ExpandProperty $prop -ErrorAction SilentlyContinue)
        $result.Properties += [pscustomobject]@{
            Property = $prop
            Present  = $hasProp
        }
        
        if (-not $hasProp) {
            $result.Issues += "Missing property: $prop"
        }
    }
    
    $result.Valid = $result.Issues.Count -eq 0
    return $result
}

# ===========================
# 4. FUNCTION AVAILABILITY
# ===========================

function Test-FunctionAvailability {
    <#
    .SYNOPSIS
        Checks for required profile functions.
    #>
    
    $expectedFunctions = @(
        "Test-IsAdmin"
        "Test-IsSystem"
        "Test-IsInteractive"
        "Get-ProfileContext"
        "Test-CommandExists"
        "Start-DeferredLoad"
        "Show-ProfileStatus"
        "Invoke-ProfileHealthCheck"
        "Edit-Profile"
        "Update-Profile"
        "Initialize-TerminalToolchain"
    )
    
    $results = @()
    
    foreach ($funcName in $expectedFunctions) {
        $exists = [bool](Get-Command $funcName -ErrorAction SilentlyContinue)
        $results += [pscustomobject]@{
            Function = $funcName
            Available = $exists
        }
    }
    
    return $results
}

# ===========================
# 5. PERFORMANCE METRICS
# ===========================

function Measure-ProfileLoadTime {
    <#
    .SYNOPSIS
        Measures profile loading performance.
    #>
    
    $profilePath = Join-Path $PSScriptRoot "Profile.ps1"
    
    if (-not (Test-Path $profilePath)) {
        return @{ Error = "Profile not found" }
    }
    
    $times = @()
    
    # Run 3 iterations for consistency
    for ($i = 0; $i -lt 3; $i++) {
        $startTime = [System.Diagnostics.Stopwatch]::StartNew()
        & { . $profilePath } | Out-Null
        $startTime.Stop()
        $times += $startTime.ElapsedMilliseconds
    }
    
    return @{
        Iterations = 3
        Min        = ($times | Measure-Object -Minimum).Minimum
        Max        = ($times | Measure-Object -Maximum).Maximum
        Average    = [math]::Round(($times | Measure-Object -Average).Average, 2)
        Values     = $times
    }
}

# ===========================
# 6. BEST PRACTICES CHECK
# ===========================

function Test-BestPractices {
    <#
    .SYNOPSIS
        Validates best practices compliance.
    #>
    
    $checks = @{
        "Uses Set-StrictMode" = $false
        "Proper error handling" = $false
        "No Write-Host outside interactive" = $false
        "Profile root defined" = $false
        "Cache directory setup" = $false
        "Module directory exists" = $false
    }
    
    # Read profile content
    $profilePath = Join-Path $PSScriptRoot "Profile.ps1"
    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath -Raw
        
        $checks["Uses Set-StrictMode"] = $content -match "Set-StrictMode"
        $checks["Proper error handling"] = $content -match "try.*catch"
        $checks["No Write-Host outside interactive"] = $content -match "ProfileContext.IsInteractive"
        $checks["Profile root defined"] = $content -match "ProfileRoot"
        $checks["Cache directory setup"] = $content -match "CacheRoot|CompletionCache"
    }
    
    # Check for directories
    $checks["Module directory exists"] = Test-Path (Join-Path $PSScriptRoot "profile.d")
    
    return $checks
}

# ===========================
# 7. INTEGRATED EVALUATION
# ===========================

function Invoke-WorkspaceEvaluation {
    <#
    .SYNOPSIS
        Runs complete workspace evaluation.
    .PARAMETER Detailed
        Show detailed results including all tests.
    .PARAMETER ExportJson
        Export results to JSON file.
    #>
    param(
        [switch]$Detailed,
        [string]$ExportJson
    )
    
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   PowerShell Profile Evaluation Framework                  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $evaluation = @{
        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        WorkspaceRoot = $PSScriptRoot
        Results = @{}
    }
    
    # 1. Syntax Validation
    Write-Host "1️⃣  Testing Profile Syntax..." -ForegroundColor Yellow
    $syntaxMain = Test-ProfileSyntax
    $syntaxD = Test-ProfileDSyntax
    
    Write-Host "   Main Profile: $(if ($syntaxMain.Valid) { '✓ Valid' } else { '✗ Invalid' })" -ForegroundColor $(if ($syntaxMain.Valid) { 'Green' } else { 'Red' })
    if ($syntaxMain.Errors.Count -gt 0 -and $Detailed) {
        $syntaxMain.Errors | ForEach-Object { Write-Host "     ERROR: $_" -ForegroundColor Red }
    }
    
    $validD = ($syntaxD | Where-Object { $_.Valid }).Count
    Write-Host "   profile.d modules: $validD/$($syntaxD.Count) valid" -ForegroundColor $(if ($validD -eq $syntaxD.Count) { 'Green' } else { 'Yellow' })
    if ($Detailed) {
        $syntaxD | Where-Object { -not $_.Valid } | ForEach-Object {
            Write-Host "     ✗ $($_.FileName): $($_.Errors[0])" -ForegroundColor Red
        }
    }
    
    $evaluation.Results.SyntaxValidation = @{
        MainProfile = $syntaxMain
        ProfileD = $syntaxD
    }
    
    # 2. Module Loadability
    Write-Host ""
    Write-Host "2️⃣  Testing Module Loadability..." -ForegroundColor Yellow
    $loadability = Test-ModuleLoadability
    $loadableCount = ($loadability | Where-Object { $_.Loadable }).Count
    Write-Host "   $loadableCount/$($loadability.Count) modules load successfully" -ForegroundColor $(if ($loadableCount -eq $loadability.Count) { 'Green' } else { 'Yellow' })
    
    if ($Detailed) {
        $loadability | ForEach-Object {
            $icon = if ($_.Loadable) { '✓' } else { '✗' }
            $color = if ($_.Loadable) { 'Green' } else { 'Red' }
            Write-Host "     $icon $($_.Module) ($($_.LoadTimeMs)ms)" -ForegroundColor $color
            if ($_.Error -and $Detailed) { Write-Host "        Error: $($_.Error)" -ForegroundColor Red }
        }
    }
    
    $evaluation.Results.ModuleLoadability = $loadability
    
    # 3. Context Detection
    Write-Host ""
    Write-Host "3️⃣  Testing Context Detection..." -ForegroundColor Yellow
    $context = Test-ContextDetection
    Write-Host "   ProfileContext: $(if ($context.Valid) { '✓ Valid' } else { '✗ Invalid' })" -ForegroundColor $(if ($context.Valid) { 'Green' } else { 'Red' })
    if ($context.Issues.Count -gt 0 -and $Detailed) {
        $context.Issues | ForEach-Object { Write-Host "     Issue: $_" -ForegroundColor Yellow }
    }
    
    $evaluation.Results.ContextDetection = $context
    
    # 4. Function Availability
    Write-Host ""
    Write-Host "4️⃣  Testing Function Availability..." -ForegroundColor Yellow
    $functions = Test-FunctionAvailability
    $availableCount = ($functions | Where-Object { $_.Available }).Count
    Write-Host "   $availableCount/$($functions.Count) functions available" -ForegroundColor $(if ($availableCount -eq $functions.Count) { 'Green' } else { 'Yellow' })
    
    if ($Detailed) {
        $functions | Where-Object { -not $_.Available } | ForEach-Object {
            Write-Host "     ✗ Missing: $($_.Function)" -ForegroundColor Yellow
        }
    }
    
    $evaluation.Results.FunctionAvailability = $functions
    
    # 5. Best Practices
    Write-Host ""
    Write-Host "5️⃣  Checking Best Practices..." -ForegroundColor Yellow
    $practices = Test-BestPractices
    $practicesPass = ($practices.Values | Where-Object { $_ -eq $true }).Count
    Write-Host "   $practicesPass/$($practices.Count) best practice checks passed" -ForegroundColor $(if ($practicesPass -ge 5) { 'Green' } else { 'Yellow' })
    
    if ($Detailed) {
        $practices.GetEnumerator() | ForEach-Object {
            $icon = if ($_.Value) { '✓' } else { '✗' }
            $color = if ($_.Value) { 'Green' } else { 'Yellow' }
            Write-Host "     $icon $($_.Key)" -ForegroundColor $color
        }
    }
    
    $evaluation.Results.BestPractices = $practices
    
    # Summary
    Write-Host ""
    Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $overallValid = $syntaxMain.Valid -and ($validD -eq $syntaxD.Count) -and $context.Valid
    $statusColor = if ($overallValid) { 'Green' } else { 'Red' }
    
    Write-Host "EVALUATION STATUS: $(if ($overallValid) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $statusColor
    Write-Host ""
    Write-Host "Root: $($PSScriptRoot)" -ForegroundColor Gray
    Write-Host "Timestamp: $($evaluation.Timestamp)" -ForegroundColor Gray
    
    # Export if requested
    if ($ExportJson) {
        $evaluation | ConvertTo-Json -Depth 5 | Set-Content $ExportJson
        Write-Host "Results exported to: $ExportJson" -ForegroundColor Green
    }
    
    return $evaluation
}

# ===========================
# 8. QUICK DIAGNOSTICS
# ===========================

function Get-ProfileDiagnostics {
    <#
    .SYNOPSIS
        Quick diagnostic summary.
    #>
    
    Write-Host "Profile Diagnostics Report" -ForegroundColor Cyan
    Write-Host "═════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "ENVIRONMENT:" -ForegroundColor Yellow
    Write-Host "  PSVersion: $($PSVersionTable.PSVersion)" 
    Write-Host "  OS: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
    Write-Host "  Profile Root: $PSScriptRoot"
    Write-Host ""
    
    Write-Host "PROFILE.D MODULES:" -ForegroundColor Yellow
    $modules = Get-ChildItem (Join-Path $PSScriptRoot "profile.d") -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($modules) {
        $modules | ForEach-Object { Write-Host "  • $($_.Name)" }
    } else {
        Write-Host "  (No modules found)"
    }
    Write-Host ""
    
    Write-Host "QUICK CHECKS:" -ForegroundColor Yellow
    Write-Host "  Global ProfileContext: $(if (Get-Variable ProfileContext -Scope Global -EA SilentlyContinue) { '✓' } else { '✗' })"
    Write-Host "  PROFILE_MODE: $($global:PROFILE_MODE)"
    Write-Host "  Interactive Mode: $(if ($global:ProfileContext.IsInteractive) { '✓' } else { '✗' })"
}

# If running as a module, export functions; otherwise just make them available
if ($MyInvocation.PSCommandPath -like '*.psm1') {
    Export-ModuleMember -Function @(
        'Test-ProfileSyntax'
        'Test-ProfileDSyntax'
        'Test-ModuleLoadability'
        'Test-ContextDetection'
        'Test-FunctionAvailability'
        'Test-BestPractices'
        'Invoke-WorkspaceEvaluation'
        'Get-ProfileDiagnostics'
        'Measure-ProfileLoadTime'
    )
}
