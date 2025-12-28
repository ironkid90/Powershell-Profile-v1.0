# Additional completion generators

function Enable-KubectlCompletion {
    Enable-CliCompletionFromCommand -Exe "kubectl" -Arguments @("completion", "powershell") -MaxAgeDays 30
}

function Enable-DockerCompletion {
    if (Test-CommandExists "docker") {
        # Docker doesn't have native PowerShell completion, but we can set up basic completions
        Register-ArgumentCompleter -CommandName docker -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            
            $commands = @('build', 'run', 'ps', 'images', 'rm', 'rmi', 'logs', 'exec', 'start', 'stop')
            $commands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

function Enable-AzureCompletion {
    Enable-CliCompletionFromCommand -Exe "az" -Arguments @("completion", "powershell") -MaxAgeDays 30
}

# Load additional completions in deferred mode
if ($global:DeferredLoaded) {
    Enable-KubectlCompletion
    Enable-DockerCompletion
    Enable-AzureCompletion
}
