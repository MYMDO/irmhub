# Changelog

Формат — [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
версіонування — [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **Interactive mode crash** — `Clear-Console` `CommandNotFoundException` виправлено викликом `Clear-Host` напряму
- **Search UX** — пустий результат пошуку тепер показує "No tools found" та паузу 1.2с замість мовчазного повернення
- **Case-insensitive category** — `-Category "javascript"` тепер працює так само як `"JavaScript"` (через `-ieq`)
- **Cross-platform crash** — `Test-AdministratorRights` обгорнуто в `try/catch`, на Linux/macOS повертає `$false` замість помилки
- **Console width / StrictMode** — `[char] * [int]` замінено на `[string]` скрізь, де використовується повторення
- **Hashtable dot-access** — ANSI-кольори тепер через `$script:ANSI['Red']` замість `.Red`
- **Variable collision renamed** — `$script:VERSION` → `$script:SCRIPT_VERSION` щоб не конфліктувало з `$Version`

### Removed

- Невикористовуваний параметр `$Header` з `Show-ToolList`

### Changed

- Повідомлення при запуску: "child runspace" → "Preparing execution scope"
- Документацію синхронізовано: AGENTS.md переписано як компактний гайд з архітектурними quirks
- Усі команди тестування тепер використовують `-NoColor` для сумісності

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
