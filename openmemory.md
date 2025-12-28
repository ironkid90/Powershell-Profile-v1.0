# ProjectPowershell1 Memory Guide

## Overview
This project manages a modular, performance-optimized PowerShell profile system designed for fast startup and consistent behavior across environments (Windows Terminal, VSCode, Admin, System).

## Architecture
- **Core Profile**: `Profile.ps1` is the main entry point, dot-sourced by the user's primary profile.
  - Context detection (Admin, System, Interactive)
  - Mode selection (Full vs Stable)
  - Deferred loading of heavy components
  - Global configuration (Paths, Encoding)
- **Modules**: `profile.d/*.ps1` contains feature-specific logic (Git, Aliases, Completions).
- **Caching**: 
  - Root: `$env:LOCALAPPDATA\PSProfileCache`
  - Completions: `$env:LOCALAPPDATA\PSProfileCache\completions`

## User Defined Namespaces
- [Leave blank - user populates]

## Components
- **Start-DeferredLoad**: Mechanism to load non-critical components (completions, tools) after the prompt is ready. Currently implemented synchronously for reliability with global state tools (oh-my-posh, aliases).
- **Enable-CliCompletionFromCommand**: Wrapper to cache slow CLI completion outputs (e.g., `kubectl completion powershell`) to disk.
- **Get-ProfileContext**: Returns a custom object with environment state (`IsAdmin`, `IsInteractive`, `IsVSCode`, etc.).

## Patterns
- **Deferred Loading**: Heavy initialization is wrapped in `Start-DeferredLoad`. While originally intended to be async, it runs synchronously in the main session to ensure aliases/functions propagate correctly.
- **Context Awareness**: The profile adapts behavior based on `$global:ProfileContext` (e.g., simplified prompt for Admin, minimal loading for non-interactive).
- **Safe Execution**: Frequent use of `try...catch` blocks and `Test-CommandExists` to prevent startup failures on missing tools.
