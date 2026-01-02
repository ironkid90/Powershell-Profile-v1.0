
# profile.d/37-predictors.ps1

if ($global:PPP.EnablePredictors -and (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    if (Get-Module -ListAvailable Az.Tools.Predictor -ErrorAction SilentlyContinue) {
        Import-Module Az.Tools.Predictor -ErrorAction SilentlyContinue
        try {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
        } catch {
            Write-Warning "Failed to update PSReadLine prediction mode: $($_.Exception.Message)"
        }
    }
}
