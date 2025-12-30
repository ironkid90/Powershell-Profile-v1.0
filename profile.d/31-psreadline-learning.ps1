
# profile.d/31-psreadline-learning.ps1

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    # Great for learning: show multiple suggestions and sources. [5](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors?view=powershell-7.5)[3](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.5)
    Set-PSReadLineOption -PredictionSource History `
                         -PredictionViewStyle ListView

    # MenuComplete shows a list (instead of cycling). [11](https://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp)[3](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.5)
    Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

    # Keep Ctrl+Space as MenuComplete too (documented). [3](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.5)[14](https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/docs-conceptual/learn/shell/tab-completion.md)
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Spacebar' -Function MenuComplete
}
