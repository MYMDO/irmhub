# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-06

### Added

- **19 tools** across 8 categories:
  - Package Managers: Scoop, Chocolatey
  - JavaScript: Bun, Deno, fnm
  - Python: uv, Rye
  - Rust: Rustup
  - System: WinUtil, MAS, PowerShell 7, InstallOffice, Win11Debloat, WinGet-CLI
  - Shell/UX: Oh My Posh, Terminal-Icons
  - Media: Spicetify CLI, Spicetify Marketplace
  - Dev Tools: Datatools

- **Interactive TUI** with ANSI color support
- **Command-line interface** with multiple modes:
  - `-List` — Display all tools
  - `-Search` — Search by keyword
  - `-Run` — Execute tool by ID
  - `-Category` — Filter by category
  - `-AutoConfirm` — Skip confirmation
  - `-NoColor` — Disable colors
  - `-Version` — Show version
  - `-Update` — Check for updates

- **Security features**:
  - TLS 1.2+ enforcement
  - HTTPS-only URLs
  - Isolated execution scope
  - Admin privilege detection
  - YES confirmation required

- **Documentation**:
  - README.md with full documentation
  - CONTRIBUTING.md guidelines
  - SECURITY.md policy
  - AGENTS.md for AI agents

### Fixed

- WinGet-CLI installer URL updated to `winget.pro`
- Fallback URL `asheroto/winget-install` for 404 errors
- ANSI color compatibility for PowerShell 5.1
- VirtualTerminalProcessing for legacy conhost
- TLS 1.3 fallback for PS 5.1
- StrictMode propagation causing third-party tool failures
- PropertyNotFoundException for Count in older PowerShell

### Refactored

- Modernized UI with better animations
- Enhanced PowerShell script structure with regions
- Improved code documentation
- Better error handling
- Optimized console width detection

### Documentation

- Comprehensive README with tool catalog
- Contributing guidelines
- Security policy
- AI agent instructions

---

## [Unreleased]

### Planned

- [ ] PowerShell Gallery distribution
- [ ] Winget package submission
- [ ] Config file support for custom tools
- [ ] JSON/YAML catalog import
- [ ] Tool update notifications
- [ ] Installation statistics (anonymous)

---

## Version History

| Version | Date | Status |
|:--------|:-----|:-------|
| 1.0.0 | 2026-04-06 | Current |
| 0.1.0 | 2026-03-30 | Initial release |

---

## Migration Guide

### From < 1.0 to 1.0

No breaking changes for interactive users.

For automation scripts using `-List` or `-Search`:

```powershell
# Old (if applicable)
.\irmhub.ps1 -list  # May have worked

# New (correct)
.\irmhub.ps1 -List
```

Exit codes may have changed. Check new exit codes in README.md.

---

## Deprecation Policy

- Deprecated features will be announced 3 months in advance
- Removal will happen in major version bumps
- Security fixes are applied immediately
