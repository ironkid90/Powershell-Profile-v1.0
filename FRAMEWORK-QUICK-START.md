# PowerShell Profile Evaluation Framework - Quick Start

## Overview
The **Evaluation Framework** (`Evaluation-Framework.ps1`) provides automated testing and validation of your PowerShell profile workspace across five dimensions:
- ✓ Syntax validation
- ✓ Module loadability
- ✓ Context detection
- ✓ Function availability
- ✓ Best practices compliance

---

## 🚀 Quick Start (30 seconds)

```powershell
# 1. Load the framework
. .\Evaluation-Framework.ps1

# 2. Run evaluation
Invoke-WorkspaceEvaluation
```

**Output:** Summary table with pass/fail status and recommendations.

---

## 📊 Common Tasks

### Run Full Evaluation with Details
```powershell
. .\Evaluation-Framework.ps1
Invoke-WorkspaceEvaluation -Detailed
```
Shows each test, module load times, and identified issues.

### Export Results to JSON
```powershell
Invoke-WorkspaceEvaluation -ExportJson "evaluation-$(Get-Date -Format yyyyMMdd).json"
```
Saves detailed results for CI/CD pipelines, historical tracking, or reporting.

### Quick Diagnostic Summary
```powershell
Get-ProfileDiagnostics
```
Shows environment, profile.d modules, and quick health checks.

### Test Individual Components

#### Syntax Only
```powershell
$mainSyntax = Test-ProfileSyntax
$profileDSyntax = Test-ProfileDSyntax
```

#### Module Loading Performance
```powershell
Test-ModuleLoadability | Format-Table -AutoSize
```

#### Best Practices Check
```powershell
Test-BestPractices | Format-Table -AutoSize
```

#### Profile Load Time Benchmark
```powershell
$metrics = Measure-ProfileLoadTime
Write-Host "Average load time: $($metrics.Average)ms"
```

---

## 📋 Test Functions Reference

| Function | Purpose | Output |
|----------|---------|--------|
| `Test-ProfileSyntax` | Validate main Profile.ps1 | Hash with Valid/Errors |
| `Test-ProfileDSyntax` | Validate profile.d modules | Array of validation results |
| `Test-ModuleLoadability` | Load all modules, measure time | Objects with timing metrics |
| `Test-ContextDetection` | Check ProfileContext global | Hash with validity and properties |
| `Test-FunctionAvailability` | Check required functions exist | Array of availability status |
| `Test-BestPractices` | Validate design patterns | Hash with check results |
| `Measure-ProfileLoadTime` | Benchmark 3 iterations | Min/Max/Average metrics |
| `Invoke-WorkspaceEvaluation` | Complete evaluation | Comprehensive report |
| `Get-ProfileDiagnostics` | Quick health check | Console-friendly summary |

---

## ✅ Interpretation Guide

### Overall Status Indicators

| Symbol | Meaning | Action |
|--------|---------|--------|
| ✓ PASS | All critical tests passed | Profile is ready to use |
| ⚠ WARN | Non-critical issues found | Review recommendations |
| ✗ FAIL | Critical syntax errors | Must fix before use |

### Common Statuses

**✓ Syntax Validation: Main Profile Valid**
- Profile.ps1 parses correctly
- No parser errors or missing braces
- Safe to load

**✓ profile.d modules: 14/14 valid**
- All modules in profile.d/ pass syntax checks
- Can be loaded without errors

**⚠ Context Detection: Invalid**
- ProfileContext global variable not found
- *Normal if framework runs before profile loads*
- Not a problem in actual shell

**5/6 best practice checks passed**
- Missing `Set-StrictMode` (optional enhancement)
- All critical best practices followed

---

## 🔧 Usage Patterns

### As a Development Tool
```powershell
# Before editing
$baseline = Invoke-WorkspaceEvaluation | ConvertTo-Json | ConvertFrom-Json

# After editing
$after = Invoke-WorkspaceEvaluation | ConvertTo-Json | ConvertFrom-Json

# Compare (manual or script)
if ($baseline.Results.SyntaxValidation.MainProfile.Valid -ne $after.Results.SyntaxValidation.MainProfile.Valid) {
    "SYNTAX STATUS CHANGED!"
}
```

