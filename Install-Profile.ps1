
# Install-Profile.ps1
# Safe installer: dot-sources repo Profile.ps1 from the user's $PROFILE

$repoProfile = Join-Path $PSScriptRoot "Profile.ps1"
if (-not (Test-Path $repoProfile)) {
    Write-Error "Profile.ps1 not found at $repoProfile"
    return
}

$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = $PROFILE }

$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$line = ". `"$repoProfile`""
$contents = Get-Content -Path $profilePath -ErrorAction SilentlyContinue
if ($contents -notcontains $line) {
    Add-Content -Path $profilePath -Value $line
    Write-Host "Added dot-source line to $profilePath" -ForegroundColor Green
} else {
    Write-Host "Dot-source line already present in $profilePath" -ForegroundColor Yellow
}

$legacyProfile = Join-Path $profileDir "profile.ps1"
if (Test-Path $legacyProfile) {
    $legacyContent = Get-Content -Path $legacyProfile -ErrorAction SilentlyContinue
    if ($legacyContent -match '\\$Name:') {
        Write-Warning "Found legacy profile.ps1 referencing '$$Name:'. This can cause ParserError. Consider removing or updating that file: $legacyProfile"
    } else {
        Write-Warning "A legacy profile.ps1 exists: $legacyProfile. Ensure your $PROFILE is dot-sourcing the repo Profile.ps1 instead."
    }
}
