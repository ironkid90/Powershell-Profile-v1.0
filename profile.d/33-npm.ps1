
# profile.d/33-npm.ps1

if (Get-Module -ListAvailable npm-completion -ErrorAction SilentlyContinue) {
    Import-Module npm-completion -ErrorAction SilentlyContinue
}
