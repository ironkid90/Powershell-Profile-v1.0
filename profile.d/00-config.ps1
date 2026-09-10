
# profile.d/00-config.ps1
# Central feature flags (safe defaults)
if (-not $global:PPP) { $global:PPP = @{} }

# Defaults are assigned only once so a user's profile/custom module can override them.
$defaults = @{
    EnablePSFzf         = $false
    EnableCarapace      = $false
    EnableGitModule     = "git-completion" # git-completion | posh-git | none
    EnableNpmModule     = $true
    EnableGuiTools      = $true
    EnableTerminalIcons = $true
    EnablePredictors    = $true
    EnableHistory       = $true
    ShowStartup         = $false
}
foreach ($entry in $defaults.GetEnumerator()) {
    if (-not $global:PPP.ContainsKey($entry.Key)) { $global:PPP[$entry.Key] = $entry.Value }
}

# Allow env overrides (nice for agents/CI)
if ($env:PPP_ENABLE_PSFZF)         { $global:PPP.EnablePSFzf        = $true }
if ($env:PPP_ENABLE_CARAPACE)      { $global:PPP.EnableCarapace     = $true }
if ($env:PPP_GIT_MODULE)           { $global:PPP.EnableGitModule    = $env:PPP_GIT_MODULE }
if ($env:PPP_ENABLE_NPM)           { $global:PPP.EnableNpmModule    = $true }
if ($env:PPP_ENABLE_GUI_TOOLS)     { $global:PPP.EnableGuiTools     = $true }
if ($env:PPP_ENABLE_TERMINAL_ICONS){ $global:PPP.EnableTerminalIcons = $true }
if ($env:PPP_ENABLE_PREDICTORS)    { $global:PPP.EnablePredictors   = $true }
if ($env:PPP_ENABLE_HISTORY -eq "0") { $global:PPP.EnableHistory = $false }
if ($env:PPP_SHOW_STARTUP -eq "1")  { $global:PPP.ShowStartup = $true }

# Optional: treat this session as "Stable" even if host detection can't tell
# Example usage: $env:PPP_FORCE_MODE="Stable"
if ($env:PPP_FORCE_MODE) { $global:PROFILE_MODE = $env:PPP_FORCE_MODE }
