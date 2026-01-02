
# profile.d/33-npm.ps1

if ($global:PPP.EnableNpmModule -and -not (Get-Module npm-completion -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable npm-completion -ErrorAction SilentlyContinue)) {
    Import-Module npm-completion -ErrorAction SilentlyContinue
}
