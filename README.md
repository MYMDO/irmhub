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

Open PowerShell (or Windows Terminal) and run:

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

> **Security Note:** We strongly recommend inspecting the raw script at the URL above before execution, as is best practice for any `irm | iex` command.

---

## Features

### Core Features

- **Centralized Catalog** — Organizes 19+ tools across 8 categories
- **Interactive TUI** — Menu-driven interface with ANSI color support
- **Category Filtering** — Browse tools by Package Managers, JS, Python, Rust, System, Shell/UX, Media, Dev Tools
- **Search Engine** — Quickly filter the catalog by name, keyword, or category
- **CLI Mode** — Non-interactive usage for automation and scripting

### Security Model

| Guarantee | Implementation |
|:----------|:---------------|
| **TLS 1.2+** | `[Net.ServicePointManager]::SecurityProtocol` updated at startup |
| **Command Preview** | Full command shown before any execution |
| **Explicit Consent** | Requires typing `YES` to proceed |
| **Elevation Check** | Warns if Admin rights are required |
| **Zero Telemetry** | No external HTTP calls except selected tool |
| **Isolated Scope** | `[scriptblock]::Create()` prevents scope pollution |
| **HTTPS Only** | Catalog enforces `https://` for all URLs |

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
| `-AutoConfirm` | Skip confirmation | `irmhub.ps1 -Run 6 -AutoConfirm` |
| `-NoColor` | Disable colors | `irmhub.ps1 -List -NoColor` |
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
| 1 | Scoop | No | Windows package manager. User-space installs. |
| 2 | Chocolatey | Yes | Largest Windows package repo. Enterprise-grade. |

### JavaScript

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 3 | Bun | No | All-in-one JS runtime, bundler, test runner. |
| 4 | Deno | No | Secure TypeScript/JS runtime. Built-in TS support. |
| 5 | fnm | No | Fast Node Version Manager written in Rust. |

### Python

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 6 | uv | No | Ultra-fast Python package manager by Astral. |
| 7 | Rye | No | Holistic Python project and environment manager. |

### Rust

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 8 | Rustup | No | Official Rust toolchain installer. |

### System

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 9 | WinUtil | Yes | Windows debloat, tweaks, software install GUI. |
| 10 | MAS | Yes | Windows/Office activator. HWID, KMS38, Online KMS. |
| 11 | PowerShell 7 | Yes | Official Microsoft PowerShell 7 installer. |
| 17 | InstallOffice | Yes | Microsoft Office CLI installation tool. |
| 18 | Win11Debloat | Yes | Remove bloatware and telemetry. |
| 19 | WinGet-CLI | Yes | Install WinGet on LTSC/LTSB/Server. |

### Shell / UX

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 12 | Oh My Posh | No | Custom prompt engine. 200+ themes. |
| 13 | Terminal-Icons | No | File/folder icons for PowerShell. |

### Media

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 14 | Spicetify CLI | No | Customize Spotify with themes. |
| 15 | Spicetify Marketplace | No | In-app marketplace for themes. |

### Dev Tools

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 16 | Datatools | No | CLI tools for JSON, CSV, XLSX processing. |

---

## Requirements

| Requirement | Minimum | Recommended |
|:------------|:--------|:------------|
| OS | Windows 10 / 11 | Windows 11 |
| PowerShell | 5.1 | 7.x |
| Network | Internet | Broadband |

---

## Adding Custom Tools

Edit `irmhub.ps1` and add an entry to `$script:CATALOG`:

```powershell
[PSCustomObject]@{
    Id    = 20
    Name  = 'MyTool'
    Cat   = 'Dev Tools'
    Icon  = '[DEV]'
    Admin = $false
    Cmd   = 'irm https://example.com/install.ps1 | iex'
    GitHub = 'https://github.com/org/repo'
    Desc  = 'A brief description.'
}
```

### PR Guidelines

To submit tools to the main repository:

1. Tool must have an active public repository with community trust
2. Installation payload must use `https://`
3. Script must contain no obfuscated code
4. Functionality must align with CLI enhancement

---

## Architecture

```
irmhub/
├── irmhub.ps1     # Main application (~500 lines)
├── index.html     # Landing page (GitHub Pages)
├── README.md      # This file
├── LICENSE        # MIT License
└── AGENTS.md      # AI agent instructions
```

### Script Structure

| Section | Lines | Purpose |
|:--------|:-----:|:--------|
| Constants | 1-50 | Version, URLs, exit codes |
| Bootstrap | 51-75 | TLS, console init |
| Catalog | 76-100 | Tool registry |
| Helpers | 101-175 | Utility functions |
| UI | 176-275 | Display components |
| Execution | 276-350 | Tool execution flow |
| Main | 351-500 | Entry points |

---

## Troubleshooting

### ANSI Colors Not Working

Run in Windows Terminal or VS Code integrated terminal. For legacy conhost:
```powershell
irmhub.ps1 -NoColor
```

### Admin Tools Failing

Some tools require Administrator privileges. Restart PowerShell as Admin:
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
