
# profile.d/50-help.ps1

function Show-ProfileHelp {
    Write-Host "=== PowerShell Profile Help ===" -ForegroundColor Cyan
    Write-Host "Core commands:" -ForegroundColor Yellow
    Write-Host "  Show-ProfileStatus       - Environment and mode summary" -ForegroundColor Gray
    Write-Host "  Invoke-ProfileHealthCheck - Check recommended tools" -ForegroundColor Gray
    Write-Host "  Update-Profile           - Refresh cached components" -ForegroundColor Gray
    Write-Host "  Show-PSReadLineTips      - Keybinding tips" -ForegroundColor Gray
    Write-Host "GUI tools (if enabled):" -ForegroundColor Yellow
    Write-Host "  Get-Process | ocgv       - Interactive grid view" -ForegroundColor Gray
    Write-Host "  Get-Variable | sot       - Object tree viewer" -ForegroundColor Gray
    Write-Host "Navigation:" -ForegroundColor Yellow
    Write-Host "  z <dir>                  - Jump to directory (zoxide)" -ForegroundColor Gray
    Write-Host "  Ctrl+T / Ctrl+R          - Fuzzy file/history (PSFzf)" -ForegroundColor Gray
}

function Show-ToolInstallHelp {
    Write-Host "=== Optional Tools ===" -ForegroundColor Cyan
    Write-Host "Terminal-Icons           : Install-Module Terminal-Icons -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "Az.Tools.Predictor       : Install-Module Az.Tools.Predictor -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "ConsoleGuiTools          : Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "PSFzf (requires fzf)      : Install-Module PSFzf -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "posh-git                  : Install-Module posh-git -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "git-completion            : Install-Module git-completion -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "npm-completion            : Install-Module npm-completion -Scope CurrentUser" -ForegroundColor Gray
}
