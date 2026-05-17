# IRMHUB

**Universal PowerShell Tool Launcher**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Zero Telemetry](https://img.shields.io/badge/Telemetry-None-success.svg)](#security-model)
[![GitHub Release](https://img.shields.io/github/v/release/MYMDO/irmhub)](https://github.com/MYMDO/irmhub/releases)

> *One command to rule them all.*
> An interactive TUI that aggregates popular open-source utilities installable via `irm ... | iex` with full security transparency.

---

## Quick Start

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

> **Security Note:** Inspect the raw script at the URL above before execution, as is best practice for any `irm | iex` command.

---

## Features

- **Centralized Catalog** — 19 tools across 8 categories
- **Interactive TUI** — Menu-driven interface with ANSI color support
- **Category Filtering** — Browse by Package Managers, JavaScript, Python, Rust, System, Shell/UX, Media, Dev Tools
- **Search Engine** — Filter by name, keyword, or category
- **CLI Mode** — Non-interactive automation and scripting
- **Security First** — TLS 1.2+, HTTPS-only, command preview, explicit consent

---

## Usage

### Interactive Mode (Default)

```powershell
# Launch interactive TUI
irmhub.ps1

# Navigate categories by number
# Press [s] to search
# Press [q] to quit
```

### Command-Line Options

| Option | Description | Example |
|:-------|:------------|:--------|
| `-List` | Display all tools | `irmhub.ps1 -List` |
| `-Search <term>` | Search tools | `irmhub.ps1 -Search python` |
| `-Run <id>` | Execute tool by ID | `irmhub.ps1 -Run 6` |
| `-Category <name>` | Filter by category | `irmhub.ps1 -Category JavaScript` |
| `-AutoConfirm` | Skip confirmation (use with `-Run`) | `irmhub.ps1 -Run 6 -AutoConfirm` |
| `-NoColor` | Disable ANSI colors | `irmhub.ps1 -List -NoColor` |
| `-Version` | Show version | `irmhub.ps1 -Version` |
| `-Update` | Check for updates | `irmhub.ps1 -Update` |

### Exit Codes

| Code | Meaning |
|:-----|:--------|
| `0` | Success |
| `1` | User cancelled |
| `2` | Admin required |
| `3` | Tool not found |
| `4` | Execution failed |
| `5` | Network error |
| `6` | Invalid parameter |
| `7` | Update available |

---

## Tool Catalog

### Package Managers

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 1 | Scoop | No | User-space package manager |
| 2 | Chocolatey | Yes | Enterprise-grade package repository |

### JavaScript

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 3 | Bun | No | All-in-one JS runtime, bundler, test runner |
| 4 | Deno | No | Secure TypeScript/JS runtime |
| 5 | fnm | No | Fast Node Version Manager (Rust) |

### Python

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 6 | uv | No | Ultra-fast Python package manager (Rust) |
| 7 | Rye | No | Holistic Python project manager |

### Rust

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 8 | Rustup | No | Official Rust toolchain installer |

### System

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 9 | WinUtil (Chris Titus) | Yes | All-in-one debloat, tweaks, software GUI |
| 10 | MAS (Activation) | Yes | Windows/Office open-source activator |
| 11 | PowerShell 7 | Yes | Official cross-platform PowerShell installer |
| 17 | InstallOffice | Yes | Microsoft Office CLI installation tool |
| 18 | Win11Debloat | Yes | Remove bloatware and telemetry |
| 19 | WinGet-CLI | Yes | Install WinGet on LTSC/LTSB/Server |

### Shell / UX

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 12 | Oh My Posh | No | Custom prompt engine, 200+ themes |
| 13 | Terminal-Icons | No | File/folder icons for PowerShell |

### Media

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 14 | Spicetify CLI | No | Customize Spotify desktop client |
| 15 | Spicetify Marketplace | No | In-app theme and extension marketplace |

### Dev Tools

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 16 | Datatools (Caltech) | No | CLI for JSON, CSV, XLSX processing |

---

## Requirements

| Requirement | Minimum | Recommended |
|:------------|:--------|:------------|
| OS | Windows 10 / 11 | Windows 11 |
| PowerShell | 5.1 | 7.x |
| Network | Internet | Broadband |

> **Note:** PowerShell 7 (cross-platform) is available in the catalog and can be installed via IRMHUB itself.

---

## Adding Custom Tools

Edit `$script:CATALOG` in `irmhub.ps1`. Each entry:

```powershell
[PSCustomObject]@{
    Id    = 20           # sequential, unique
    Name  = 'MyTool'
    Cat   = 'Dev Tools'  # must match existing category exactly
    Icon  = '[DEV]'      # [PKG] [JS] [PY] [RS] [SYS] [UX] [MED] [DEV]
    Admin = $false       # $true if elevation is required
    Cmd   = 'irm https://example.com/install.ps1 | iex'
    GitHub = 'https://github.com/org/repo'
    Desc  = 'A brief description.'
}
```

### Submission Guidelines

1. Active public repository with community trust
2. HTTPS-only installation URL
3. No obfuscated code
4. Serves developers, sysadmins, or power users

---

## Architecture

```
irmhub/
├── irmhub.ps1     # Main application (644 lines)
├── index.html     # GitHub Pages landing page
├── README.md      # This file
├── AGENTS.md      # AI agent instructions
├── CONTRIBUTING.md   # Contribution guidelines
├── CHANGELOG.md   # Version history
├── SECURITY.md    # Security policy
├── LICENSE        # MIT License
├── .editorconfig  # Editor configuration
└── .gitignore     # Git ignore rules
```

### Script Structure (`irmhub.ps1`)

| Section | Purpose |
|:--------|:--------|
| Constants | Version, URLs, exit codes |
| Helper Functions | Security, console, formatting, search utilities |
| Bootstrap & Security | TLS enforcement, console initialization |
| State & UI Configuration | ANSI colors, terminal width detection |
| Tool Catalog | Tool registry (19 tools) |
| UI Components | Banner, category list, tool display |
| Execution Logic | Command execution in isolated scope |
| Interactive Mode | Menu-driven TUI loop |
| Non-Interactive Mode | CLI flag handling |
| Main Entry Point | Mode routing |

> **Note:** Functions are defined before they are called to support `Invoke-Expression` execution in PowerShell 5.1. This differs from standard `.ps1` execution where forward references work.

---

## Security Model

| Guarantee | Implementation |
|:----------|:---------------|
| **TLS 1.2+** | `[Net.ServicePointManager]::SecurityProtocol` updated at startup |
| **Command Preview** | Full command shown before execution |
| **Explicit Consent** | Requires typing `YES` exactly to proceed |
| **Elevation Check** | Warns if administrator rights are required |
| **Isolated Execution** | `[scriptblock]::Create()` in relaxed scope prevents pollution |
| **HTTPS Only** | Catalog enforces `https://` for all URLs |
| **Zero Telemetry** | No outbound calls except the selected tool's installer |

---

## Troubleshooting

### PowerShell 5.1 and `irm | iex`

When running via the `irm ... | iex` pattern in PowerShell 5.1, the script is executed through `Invoke-Expression`. Known caveats:
- **No forward references** — all functions must be defined before invocation (already handled in this script)
- **No `[CmdletBinding()]` at script level** — scripts downloaded via this pattern do not support it; parameters are parsed manually

### ANSI Colors Not Working

Run in Windows Terminal or VS Code integrated terminal. For legacy conhost:

```powershell
irmhub.ps1 -NoColor
```

### Admin Tools Failing

Restart PowerShell as Administrator:

```powershell
Start-Process powershell -Verb RunAs
```

### Network Errors

Check internet connectivity and firewall rules:

```powershell
Test-NetConnection github.com
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

**Disclaimer:** IRMHUB is an aggregator tool. It is not affiliated with, nor does it explicitly endorse, any third-party tools. *Always review source code before executing.*
