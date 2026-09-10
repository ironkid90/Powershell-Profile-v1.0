# Persistent, low-noise command history for interactive human sessions.
if ($global:PPP.EnableHistory -and
    $global:ProfileContext.IsInteractive -and
    (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    try {
        $historyRoot = Join-Path $global:CacheRoot "history"
        if (-not (Test-Path $historyRoot)) {
            New-Item -ItemType Directory -Path $historyRoot -Force | Out-Null
        }

        $historyPath = Join-Path $historyRoot "PSReadLine.history.txt"
        Set-PSReadLineOption -HistorySavePath $historyPath -HistorySaveStyle SaveIncrementally
    } catch {
        Write-Verbose "History persistence could not be configured: $($_.Exception.Message)"
    }
}

function Search-ProfileHistory {
    param([Parameter(Mandatory, Position = 0)][string]$Pattern)

    $historyPath = Join-Path $global:CacheRoot "history\PSReadLine.history.txt"
    if (Test-Path $historyPath) {
        Select-String -Path $historyPath -Pattern $Pattern
    }
}
