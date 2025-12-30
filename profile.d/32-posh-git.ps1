
# profile.d/32-posh-git.ps1

if (Get-Module -ListAvailable posh-git -ErrorAction SilentlyContinue) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}
