<div align="center">

# ⚡ IRMHUB
**Universal PowerShell Tool Launcher**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Zero Telemetry](https://img.shields.io/badge/Telemetry-None-success.svg)](#privacy--security-model)

> *One command to rule them all.*<br>
> An interactive TUI that aggregates popular open-source utilities installable via `irm ... | iex` with full security transparency.

</div>

---

## 🚀 Quick Start

Open PowerShell (or Windows Terminal) and run:

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

> **Note:** We strongly recommend inspecting the raw script at the URL above before execution, as is best practice for any `irm | iex` command.

## 📖 Overview

IRMHUB is a premium, zero-dependency PowerShell TUI (Text User Interface) designed for developers, system administrators, and power users. It simplifies the discovery and securely manages the installation of essential Windows-based open-source CLI tools.

### Core Features

- **Centralized Catalog:** Organizes tools across categories (Package Managers, JS, Python, Rust, System, Shell/UX, Media, Dev Tools).
- **Search Engine:** Quickly filter the catalog by name, keyword, or category.
- **Security Check:** Previews the *exact* command before making any system changes.
- **Privilege Awareness:** Automatically detects and warns if a tool requires Administrator elevation.
- **Zero Telemetry:** Makes no external HTTP calls other than to the specific tool script you select.

## 🛡️ Privacy & Security Model

IRMHUB is built on a foundation of absolute transparency and security. 

| Security Guarantee | Technical Implementation |
|:-------------------|:-------------------------|
| **Forced TLS 1.2+** | `[Net.ServicePointManager]::SecurityProtocol` is dynamically updated at startup. |
| **Command Preview** | Before execution, the payload command is printed in plain text for review. |
| **Explicit Consent** | Execution is paused until the user manually types `YES`. |
| **Elevation Check** | Leverages `WindowsPrincipal.IsInRole(Administrator)` to fail safely on admin tools. |
| **Zero Logging** | No usage data, hardware IDs, or IPs are logged, persisted, or transmitted. |
| **Isolated Scope** | Uses `[scriptblock]::Create()` to prevent global scope pollution of your session. |
| **Strict HTTPS** | The catalog enforces `https://` for all target repositories and payloads. |

## 📦 Included Tools Registry

IRMHUB ships with the following curated open-source projects:

| Tool | Category | Admin Required |
|:-----|:---------|:--------------:|
| **Scoop** | Package Manager | No |
| **Chocolatey** | Package Manager | Yes |
| **Bun** | JavaScript | No |
| **Deno** | JavaScript | No |
| **fnm** | JavaScript | No |
| **uv** (Astral) | Python | No |
| **Rye** | Python | No |
| **Rustup** | Rust | No |
| **WinUtil** | System | Yes |
| **MAS** | System | Yes |
| **PowerShell 7** | System | Yes |
| **Oh My Posh** | Shell / UX | No |
| **Terminal-Icons** | Shell / UX | No |
| **Spicetify CLI** | Media | No |
| **Spicetify Marketplace**| Media | No |
| **Datatools** | Dev Tools | No |
| **InstallOffice Tool** | System | Yes |
| **Win11Debloat (Raphire)** | System | Yes |
| **Microsoft PowerToys** | System | Yes |
| **UniGetUI (WingetUI)** | System | Yes |
| **Windhawk** | System | Yes |

## 🛠️ Modifying the Catalog

Want to add your favorite tool to your fork? Simply edit `irmhub.ps1` and append a new hashtable to the `$script:CATALOG` array:

```powershell
@{ 
    Id      = 17; 
    Name    = 'MyTool'; 
    Cat     = 'Dev Tools'; 
    Icon    = '[DEV]'; 
    Admin   = $false; 
    Cmd     = 'irm https://example.com/install.ps1 | iex'; 
    GitHub  = 'https://github.com/org/repo'; 
    Desc    = 'A brief description of what this does.' 
}
```

### Pull Request Guidelines
If you are submitting a PR to the main repository, the tool must meet the following criteria:
1. Backed by an active public repository (e.g., GitHub) with verifiable community trust.
2. The installation payload must be strictly `https://`.
3. The script must contain no obfuscated code.
4. Functionality must align with development, system administration, or CLI enhancement.

## ⚙️ Requirements

- **OS:** Windows 10 / 11
- **Engine:** PowerShell 5.1 (Built-in) or PowerShell 7+ (Core)
- **Network:** Active internet connection

## 📄 License & Disclaimer

This project is licensed under the [MIT License](LICENSE).

**Disclaimer:** IRMHUB is an aggregator tool. It is not affiliated with, nor does it explicitly endorse, any of the third-party tools listed in its catalog. Each tool is the property of its respective authors. *Always review third-party source code before executing it on your machine.*
