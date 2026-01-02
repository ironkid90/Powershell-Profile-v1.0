# PowerShell Profile v1.0
# Goals: Fast startup, predictable behavior, agent-friendly, completion preservation

# ----------------------------
# Context detection
# ----------------------------
function Test-IsAdmin {
    if ($IsWindows) {
        try {
            return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        } catch { return $false }
    } else {
        # Linux/macOS
        try { return (id -u) -eq 0 } catch { return $false }
    }
}

function Test-IsSystem {
    if ($IsWindows) {
        try { return [System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem }
        catch { return $false }
    } else {
        # Linux: System users usually have UID < 1000
        try { $uid = id -u; return $uid -gt 0 -and $uid -lt 1000 } catch { return $false }
    }
}

function Test-IsInteractive { return -not [Console]::IsInputRedirected }

function Get-ProfileContext {
    [pscustomobject]@{
        IsAdmin           = Test-IsAdmin
        IsSystem          = Test-IsSystem
        IsInteractive     = Test-IsInteractive
        IsVSCode          = [bool]$env:VSCODE_PID
        IsWindowsTerminal = [bool]$env:WT_SESSION
        IsSSH             = [bool]$env:SSH_CLIENT -or [bool]$env:SSH_CONNECTION
        HostName          = $Host.Name
        PSVersion         = $PSVersionTable.PSVersion.ToString()
    }
}

$global:ProfileContext = Get-ProfileContext

# ----------------------------
# Mode selection
# ----------------------------
if ($env:PROFILE_MODE) {
    $global:PROFILE_MODE = $env:PROFILE_MODE
} else {
    if (-not $global:ProfileContext.IsInteractive) { $global:PROFILE_MODE = "Stable" }
    elseif ($global:ProfileContext.IsSystem)        { $global:PROFILE_MODE = "Stable" }
    else                                            { $global:PROFILE_MODE = "Full" }
}

# ----------------------------
# Paths + caches
# ----------------------------
$global:ProfileRoot = $PSScriptRoot
if (-not $global:ProfileRoot) {
    if ($IsWindows) { $global:ProfileRoot = Join-Path $HOME "Documents\PowerShell" }
    else { $global:ProfileRoot = Join-Path $HOME ".config\powershell" }
}

if ($IsWindows) {
    $global:CacheRoot = Join-Path $env:LOCALAPPDATA "PSProfileCache"
} else {
    $global:CacheRoot = Join-Path $HOME ".cache\PSProfileCache"
}
$global:CompletionCache = Join-Path $global:CacheRoot "completions"

foreach ($p in @($global:ProfileRoot, $global:CacheRoot, $global:CompletionCache)) {
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

# Machine-wide tool locations
if ($IsWindows) {
    $MachineToolsBin = "C:\ProgramData\Tools\bin"
    if (Test-Path $MachineToolsBin) {
        $env:PATH = "$MachineToolsBin;$env:PATH"
    }
}

function Test-CommandExists { param([string]$Name) return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue) }

# ----------------------------
# Early: encoding + title + basic prompt
# ----------------------------
try {
    [Console]::InputEncoding  = [Text.UTF8Encoding]::new($false)
    [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
} catch {}

try {
    $adminTag = if ($global:ProfileContext.IsAdmin) { " [ADMIN]" } else { "" }
    $sysTag   = if ($global:ProfileContext.IsSystem) { " [SYSTEM]" } else { "" }
    if ($IsWindows -or $env:WT_SESSION) {
        $Host.UI.RawUI.WindowTitle = "pwsh $($global:ProfileContext.PSVersion)$adminTag$sysTag"
    }
} catch {}

function global:prompt {
    $loc = Get-Location
    if ($global:ProfileContext.IsAdmin) { "[$loc] # " } else { "[$loc] $ " }
}

# ----------------------------
# PSReadLine early (completion experience)
# ----------------------------
if ($global:ProfileContext.IsInteractive -and (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    try {
        Set-PSReadLineOption -EditMode Windows `
            -HistoryNoDuplicates `
            -HistorySearchCursorMovesToEnd `
            -PredictionSource History `
            -PredictionViewStyle ListView `
            -BellStyle None

        Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
        
        # Fix Windows Terminal paste behavior
        Set-PSReadLineKeyHandler -Key Ctrl+V -Function Paste
    } catch {
        Write-Warning "PSReadLine configuration failed: $($_.Exception.Message)"
    }
}

# ----------------------------
# Simplified Deferred Loading
# ----------------------------
function Start-DeferredLoad {
    param([ScriptBlock]$LoadBlock)
    
    # We run synchronously to ensure correctness. 
    # True background loading of global state is not supported in PowerShell.
    try {
        . $LoadBlock
    } catch {
        Write-Warning "Deferred load failed: $($_.Exception.Message)"
    }
}

# ----------------------------
# Deferred content to load
# ----------------------------
$DeferredContent = {
    $global:DeferredLoaded = $true
    
    # Load optional tools
    if ($IsWindows -and (Test-CommandExists "gsudo")) { Set-Alias sudo gsudo }
    if (Test-CommandExists "oh-my-posh") { 
        try { oh-my-posh init pwsh | Invoke-Expression } catch {}
    }
    if (Test-CommandExists "zoxide") {
        try { Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) }) } catch {}
    }
    
    # Load profile.d modules if they exist
    $profileDir = Join-Path $global:ProfileRoot "profile.d"
    if (Test-Path $profileDir) {
        Get-ChildItem $profileDir -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
            try { . $_.FullName } catch {
                Write-Warning ("Failed to load profile module {0}: {1}" -f $_.Name, $_.Exception.Message)
            }
        }
    }
}

function Import-ProfileModuleByName {
    param([Parameter(Mandatory)][string]$ModuleName)

    $profileDir = Join-Path $global:ProfileRoot "profile.d"
    $path = Join-Path $profileDir $ModuleName
    if (Test-Path $path) {
        try { . $path } catch {
            Write-Warning ("Failed to load profile module {0}: {1}" -f $ModuleName, $_.Exception.Message)
    param([Parameter(Mandatory)][string]$Name)

    $profileDir = Join-Path $global:ProfileRoot "profile.d"
    $path = Join-Path $profileDir $Name
    if (Test-Path $path) {
        try { . $path } catch {
 codex/suggest-improvements-for-powershell-profile-gc8v07
            Write-Warning "Failed to load profile module ${Name}: $($_.Exception.Message)"

            Write-Warning "Failed to load profile module $Name: $($_.Exception.Message)"
 main
        }
    }
}

# ----------------------------
# Health + status functions
# ----------------------------
function Show-ProfileStatus {
    $c = $global:ProfileContext
    Write-Host "=== Profile v1.0 Status ===" -ForegroundColor Cyan
    Write-Host ("Mode: " + $global:PROFILE_MODE) -ForegroundColor Yellow
    Write-Host ("Host: " + $c.HostName + " | VSCode=" + $c.IsVSCode + " | WT=" + $c.IsWindowsTerminal + " | Interactive=" + $c.IsInteractive) -ForegroundColor Gray
    Write-Host ("Admin=" + $c.IsAdmin + " | SYSTEM=" + $c.IsSystem + " | SSH=" + $c.IsSSH) -ForegroundColor Gray
}

function Invoke-ProfileHealthCheck {
    $checks = @(
        @{ Name="oh-my-posh"; Kind="cmd" },
        @{ Name="zoxide"; Kind="cmd" },
        @{ Name="gsudo"; Kind="cmd" },
        @{ Name="helm"; Kind="cmd" }
    )

    $results = $checks | ForEach-Object {
        $present = if ($_.Kind -eq "cmd") { [bool](Get-Command $_.Name -ErrorAction SilentlyContinue) } else { $false }
        [pscustomobject]@{ Item=$_.Name; Present=$present }
    }
    
    $results | Format-Table -AutoSize
    return $results
}

function Edit-Profile {
    if (Test-Path $PSCommandPath) {
        code $PSCommandPath
    } else {
        Write-Warning "Profile file not found: $PSCommandPath"
    }
}

function Update-Profile {
    param([switch]$Force)
    
    if (-not $Force -and -not $global:ProfileContext.IsInteractive) {
        Write-Warning "Profile updates should be run interactively"
        return
    }
    
    Write-Host "Updating profile components..." -ForegroundColor Yellow
    
    # Example: Update completion caches
    if (Get-Command Update-ProfileCompletions -ErrorAction SilentlyContinue) {
        Update-ProfileCompletions
    }
    
    Write-Host "Profile update complete" -ForegroundColor Green
}

# ----------------------------
# Bootstrap command
# ----------------------------
function Initialize-TerminalToolchain {
    param([switch]$MachineWide)
    
    Write-Host "=== Terminal Toolchain Bootstrap ===" -ForegroundColor Cyan
    
    if ($MachineWide -and $IsWindows) {
        Write-Host "Installing machine-wide tools (Windows)..." -ForegroundColor Yellow
        
        # Create machine-wide tools directory
        if (-not (Test-Path "C:\ProgramData\Tools\bin")) {
            New-Item -ItemType Directory -Path "C:\ProgramData\Tools\bin" -Force | Out-Null
        }
        
        Write-Host "Machine-wide tools directory ready: C:\ProgramData\Tools\bin" -ForegroundColor Green
    }
    
    Write-Host "Bootstrap complete. Recommended tools:" -ForegroundColor Green
    if ($IsWindows) { Write-Host "- gsudo: Admin elevation" -ForegroundColor Gray }
    else { Write-Host "- sudo: Admin elevation (standard)" -ForegroundColor Gray }
    Write-Host "- oh-my-posh: Prompt theming" -ForegroundColor Gray
    Write-Host "- zoxide: Directory jumping" -ForegroundColor Gray
    Write-Host "- Helm: Kubernetes package manager" -ForegroundColor Gray
}

# ----------------------------
# Activate based on mode
# ----------------------------
if ($global:PROFILE_MODE -eq "Full") {
    # Start deferred loading for interactive sessions
    Start-DeferredLoad -LoadBlock $DeferredContent
} else {
    # Stable mode: load essentials only
    Import-ProfileModuleByName -ModuleName "00-config.ps1"
    Import-ProfileModuleByName -ModuleName "30-completions.ps1"
    Import-ProfileModuleByName -Name "00-config.ps1"
    Import-ProfileModuleByName -Name "30-completions.ps1"
}

# ----------------------------
# Final initialization message
# ----------------------------
if ($global:ProfileContext.IsInteractive) {
    Write-Host "PowerShell profile loaded ($($global:PROFILE_MODE) mode)" -ForegroundColor Green
    Write-Host "Use 'Show-ProfileStatus' for details, 'Invoke-ProfileHealthCheck' for tool status" -ForegroundColor Gray
    Write-Host "Use 'Show-ProfileHelp' for beginner-friendly tips and shortcuts" -ForegroundColor Gray
}
