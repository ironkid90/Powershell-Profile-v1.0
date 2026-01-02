# Project PowerShell Profile (PPP) v1.0

A high-performance, modular, and context-aware PowerShell profile designed for modern development workflows.

## 🎯 Project Goals
- **Fast Startup**: Optimized loading sequence with selective feature activation.
- **Predictable Behavior**: Context detection ensures the profile behaves correctly in VSCode, Windows Terminal, SSH, and as Administrator.
- **Modular Design**: Features are separated into logical modules in the `profile.d/` directory.
- **Completion Preservation**: Caches CLI tool completions (like Helm) to avoid expensive generation on every shell start.
- **Agent Friendly**: Structured to work well with AI coding assistants and automation.

## 🚀 Installation & Activation

### 1. Link to your PowerShell Profile
Instead of copying the file, it is recommended to "dot-source" it from your main profile. This allows you to keep the repository separate and update it easily.

#### On Windows:
Add the following line to your `$PROFILE` (usually `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`):

```powershell
. "C:\Path\To\Your\Repo\Profile.ps1"
```

#### On Linux / WSL:
1. Ensure PowerShell 7 is installed (`sudo apt install -y powershell`).
2. Clone this repo to a directory (e.g., `~/projects/powershell-profile`).
3. Add the following line to your `$PROFILE` (usually `~/.config/powershell/Microsoft.PowerShell_profile.ps1`):

```powershell
. "$HOME/projects/powershell-profile/Profile.ps1"
```

### 2. Set up the Module Directory
Ensure the `profile.d` folder is in the same directory as `Profile.ps1`. Any `.ps1` files placed in `profile.d/` will be automatically loaded alphabetically. On Linux, ensure the files have correct permissions if you plan to execute them directly (though dot-sourcing handles this).

## 🐧 WSL / Linux Compatibility
The profile is cross-platform and automatically detects the operating system:
- **Paths**: Uses `~/.config/powershell` for the root and `~/.cache/PSProfileCache` for completions on Linux.
- **Admin**: Detects root via `id -u` on Linux.
- **Tools**: Switches from `gsudo` (Windows) to standard `sudo` (Linux) where appropriate.
- **Interoperability**: If running in WSL, it maintains compatibility with Windows Terminal features.

## 📂 Project Structure
- `Profile.ps1`: The core profile logic and entry point.
- `profile.d/`: Directory for modular scripts.
  - `10-git.ps1`: Git aliases and functions.
  - `20-aliases.ps1`: Navigation and general utility aliases.
  - `30-completions.ps1`: CLI completion registrations.
  - `35-terminal-icons.ps1`: Optional icon theming for directory listings.
  - `36-carapace.ps1`: Optional Carapace completion hook (user-supplied init).
  - `37-predictors.ps1`: Optional PSReadLine predictors (e.g., Az.Tools.Predictor).
  - `50-help.ps1`: User help and install guidance functions.
- `openmemory.md`: Architectural documentation and design decisions.

## 🛠️ Key Commands

| Command | Description |
|---------|-------------|
| `Show-ProfileStatus` | Displays current session context (Admin, VSCode, etc.) and loading mode. |
| `Invoke-ProfileHealthCheck` | Checks for the presence of recommended tools (gsudo, oh-my-posh, etc.). |
| `Edit-Profile` | Opens the current `Profile.ps1` in VS Code for quick editing. |
| `Update-Profile` | Manually triggers a refresh of cached components (like completions). |
| `Initialize-TerminalToolchain` | Bootstraps the environment by setting up tool directories. |
| `Show-ProfileHelp` | Beginner-friendly tips and key shortcuts. |
| `Show-ToolInstallHelp` | Quick install commands for optional modules. |

## ⚙️ Loading Modes
The profile automatically selects a mode based on the environment:
- **Full Mode**: Activated in interactive user sessions. Loads all modules, themes, and completions.
- **Stable Mode**: Activated in non-interactive sessions or system accounts. Loads only essentials for maximum reliability and speed.

## 📦 Recommended Modules
```powershell
Install-Module npm-completion -Scope CurrentUser
Install-Module git-completion -Scope CurrentUser   # or: Install-Module posh-git
Install-Module PSFzf -Scope CurrentUser            # optional (needs fzf installed)
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
Install-Module Terminal-Icons -Scope CurrentUser
Install-Module Az.Tools.Predictor -Scope CurrentUser
```

Optional external tools:
- **fzf** (required by PSFzf)
- **Carapace** (optional): set `PPP_ENABLE_CARAPACE=1` and provide `PPP_CARAPACE_SCRIPT` or `PPP_CARAPACE_INIT`



## 📝 Usage Tips
- **Adding Aliases**: Add new aliases to a new script in `profile.d/` to keep the main profile clean.
- **Custom Themes**: The profile supports `oh-my-posh` out of the box. Simply install it and the profile will detect and initialize it.
- **Admin Tools**: Use `gsudo` (aliased to `sudo`) for seamless elevation within the terminal.
- **Terminal Icons**: Install `Terminal-Icons` for file/folder glyphs in `Get-ChildItem`.
- **Predictors**: Install `Az.Tools.Predictor` for smart PSReadLine suggestions (enabled automatically if present).
- **Carapace**: Set `PPP_ENABLE_CARAPACE=1` and provide `PPP_CARAPACE_SCRIPT` or `PPP_CARAPACE_INIT` to load your Carapace PowerShell init.
- **Help**: Run `Show-ProfileHelp` and `Show-ToolInstallHelp` for quick reminders.

## 🧰 Troubleshooting
### ParserError: `$Name:` variable reference is not valid
If you see an error like:
```
Variable reference is not valid. ':' was not followed by a valid variable name character.
```
make sure your `$PROFILE` is dot-sourcing the **latest** `Profile.ps1` from this repo and not an older copy.
Steps:
1. Confirm your `$PROFILE` file contains a line like:
   ```powershell
   . "C:\Path\To\Your\Repo\Profile.ps1"
   ```
2. Remove or update any old copies of `Profile.ps1` that might still be referenced.
3. Restart the terminal and run `Show-ProfileStatus`.

---
*Developed as part of the ProjectPowershell1 initiative.*
