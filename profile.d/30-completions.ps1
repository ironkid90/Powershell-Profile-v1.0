
# profile.d/30-completions.ps1

function Enable-CliCompletionCache {
    param(
        [Parameter(Mandatory)][string]$Exe,
        [Parameter(Mandatory)][string[]]$Args,
        [Parameter(Mandatory)][string]$CacheName,
        [int]$MaxAgeDays = 14
    )

    if (-not (Get-Command $Exe -ErrorAction SilentlyContinue)) { return }

    $cacheDir = Join-Path $global:CompletionCache "cli"
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }

    $cacheFile = Join-Path $cacheDir "$CacheName.ps1"

    $needsRefresh = $true
    if (Test-Path $cacheFile) {
        $ageDays = ((Get-Date) - (Get-Item $cacheFile).LastWriteTime).TotalDays
        if ($ageDays -lt $MaxAgeDays) { $needsRefresh = $false }
    }

    if ($needsRefresh) {
        try {
            $script = (& $Exe @Args) | Out-String
            if ($script -and $script.Length -gt 200) {
                Set-Content -Path $cacheFile -Value $script -Encoding UTF8
            }
        } catch { }
    }

    if (Test-Path $cacheFile) {
        try { . $cacheFile } catch { }
    }
}

function Enable-HelmCompletion {
    # Helm docs show loading completion script via Invoke-Expression; caching is faster. [5](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors?view=powershell-7.5)[3](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.5)
    Enable-CliCompletionCache -Exe "helm" -Args @("completion","powershell") -CacheName "helm" -MaxAgeDays 14
}

function Enable-AzCompletion {
    # Azure CLI now supports tab completion on PowerShell; enable via profile. [4](https://techcommunity.microsoft.com/blog/azuretoolsblog/azure-cli-supports-tab-completion-on-powershell/3829771)[2](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.5)
    # The exact az completion command can vary by version; caching keeps cost low.
    Enable-CliCompletionCache -Exe "az" -Args @("completion","-s","powershell") -CacheName "az" -MaxAgeDays 14
}

function Enable-NpmCompletion {
    # npm-completion module exists specifically for npm in PowerShell. [6](https://github.com/PowerShell-Completion/npm-completion)[2](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.5)
    if ($global:PPP.EnableNpmModule -and (Get-Module -ListAvailable npm-completion -ErrorAction SilentlyContinue)) {
        Import-Module npm-completion -ErrorAction SilentlyContinue
    }
}

function Enable-ProfileCompletions {
    Enable-HelmCompletion
    Enable-AzCompletion
    Enable-NpmCompletion
}

function Update-ProfileCompletions {
    Enable-CliCompletionCache -Exe "helm" -Args @("completion","powershell") -CacheName "helm" -MaxAgeDays 0
    Enable-CliCompletionCache -Exe "az" -Args @("completion","-s","powershell") -CacheName "az" -MaxAgeDays 0
    Enable-NpmCompletion
}

# Activate completions (safe in Stable/Full)
Enable-ProfileCompletions
