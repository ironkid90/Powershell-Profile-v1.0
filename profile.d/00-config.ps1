
# profile.d/00-config.ps1
# Central feature flags (safe defaults)
if (-not $global:PPP) { $global:PPP = @{} }

# Default: keep VS Code stable & minimal
$global:PPP.EnablePSFzf        = $false
$global:PPP.EnableCarapace     = $false
$global:PPP.EnableGitModule    = "git-completion"  # options: "git-completion" | "posh-git" | "none"
$global:PPP.EnableNpmModule    = $true             # npm-completion module
$global:PPP.EnableGuiTools     = $true
$global:PPP.EnableTerminalIcons = $true
$global:PPP.EnablePredictors   = $true

# Allow env overrides (nice for agents/CI)
if ($env:PPP_ENABLE_PSFZF)         { $global:PPP.EnablePSFzf        = $true }
if ($env:PPP_ENABLE_CARAPACE)      { $global:PPP.EnableCarapace     = $true }
if ($env:PPP_GIT_MODULE)           { $global:PPP.EnableGitModule    = $env:PPP_GIT_MODULE }
if ($env:PPP_ENABLE_NPM)           { $global:PPP.EnableNpmModule    = $true }
if ($env:PPP_ENABLE_GUI_TOOLS)     { $global:PPP.EnableGuiTools     = $true }
if ($env:PPP_ENABLE_TERMINAL_ICONS){ $global:PPP.EnableTerminalIcons = $true }
if ($env:PPP_ENABLE_PREDICTORS)    { $global:PPP.EnablePredictors   = $true }

# Optional: treat this session as "Stable" even if host detection can't tell
# Example usage: $env:PPP_FORCE_MODE="Stable"
if ($env:PPP_FORCE_MODE) { $global:PROFILE_MODE = $env:PPP_FORCE_MODE }
