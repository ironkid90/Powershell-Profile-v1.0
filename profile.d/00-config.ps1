
# profile.d/00-config.ps1
# Central feature flags (safe defaults)
if (-not $global:PPP) { $global:PPP = @{} }

# Default: keep VS Code stable & minimal
$global:PPP.EnablePSFzf     = $false
$global:PPP.EnableCarapace  = $false
$global:PPP.EnableGitModule = "git-completion"  # options: "git-completion" | "posh-git" | "none"
$global:PPP.EnableNpmModule = $true             # npm-completion module

# Allow env overrides (nice for agents/CI)
if ($env:PPP_ENABLE_PSFZF)     { $global:PPP.EnablePSFzf    = $true }
if ($env:PPP_ENABLE_CARAPACE)  { $global:PPP.EnableCarapace = $true }
if ($env:PPP_GIT_MODULE)       { $global:PPP.EnableGitModule = $env:PPP_GIT_MODULE }
