# IRMHUB Agent Guide

## Project Facts
- **Single-file PowerShell TUI:** `irmhub.ps1` (656 рядків). Windows (PS 5.1+), Linux/macOS (pwsh 7+).
- **No build system, tests, or CI:** лише ручна верифікація.
- **Zero external dependencies:** чистий PowerShell.
- **GitHub Pages:** `index.html` — лендінг.

## Testing
```powershell
# Pester unit-тести (усі функції)
Invoke-Pester ./tests/irmhub.Tests.ps1

# Перевірка PSScriptAnalyzer (CI)
Invoke-ScriptAnalyzer ./irmhub.ps1 -Severity Error
```

## Verification Commands
```powershell
# Синтаксис + список 19 інструментів
pwsh -File irmhub.ps1 -List -NoColor

# Пошук та фільтрація (регістронезалежно)
pwsh -File irmhub.ps1 -Search "python" -NoColor
pwsh -File irmhub.ps1 -Category "javascript" -NoColor

# Запуск без підтвердження (автоматизація)
pwsh -File irmhub.ps1 -Run 6 -AutoConfirm
```

## Architecture Quirks
- **No Forward References:** Функції — до виклику (Helpers → Bootstrap → UI → ...). PS 5.1 `iex` не підтримує forward references.
- **No Script-Level `[CmdletBinding()]` або `param()`:** `MetadataError` у `iex`. Параметри парсяться вручну з `$args`. Всередині функцій — без обмежень.
- **Variable Collision:** PowerShell case-insensitive. `$script:VERSION` перезапише `-Version` switch `$Version`. Використовуйте `$script:SCRIPT_VERSION`.
- **Exit Behavior:** Інтерактивний режим — **ніколи** `exit` (тільки `return`), інакше вб'є батьківське вікно при `iex`. Неінтерактивний — `exit` з кодом.
- **Exit Codes:** 0=Success, 1=Cancel, 2=AdminRequired, 3=NotFound, 4=ExecFailed, 5=Network, 6=BadArgs, 7=UpdateAvailable.
- **StrictMode + `[char] * [int]`:** `Set-StrictMode -Version 2.0` ламає множення char на int під `iex`. Завжди `[string]` для повторення (напр. у `Write-Divider`). `[char] * [int]` скрізь виправлено, тому `Set-StrictMode -Off` більше не потрібен.
- **Hashtable Access:** `$script:ANSI['Red']`, не `$script:ANSI.Red` (ключі `Bold`, `Dim` ламають dot-notation).
- **Cross-Platform Safety:** `[Security.Principal.WindowsIdentity]::GetCurrent()` падає на Linux/macOS. Обгортайте в `try/catch`.
- **Confirmation:** `-ceq 'YES'` (case-sensitive). Тільки `YES` великими.
- **$ErrorActionPreference:** Встановлено `'Stop'` на рівні скрипта. Функції, що можуть фейлитись — у try/catch.
- **Relaxed Scope для команд:** `$relaxedCmd` обгортає виконання в `Set-StrictMode -Off; $ErrorActionPreference = 'Continue'`.
- **Approved Verb:** `Invoke-ToolCommand` (не `Execute-`). PS Approved Verb.
- **DNS замість HTTP:** `Test-NetworkConnectivity` використовує `[System.Net.Dns]::GetHostAddresses()`, не `Invoke-WebRequest`.

## Adding a Tool
Редагувати `$script:CATALOG` у `irmhub.ps1`.
```powershell
[PSCustomObject]@{
    Id     = N                           # Унікальний ID
    Name   = 'ToolName'
    Cat    = 'Category'                  # Має точно співпадати (case-sensitive!)
    Icon   = '[CAT]'                     # [PKG] [JS] [PY] [RS] [SYS] [UX] [MED] [DEV]
    Admin  = $false                      # $true якщо elevation
    Cmd    = 'irm https://... | iex'     # 'Cmd', не 'Command'
    GitHub = 'https://github.com/org/repo'
    Desc   = 'Description.'
}
```
**Policy:** HTTPS only, активний GitHub, без обфускації, без телеметрії.
