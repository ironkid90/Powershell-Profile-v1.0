
# profile.d/60-gui.ps1

if (Get-Module -ListAvailable Microsoft.PowerShell.ConsoleGuiTools -ErrorAction SilentlyContinue) {
    Import-Module Microsoft.PowerShell.ConsoleGuiTools -ErrorAction SilentlyContinue

    function ocgv {
        <#
          Wrapper: pipeline -> Out-ConsoleGridView
          Lets you filter/select objects interactively in the console.
        #>
        param(
            [Parameter(ValueFromPipeline)] $InputObject,
            [string]$Title = "Select",
            [ValidateSet("None","Single","Multiple")] [string]$OutputMode = "Multiple"
        )
        process {
            $InputObject | Out-ConsoleGridView -Title $Title -OutputMode $OutputMode
        }
    }

    function sot {
        <#
          Wrapper: pipeline -> Show-ObjectTree (great for nested objects)
        #>
        param(
            [Parameter(ValueFromPipeline)] $InputObject,
            [string]$Title = "Object Tree"
        )
        process {
            $InputObject | Show-ObjectTree -Title $Title
        }
    }
}
