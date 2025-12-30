
# profile.d/40-psfzf-optional.ps1

if ($global:PPP.EnablePSFzf) {
    if (Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue) {
        Import-Module PSFzf -ErrorAction SilentlyContinue

        # Standard PSFzf chords. [12](https://github.com/kelleyma49/PSFzf)[13](https://deepwiki.com/kelleyma49/PSFzf/3-user-guide)
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                        -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}
