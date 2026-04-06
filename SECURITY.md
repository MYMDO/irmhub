# Security Policy

## Supported Versions

| Version | Supported          |
|:--------|:------------------|
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:               |

## Reporting a Vulnerability

If you discover a security vulnerability in IRMHUB, please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. Email the maintainers directly or use GitHub's private vulnerability reporting
3. Include detailed information about the vulnerability
4. Allow time for assessment and fix before public disclosure

Expected response time: 48-72 hours

## Security Model

IRMHUB implements multiple layers of security to protect users:

### Transport Layer Security

```powershell
# TLS 1.2+ enforced at startup
[Net.ServicePointManager]::SecurityProtocol = 
    [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
```

### HTTPS Enforcement

- All tool URLs must use `https://`
- No HTTP-only URLs allowed in catalog
- Certificate validation enabled by default

### Command Transparency

Before any tool executes, IRMHUB displays:

1. Tool name and description
2. Full GitHub repository URL
3. Exact command to be executed
4. Administrator privilege requirement
5. Security checklist

### User Consent

- Requires typing `YES` (exact match, case-insensitive)
- No shortcuts or abbreviations accepted
- Cancel by pressing Enter or typing anything else

### Scope Isolation

Tools execute in isolated scriptblock:

```powershell
$sb = [scriptblock]::Create($relaxedCmd)
& $sb
```

This prevents:
- Global scope pollution
- Variable leakage
- Function shadowing

### Privilege Awareness

Tools requiring Administrator rights are flagged in catalog:

```powershell
Admin = $true  # or $false
```

IRMHUB warns users before execution if:
- Tool requires admin rights
- Current session is not elevated

## Known Limitations

### User Responsibility

IRMHUB is a **launcher** that aggregates other tools. Security depends on:

1. **Tool Maintainers** — Each tool's security practices
2. **User Vigilance** — Reviewing commands before execution
3. **Network Security** — HTTPS and TLS enforcement on user's end

### What IRMHUB Does NOT Do

- Verify tool integrity post-install
- Scan for malware in third-party scripts
- Provide sandboxing for executed tools
- Monitor installed software
- Provide update notifications for installed tools

## Best Practices

### For Users

1. **Always verify URLs** before running `irm | iex`
2. **Review source code** of tools before first run
3. **Use `-List`** to preview tools without executing
4. **Report suspicious tools** via GitHub issues
5. **Keep PowerShell updated** to latest version

### For Tool Maintainers

1. **Use HTTPS** for all download URLs
2. **Sign releases** where possible
3. **Provide checksums** for binaries
4. **Maintain security.txt** at repository root
5. **Respond to security reports** promptly

## Security Checklist

Before adding a tool to IRMHUB:

- [ ] Tool repository is publicly accessible
- [ ] Install script uses `https://`
- [ ] No obfuscated or minified code
- [ ] No telemetry or data collection
- [ ] Clean security history (no recent vulnerabilities)

## Security References

- [PowerShell Security Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/security/removing-scripts-from-internet)
- [Windows Security](https://docs.microsoft.com/en-us/windows/security/)
- [NIST Guidelines](https://csrc.nist.gov/publications/sp800-53)

---

**Remember:** Security is a shared responsibility. Stay vigilant!
