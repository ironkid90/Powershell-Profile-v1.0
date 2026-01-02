
# profile.d/35-terminal-icons.ps1

if ($global:PPP.EnableTerminalIcons -and (Get-Module -ListAvailable Terminal-Icons -ErrorAction SilentlyContinue)) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}
