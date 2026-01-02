# Useful aliases and shortcuts

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# System
Set-Alias -Name which -Value Get-Command
Set-Alias -Name grep -Value Select-String

# File operations
function Edit-File { param([string]$Path) code $Path }
Set-Alias -Name e -Value Edit-File

function Show-Path { $env:PATH -split [IO.Path]::PathSeparator | Where-Object { $_ } }
Set-Alias -Name path -Value Show-Path

# Process management
function Kill-Process { param([string]$Name) Get-Process $Name | Stop-Process -Force }
Set-Alias -Name killp -Value Kill-Process

# Network
function Get-PublicIP { (Invoke-RestMethod -Uri "https://api.ipify.org").Trim() }
Set-Alias -Name myip -Value Get-PublicIP

# Utilities
function Measure-Directory {
    param(
        [string]$Path = ".",
        [int]$Depth
    )

    $useDepth = $PSVersionTable.PSVersion.Major -ge 7 -and $PSBoundParameters.ContainsKey("Depth")
    if ($useDepth) {
        Get-ChildItem $Path -Depth $Depth | Measure-Object -Property Length -Sum
    } else {
        if ($PSBoundParameters.ContainsKey("Depth")) {
            Write-Warning "Depth is only supported in PowerShell 7+. Falling back to recursive scan."
        }
        Get-ChildItem $Path -Recurse | Measure-Object -Property Length -Sum
    }
}
Set-Alias -Name dirsize -Value Measure-Directory
