# Contributing to IRMHUB

Thank you for your interest in contributing to IRMHUB!

## Ways to Contribute

### 1. Report Issues

- Search existing issues before creating new ones
- Use issue templates when available
- Include reproduction steps and expected vs actual behavior
- Specify your PowerShell version and Windows version

### 2. Submit Tool Proposals

Open a new issue with the **Tool Request** template and include:

```
Name: [Tool Name]
Category: [Package Manager / JS / Python / Rust / System / Shell / UX / Media / Dev Tools]
URL: [Install script URL - must be HTTPS]
GitHub: [Repository URL]
Admin Required: [Yes / No]
Description: [Brief description of the tool]
```

### 3. Submit Pull Requests

#### PR Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/tool-name`
3. Make your changes
4. Test locally with `pwsh -File irmhub.ps1`
5. Commit with clear messages
6. Push and create PR

#### Code Style

- Follow PowerShell best practices
- Use `#Requires -Version 5.1` for compatibility
- Use `[CmdletBinding()]` for functions with parameters
- Use `param()` block for script-level parameters
- Use descriptive function names with Verb-Noun pattern
- Comment complex logic but avoid obvious comments

#### Required Checks

Before submitting a PR:

```powershell
# Verify script loads without errors
. .\irmhub.ps1 -List -NoColor

# Test search functionality
. .\irmhub.ps1 -Search "python" -NoColor

# Test category filter
. .\irmhub.ps1 -Category "JavaScript" -NoColor
```

### 4. Documentation

- Update README.md if adding features
- Add code comments for non-obvious logic
- Update this CONTRIBUTING.md if contributing guidelines change

---

## Tool Addition Criteria

Tools submitted for inclusion must meet:

1. **Active Development** — Regular commits within last 6 months
2. **Community Trust** — Established user base and positive reception
3. **Open Source** — Public repository with OSI-approved license
4. **HTTPS Installation** — Install script must use `https://`
5. **No Obfuscation** — Source must be readable and auditable
6. **Relevant Purpose** — CLI tools for developers, sysadmins, power users

### Categories

| Category | Description |
|:---------|:------------|
| Package Manager | Windows package managers (Scoop, Chocolatey) |
| JavaScript | JS runtimes, package managers, tools |
| Python | Python package managers, tools |
| Rust | Rust toolchain, cargo tools |
| System | Windows utilities, optimizers, activators |
| Shell / UX | Prompt engines, terminal enhancements |
| Media | Spotify, audio/video tools |
| Dev Tools | Development utilities, CLI tools |

---

## Development Setup

```powershell
# Clone your fork
git clone https://github.com/YOUR-USERNAME/irmhub.git
cd irmhub

# Create feature branch
git checkout -b feature/my-tool

# Test changes
pwsh -File irmhub.ps1 -List

# Commit changes
git add .
git commit -m "feat: Add MyTool to catalog"

# Push to your fork
git push origin feature/my-tool
```

---

## Scripts

### Testing Matrix

Test across these environments:

| PowerShell | Windows | Status |
|:-----------|:--------|:-------|
| 5.1 | 10 | Required |
| 7.x | 10 | Required |
| 7.x | 11 | Recommended |

### Manual Testing Checklist

- [ ] Script loads without errors
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

---

## Questions?

- Open an issue for bugs
- Start a discussion for questions
- Check existing issues before asking

---

## Recognition

Contributors will be recognized in:
- GitHub release notes
- Project documentation
- Community announcements

Thank you for making IRMHUB better!
