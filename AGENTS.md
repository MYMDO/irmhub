# IRMHUB Agent Guide

## Project Overview

IRMHUB is a single-file PowerShell TUI application for Windows that aggregates open-source tool installers. The project is intentionally simple—no build system, tests, or CI workflows.

## Project Structure

```
irmhub/
├── irmhub.ps1        # Main application (~500 lines, v1.0.0)
├── index.html        # Landing page for GitHub Pages
├── README.md         # User documentation
├── CONTRIBUTING.md   # Contribution guidelines
├── SECURITY.md      # Security policy
├── CHANGELOG.md     # Version history
├── LICENSE          # MIT License
├── AGENTS.md        # This file
├── .gitignore       # Git ignore rules
└── .editorconfig    # Editor configuration
```

## Script Architecture

### Sections (irmhub.ps1)

| Region | Lines | Purpose |
|:-------|:------|:--------|
| Constants | 1-50 | Version, URLs, exit codes |
| Bootstrap | 51-75 | TLS enforcement, console init |
| State/Config | 76-100 | ANSI colors, terminal width |
| Catalog | 101-125 | Tool registry (19 tools) |
| Helpers | 126-200 | Utility functions |
| UI | 201-300 | Display components |
| Execution | 301-375 | Tool execution flow |
| Modes | 376-450 | Interactive/non-interactive |
| Main | 451-500 | Entry point |

### Constants

```powershell
$script:VERSION = '1.0.0'
$script:AUTHOR = 'MYMDO'
$script:REPO_URL = 'https://github.com/MYMDO/irmhub'
$script:EXIT_CODES = @{ Success=0; UserCancel=1; AdminRequired=2; ... }
```

## Script Requirements

- `#Requires -Version 5.1` — Minimum PowerShell 5.1
- `$ErrorActionPreference = 'Stop'`
- `Set-StrictMode -Version 2.0`
- `[CmdletBinding()]` for parameter binding

## Adding Tools to Catalog

Catalog is defined in `$script:CATALOG` (lines ~100-125). Each entry:

```powershell
[PSCustomObject]@{
    Id    = N
    Name  = 'ToolName'
    Cat   = 'Category'
    Icon  = '[CAT]'
    Admin = $false
    Cmd   = 'irm https://... | iex'
    GitHub = 'https://github.com/org/repo'
    Desc  = 'Description.'
}
```

### Categories

| Category | Icon | Example Tools |
|:---------|:----|:-------------|
| Package Manager | [PKG] | Scoop, Chocolatey |
| JavaScript | [JS] | Bun, Deno, fnm |
| Python | [PY] | uv, Rye |
| Rust | [RS] | Rustup |
| System | [SYS] | WinUtil, MAS, WinGet-CLI |
| Shell / UX | [UX] | Oh My Posh, Terminal-Icons |
| Media | [MED] | Spicetify CLI, Spicetify Marketplace |
| Dev Tools | [DEV] | Datatools |

### Rules

- Id must be unique and sequential
- `Admin=$true` for tools requiring elevation
- Commands MUST use `https://` and `irm ... | iex` pattern
- Tool must have active public GitHub repository

## CLI Parameters

| Parameter | Type | Description |
|:----------|:-----|:------------|
| `-List` | switch | Display all tools |
| `-Search` | string | Search by keyword |
| `-Run` | int | Execute tool by ID |
| `-Category` | string | Filter by category name |
| `-AutoConfirm` | switch | Skip YES confirmation |
| `-NoColor` | switch | Disable ANSI colors |
| `-Version` | switch | Show version info |
| `-Update` | switch | Check GitHub for updates |

## Exit Codes

| Code | Constant | Meaning |
|:-----|:---------|:--------|
| 0 | Success | Execution completed |
| 1 | UserCancel | User declined |
| 2 | AdminRequired | Needs elevation |
| 3 | ToolNotFound | Invalid ID |
| 4 | ExecutionFailed | Tool error |
| 5 | NetworkError | No internet |
| 6 | InvalidParameter | Bad args |
| 7 | UpdateAvailable | New version exists |

## Key Conventions

### Security

- TLS 1.2+ enforced at startup (lines ~55-65)
- ANSI color support initialized for PS 5.1 (lines ~66-75)
- Tools execute via `[scriptblock]::Create()` in isolated scope (line ~360)
- Confirmation requires typing `YES` exactly, case-insensitive

### Color Handling

```powershell
$script:COLORS_ENABLED = -not $NoColor
$script:ANSI = if ($script:COLORS_ENABLED) @{ ... } @{ ... }
```

### Console Width

```powershell
function Get-ConsoleWidth {
    try {
        $width = $Host.UI.RawUI.WindowSize.Width
        if ($null -ne $width -and $width -gt 0) {
            return [Math]::Min(100, $width - 2)
        }
    } catch { }
    return 78
}
```

## Testing

```powershell
# Interactive mode
pwsh -File irmhub.ps1

# List all tools
pwsh -File irmhub.ps1 -List -NoColor

# Search
pwsh -File irmhub.ps1 -Search "python"

# Run specific tool
pwsh -File irmhub.ps1 -Run 6 -AutoConfirm

# Test colors disabled
pwsh -File irmhub.ps1 -List -NoColor
```

### Manual Testing Checklist

- [ ] `-List` shows all 19 tools
- [ ] `-Search` returns correct results
- [ ] `-Category` filters correctly
- [ ] `-Run` executes tool
- [ ] `-AutoConfirm` skips confirmation
- [ ] `-NoColor` disables colors
- [ ] `-Version` shows version
- [ ] ANSI colors render correctly
- [ ] Admin warning shows for elevated tools
- [ ] Exit codes are correct

## HTML Landing Page

`index.html` is a static landing page for GitHub Pages:

- SEO meta tags (description, keywords, robots)
- Open Graph and Twitter Card tags
- JSON-LD structured data (Schema.org)
- ARIA labels and roles for accessibility
- CSS custom properties for theming
- Responsive design (mobile-first)
- `prefers-reduced-motion` support

### Copy Button

Uses `navigator.clipboard.writeText()` with fallback:

```javascript
navigator.clipboard.writeText(command)
    .then(() => showCopySuccess(...))
    .catch(() => fallbackCopy(command));
```

## Documentation Files

| File | Purpose | Audience |
|:-----|:--------|:---------|
| README.md | Full project documentation | Users, contributors |
| CONTRIBUTING.md | How to contribute | Developers |
| SECURITY.md | Security policy | Security researchers |
| CHANGELOG.md | Version history | All |
| AGENTS.md | AI agent instructions | Claude, Copilot, etc. |

## Repository Conventions

- Main branch: `main`
- Feature branches: `feature/tool-name`
- Commit style: `type: description` (feat:, fix:, refactor:, docs:)
- Versioning: Semantic (1.0.0)

## Important Notes

1. **No build system** — Script is self-contained
2. **No tests** — Manual testing only
3. **No CI** — PRs reviewed manually
4. **Windows only** — PowerShell TUI for Windows
5. **No dependencies** — Zero external modules

## Troubleshooting

### Colors not working
```powershell
irmhub.ps1 -NoColor
```

### Admin tools failing
Restart PowerShell as Administrator.

### Network errors
```powershell
Test-NetConnection github.com
```