### As a CI/CD Check
```powershell
. .\Evaluation-Framework.ps1
$results = Invoke-WorkspaceEvaluation -ExportJson "eval-report.json"
$isSyntaxValid = $results.Results.SyntaxValidation.MainProfile.Valid
exit $(if ($isSyntaxValid) { 0 } else { 1 })
```

### As a Scheduled Health Check
```powershell
# Schedule via Task Scheduler or cron
. .\Evaluation-Framework.ps1
Invoke-WorkspaceEvaluation -ExportJson "health-$(Get-Date -Format yyyyMMdd-HHmmss).json"
```

---

## 🐛 Troubleshooting

### "Functions not available" warning
**Cause:** ProfileContext and functions only load when profile is sourced  
**Solution:** Run `Get-ProfileDiagnostics` in your interactive shell instead

### "ProfileContext global variable not found"
**Cause:** Running framework before profile initialization  
**Solution:** This is expected when testing the framework itself, not a problem

### Modules fail to load
**Cause:** Syntax errors or missing dependencies  
**Solution:** Run with `-Detailed` flag to see specific errors

### Very slow module load times
**Cause:** Git-completion or terminal-icons modules  
**Solution:** Consider deferring these modules or implementing lazy-loading

---

## 📈 Performance Baseline

Typical load times for profile.d modules:

```
Fast modules (< 50ms):
  ✓ config, git, aliases, git-posh, carapace, psfzf, help

Medium modules (50-200ms):
  ✓ npm, predictors, gui

Heavy modules (> 700ms):
  ✓ completions, git-completion, terminal-icons

Total typical load time: 4-5 seconds
```

---

## 🎯 What Happens Next?

### If Status is ✓ PASS
1. Your profile is syntactically correct and ready to use
2. All modules load without errors
3. Context detection works properly

### If Status is ⚠ WARN
1. Review the specific warnings (usually best practices)
2. Consider implementing recommendations
3. Not blocking, but improves quality

### If Status is ✗ FAIL
1. **Fix syntax errors first** (shown in detailed output)
2. Run `Test-ProfileSyntax` for exact error locations
3. Re-run evaluation after fixes

---

## 📚 Related Documentation

- `EVALUATION-REPORT.md` - Full evaluation report with recommendations
- `README.md` - Profile installation and usage guide
- `openmemory.md` - Architecture and design decisions
- `Evaluation-Framework.ps1` - Framework source code with detailed comments

---

## 💡 Pro Tips

1. **Run before major edits:** Establish a baseline
   ```powershell
   Invoke-WorkspaceEvaluation -ExportJson "baseline.json"
   ```

2. **Compare changes:** Use JSON exports to track deltas
   ```powershell
   # Before and after
   $before | ConvertTo-Json > before.json
   $after | ConvertTo-Json > after.json
   # Then compare with your favorite diff tool
   ```

3. **Integrate with terminal startup:** Add check to profile
   ```powershell
   # At end of Profile.ps1 (optional)
   if ($global:ProfileContext.IsInteractive) {
       $evalPath = Join-Path $PSScriptRoot "Evaluation-Framework.ps1"
       if (Test-Path $evalPath) {
           # Can add periodic health checks here
       }
   }
   ```

4. **Fast module testing:** Test just one module
   ```powershell
   . (Join-Path $global:ProfileRoot "profile.d\30-completions.ps1")
   ```

---

## 🔗 Command Cheat Sheet

```powershell
# Load framework
. .\Evaluation-Framework.ps1

# Quick checks
Invoke-WorkspaceEvaluation
Get-ProfileDiagnostics

# Detailed analysis
Invoke-WorkspaceEvaluation -Detailed
Test-ProfileSyntax
Test-ModuleLoadability

# Benchmarking
Measure-ProfileLoadTime

# Reporting
Invoke-WorkspaceEvaluation -ExportJson "report.json"
```

---

**Need help?** See the `Evaluation-Framework.ps1` source for detailed function documentation.
