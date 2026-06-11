# Changelog

Формат — [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
версіонування — [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- **Function renamed** — `Execute-ToolCommand` → `Invoke-ToolCommand` (PS Approved Verb)
- **Explicit `$AutoConfirm`** — більше не захоплюється з script scope; передається як параметр
- **StrictMode global** — видалено `Set-StrictMode -Off` з `Start-InteractiveMode`
- **Network check** — `Test-NetworkConnectivity` тепер використовує `[System.Net.Dns]::GetHostAddresses()` замість `Invoke-WebRequest`
- **Unknown parameters** — додано обробку невідомих аргументів (exit 6)
- **Catalog validation** — додано перевірку на дублюючі ID при старті

### Fixed

- **Interactive mode crash** — `Clear-Console` `CommandNotFoundException` виправлено викликом `Clear-Host` напряму
- **Search UX** — пустий результат пошуку тепер показує "No tools found" та паузу 1.2с
- **Case-insensitive category** — `-Category "javascript"` працює як `"JavaScript"` (через `-ieq`)
- **Duplicate condition in `Get-ToolsByCategory`** — видалено зайвий `-eq`, залишено тільки `-ieq`
- **Cross-platform crash** — `Test-AdministratorRights` обгорнуто в `try/catch`
- **StrictMode / char-int** — `[char] * [int]` замінено на `[string]` скрізь
- **Hashtable dot-access** — ANSI-кольори через `$script:ANSI['Red']`
- **Variable collision** — `$script:VERSION` → `$script:SCRIPT_VERSION`
- **`$Run` sentinel fix** — `$Run` тепер -1 (замість 0), додано валідацію від'ємних/нульових ID
- **`-Update` без release** — додано fallback повідомлення
- **`$categories.Length` → `.Count`** — уніфіковано для колекцій
- **`Show-SearchUI` side-effect** — більше не встановлює `$script:SEARCH_KEYWORD`, повертає `[PSCustomObject]`

### Removed

- Невикористовуваний параметр `$Header` з `Show-ToolList`

### Changed

- **Color map** — локальний `$colorMap` у `Show-ToolList` винесено в `$script:CATEGORY_COLORS` (State & UI Configuration)
- **MAS disclaimer** — додано "Use at your own risk and in compliance with local laws"
- Повідомлення запуску: "child runspace" → "Preparing execution scope"
- Документацію повністю оновлено (AGENTS.md, README, CONTRIBUTING, CHANGELOG, SECURITY, index.html)
- Рядки: 644 → 651 → 652

### DevOps

- **PSScriptAnalyzer CI** — `.github/workflows/lint.yml` (windows-latest, Errors only)
- **Pester tests** — `tests/irmhub.Tests.ps1` (Search, Get-ToolById, Get-ToolsByCategory, Test-AdministratorRights, Get-ConsoleWidth, Format-Color)
- **Issue template** — `.github/ISSUE_TEMPLATE/new-tool.yml` (структурована форма для додавання інструментів)
- **`Main` guard** — додано `$MyInvocation.InvocationName` check, щоб скрипт не запускався при dot-source (Pester)
- **`.gitignore`** — прибрано `.github/`, `*.yml`, `*.yaml` з ігнорування

---

## [1.0.0] - 2026-04-06

### Added

- **19 tools** across 8 categories
- **Interactive TUI** з ANSI-кольорами
- **CLI**: `-List`, `-Search`, `-Run`, `-Category`, `-AutoConfirm`, `-NoColor`, `-Version`, `-Update`
- **Security**: TLS 1.2+, HTTPS-only, ізольований scope, попередження адмін-прав, підтвердження YES
- **Documentation**: README, CONTRIBUTING, SECURITY, AGENTS

### Fixed

- WinGet-CLI URL → `winget.pro`
- ANSI-кольори для PS 5.1
- VirtualTerminalProcessing для legacy conhost
- TLS 1.3 fallback для PS 5.1
- StrictMode у third-party скриптах
- `Count` PropertyNotFoundException

---

## Version History

| Version | Date | Status |
|:--------|:-----|:-------|
| 1.0.0 | 2026-04-06 | Current |
| 0.1.0 | 2026-03-30 | Initial |
