
# profile.d/31-psreadline-learning.ps1

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    # Discovery-friendly: show a list of suggestions
    Set-PSReadLineOption -PredictionSource History `
                         -PredictionViewStyle ListView

    # Make Tab show a menu of choices (instead of cycling)
    Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

    # Keep Ctrl+Space as MenuComplete (documented default behavior)
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Spacebar' -Function MenuComplete
}

function Show-PSReadLineTips {
    Write-Host "=== PSReadLine Tips ===" -ForegroundColor Cyan
    Write-Host "Tab            : Menu completion" -ForegroundColor Gray
    Write-Host "Ctrl+Space     : Menu completion" -ForegroundColor Gray
    Write-Host "Up/Down arrows : History search" -ForegroundColor Gray
    Write-Host "Ctrl+R         : History search (with PSFzf if enabled)" -ForegroundColor Gray
    Write-Host "Ctrl+T         : Fuzzy file picker (with PSFzf if enabled)" -ForegroundColor Gray
}
