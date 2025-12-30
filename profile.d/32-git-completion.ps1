
# profile.d/32-git-completion.ps1

switch ($global:PPP.EnableGitModule) {
    "git-completion" {
        # git-completion-pwsh: completion-focused module. [10](https://github.com/kzrnm/git-completion-pwsh)[3](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.5)
        if (Get-Module -ListAvailable git-completion -ErrorAction SilentlyContinue) {
            Import-Module git-completion -ErrorAction SilentlyContinue
        }
    }
    "posh-git" {
        # posh-git: provides tab completion and prompt integration. [8](https://dahlbyk.github.io/posh-git/)[9](https://git-scm.com/book/ms/v2/Appendix-A:-Git-in-Other-Environments-Git-in-PowerShell)
        if (Get-Module -ListAvailable posh-git -ErrorAction SilentlyContinue) {
            Import-Module posh-git -ErrorAction SilentlyContinue
        }
    }
    default { }
}
