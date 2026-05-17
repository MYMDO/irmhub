# IRMHUB Agent Guide

## Project Facts

- **Single-file PowerShell TUI** — `irmhub.ps1` (641 lines), Windows only
- **No build system, no tests, no CI** — manual testing only
- **Zero external dependencies** — pure PowerShell 5.1+
- **GitHub Pages** — `index.html` is the landing page

## Developer Commands

```powershell
# Verify script loads without errors
pwsh -File irmhub.ps1 -List -NoColor

# Test search / category
pwsh -File irmhub.ps1 -Search "python" -NoColor
pwsh -File irmhub.ps1 -Category "JavaScript" -NoColor

# Run a tool without confirmation (automation)
pwsh -File irmhub.ps1 -Run 6 -AutoConfirm
```

## Architecture

`irmhub.ps1` uses `#region` blocks in this order: Constants → Helpers → Bootstrap → State/UI Config → Catalog → UI → Execution → Interactive Mode → Non-Interactive Mode → Main.

**Key quirk:** All functions must be defined BEFORE they are called. With `Invoke-Expression` (the `irm | iex` pattern), PowerShell 5.1 does not support forward-referencing functions. So Helpers region comes before Bootstrap. This differs from normal .ps1 file execution where forward references work.

**Entry point:** `Main` function at the bottom routes to `Start-InteractiveMode` (default) or `Start-NonInteractiveMode` (when any CLI flag is set). `Main` is wrapped in try/catch to prevent crashes from closing the PowerShell window. Interactive mode does NOT call `exit` — only non-interactive mode does.

## Adding Tools

Edit `$script:CATALOG` in the Catalog region. Each entry:

```powershell
[PSCustomObject]@{
    Id    = N          # sequential, unique
    Name  = 'ToolName'
    Cat   = 'Category' # must match an existing category exactly (note: 'Cat' not 'Category')
    Icon  = '[CAT]'    # [PKG] [JS] [PY] [RS] [SYS] [UX] [MED] [DEV]
    Admin = $false     # $true if elevation needed
    Cmd   = 'irm https://... | iex'  # note: 'Cmd' not 'Command'
    GitHub = 'https://github.com/org/repo'
    Desc  = 'Description.'
}
```

**Rules:** HTTPS only, active public GitHub repo, no obfuscated code. Tool must serve developers/sysadmins/power users.

## Critical Gotchas

- **PowerShell variable names are case-insensitive.** `$script:VERSION = '1.0.0'` **overwrites** `$Version = $false` because PowerShell treats `VERSION` and `Version` as the same variable. This was the root cause of the `irm | iex` window closing bug — `$Version` became the truthy string `'1.0.0'`, causing the `-Version` branch to always be entered, calling `exit`. Always use distinct names: `$script:SCRIPT_VERSION` not `$script:VERSION`.

- **Confirmation is case-sensitive.** The check uses `-ceq 'YES'` (not `-eq`). User must type exactly `YES` in uppercase.
- **`[CmdletBinding()]` and `param()` break `irm | iex` in PS 5.1.** The script must NOT have `[CmdletBinding()]` or a `param()` block at the top level — they cause MetadataErrors when executed via `Invoke-Expression` (the `| iex` pattern). Parameters are parsed manually from `$args` instead. Functions WITHIN the script CAN use `[CmdletBinding()]` or `[Parameter()]` — the restriction is only at script level.
- **`Set-StrictMode -Version 2.0` interacts badly with `iex` in PS 5.1.** `[char] * [int]` throws "operation not defined". `Write-Divider` uses `[string]` not `[char]`. `Start-InteractiveMode` calls `Set-StrictMode -Off` to avoid this during UI rendering.
- **`$script:` scope works with `iex`.** Despite there being no script scope, `$script:var` resolves to `$global:var` when code runs via `Invoke-Expression`.
- **`$ErrorActionPreference = 'Stop'` is set at the top level.** Makes all errors terminating. Functions that may fail must use try/catch.
- **Tools execute in a relaxed scope.** The `$relaxedCmd` string wraps tool commands with `Set-StrictMode -Off; $ErrorActionPreference = 'Continue'` to prevent third-party scripts from breaking.
- **Exit codes matter.** Non-interactive mode returns exit codes (0=success, 1=cancel, 2=admin required, 3=not found, 4=exec failed, 5=network, 6=bad args, 7=update available).
- **ANSI colors use hashtable bracket notation.** `$script:ANSI['Red']` not `$script:ANSI.Red` — hashtables don't support dot access on keys like `Bold`, `Dim`, `BrightBlack`.

## Conventions

- **EditorConfig:** 4-space indent for `.ps1`, 2-space for `.md`/`.json`/`.yml`, LF line endings, UTF-8
- **Commits:** `type: description` (feat:, fix:, refactor:, docs:)
- **Branches:** `feature/tool-name`
- **gitignore:** excludes `.github/`, `*.yml`, `*.yaml` — do not add CI files to this repo

## Verification

No automated tests. Before committing changes:

```powershell
pwsh -File irmhub.ps1 -List -NoColor       # loads cleanly, shows all 19 tools
pwsh -File irmhub.ps1 -Search python -NoColor  # search works
pwsh -File irmhub.ps1 -Category JavaScript -NoColor  # filter works
```
