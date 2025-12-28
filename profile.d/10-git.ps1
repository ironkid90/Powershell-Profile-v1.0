# Git-related profile components (loaded deferred)

function Get-GitStatusInfo {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        
        if ($branch) {
            $dirty = if ($status) { "*" } else { "" }
            return "git:($branch$dirty)"
        }
    }
    return $null
}

# Git aliases
Set-Alias -Name g -Value git
function gs { git status }
function gco { git checkout $args }
function gcm { git commit $args }
function gp { git push $args }

function Get-GitPrompt {
    $info = Get-GitStatusInfo
    if ($info) { " $info" } else { "" }
}
