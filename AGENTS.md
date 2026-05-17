# IRMHUB Agent Guide

## Project Facts

- **Single-file PowerShell TUI** — `irmhub.ps1` (619 lines), Windows only
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

`irmhub.ps1` uses `#region` blocks in this order: Constants → Bootstrap → State/UI Config → Catalog → Helpers → UI → Execution → Interactive Mode → Non-Interactive Mode → Main.

**Key quirk:** `Initialize-SecurityProtocol` and `Initialize-ConsoleTerminal` are called at lines 99-100 but defined later in the Helpers region. PowerShell parses the entire file before execution so this works.

**Entry point:** `Main` function at the bottom routes to `Start-InteractiveMode` (default) or `Start-NonInteractiveMode` (when any CLI flag is set).

## Adding Tools

Edit `$script:CATALOG` in the Catalog region. Each entry:

```powershell
[PSCustomObject]@{
    Id    = N          # sequential, unique
    Name  = 'ToolName'
    Cat   = 'Category' # must match an existing category exactly
    Icon  = '[CAT]'    # [PKG] [JS] [PY] [RS] [SYS] [UX] [MED] [DEV]
    Admin = $false     # $true if elevation needed
    Cmd   = 'irm https://... | iex'
    GitHub = 'https://github.com/org/repo'
    Desc  = 'Description.'
}
```

**Rules:** HTTPS only, active public GitHub repo, no obfuscated code. Tool must serve developers/sysadmins/power users.

## Critical Gotchas

- **Confirmation is case-sensitive.** The check uses `-ceq 'YES'` (not `-eq`). User must type exactly `YES` in uppercase.
- **Tools execute in a relaxed scope.** Commands are wrapped with `Set-StrictMode -Off; $ErrorActionPreference = 'Continue'` to prevent third-party scripts from breaking under the script's top-level strict mode.
- **`[CmdletBinding()]` and `param()` break `irm | iex` in PS 5.1.** The script must NOT have `[CmdletBinding()]` or a `param()` block at the top level — they cause MetadataErrors when executed via `Invoke-Expression` (the `| iex` pattern). Parameters are parsed manually from `$args` instead.
- **Exit codes matter.** Non-interactive mode returns exit codes (0=success, 1=cancel, 2=admin required, 3=not found, 4=exec failed, 5=network, 6=bad args, 7=update available).

## Conventions

- **EditorConfig:** 4-space indent for `.ps1`, 2-space for `.md`/`.json`/`.yml`, LF line endings, UTF-8
- **Commits:** `type: description` (feat:, fix:, refactor:, docs:)
- **Branches:** `feature/tool-name`
- **gitignore:** excludes `.github/`, `*.yml`, `*.yaml` — do not add CI files to this repo

## Testing

No automated tests. Before committing changes:

1. `pwsh -File irmhub.ps1 -List -NoColor` — loads cleanly, shows all tools
2. `pwsh -File irmhub.ps1 -Search "<keyword>" -NoColor` — search works
3. `pwsh -File irmhub.ps1 -Category "<cat>" -NoColor` — filter works
4. Verify ANSI colors render in Windows Terminal (test without `-NoColor`)
5. Verify admin warning appears for Admin tools when not elevated
