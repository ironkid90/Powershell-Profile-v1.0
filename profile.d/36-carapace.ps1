
# profile.d/36-carapace.ps1

if ($global:PPP.EnableCarapace -and (Get-Command carapace -ErrorAction SilentlyContinue)) {
    if ($env:PPP_CARAPACE_SCRIPT -and (Test-Path $env:PPP_CARAPACE_SCRIPT)) {
        try { . $env:PPP_CARAPACE_SCRIPT } catch {
            Write-Warning "Failed to load Carapace script: $($_.Exception.Message)"
        }
    } elseif ($env:PPP_CARAPACE_INIT) {
        try { Invoke-Expression $env:PPP_CARAPACE_INIT } catch {
            Write-Warning "Failed to initialize Carapace: $($_.Exception.Message)"
        }
    } else {
        Write-Verbose "Carapace detected. Set PPP_CARAPACE_SCRIPT or PPP_CARAPACE_INIT to enable completions."
    }
}
