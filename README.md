# IRMHUB

**Universal PowerShell Tool Launcher** — інтерактивний TUI для встановлення популярних open-source утиліт через `irm ... | iex`.

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%20|%207.x-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Cross-Platform](https://img.shields.io/badge/Cross--Platform-Windows%20|%20Linux%20|%20macOS-success)](https://github.com/PowerShell/PowerShell)
[![Zero Telemetry](https://img.shields.io/badge/Telemetry-None-success.svg)](#security-model)
[![GitHub Release](https://img.shields.io/github/v/release/MYMDO/irmhub)](https://github.com/MYMDO/irmhub/releases)

> *One command to rule them all.*

---

## Quick Start

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

**На Linux/macOS** (потрібен PowerShell 7.x):
```powershell
pwsh -c "irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex"
```

> [!CAUTION]
> Завжди перевіряйте скрипт перед виконанням. IRMHUB показує кожну команду перед запуском і вимагає ручного підтвердження `YES`.

---

## Features

- **Централізований каталог** — 19 інструментів у 8 категоріях
- **Інтерактивний TUI** — меню з ANSI-кольорами, навігація цифрами
- **Пошук** — фільтрація за назвою, ключовим словом
- **Категорії** — перегляд за групами (регістронезалежний пошук)
- **CLI режим** — автоматизація та скриптинг без інтерактиву
- **Безпека** — TLS 1.2+, HTTPS-only, попередній перегляд команд, явний дозвіл
- **Кроссплатформенність** — Windows (PS 5.1+), Linux/macOS (pwsh 7+)

---

## Usage

### Interactive Mode (Default)

```powershell
# Запуск TUI
irmhub.ps1

# Навігація категорій за номером
# [s] — пошук
# [q] — вихід
```

### CLI Options

| Option | Description | Example |
|:-------|:------------|:--------|
| `-List` | Показати всі інструменти | `irmhub.ps1 -List` |
| `-Search <term>` | Пошук за ключовим словом | `irmhub.ps1 -Search python` |
| `-Run <id>` | Запустити інструмент за ID | `irmhub.ps1 -Run 6` |
| `-Category <name>` | Фільтр за категорією (регістронезалежно) | `irmhub.ps1 -Category javascript` |
| `-AutoConfirm` | Пропустити підтвердження (з `-Run`) | `irmhub.ps1 -Run 6 -AutoConfirm` |
| `-NoColor` | Вимкнути ANSI-кольори | `irmhub.ps1 -List -NoColor` |
| `-Version` | Показати версію | `irmhub.ps1 -Version` |
| `-Update` | Перевірити оновлення | `irmhub.ps1 -Update` |

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
| 1 | Scoop | No | User-space package manager for Windows |
| 2 | Chocolatey | Yes | Enterprise-grade package repository (10k+ packages) |

### JavaScript

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 3 | Bun | No | All-in-one JS runtime, bundler, test runner, package manager |
| 4 | Deno | No | Secure TypeScript/JS runtime by Node.js creators |
| 5 | fnm | No | Fast Node Version Manager written in Rust |

### Python

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 6 | uv | No | Ultra-fast Python package/project manager by Astral (Rust) |
| 7 | Rye | No | Holistic Python project manager with venv handling |

### Rust

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 8 | Rustup | No | Official Rust toolchain installer (rustc, cargo, clippy) |

### System

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 9 | WinUtil (Chris Titus) | Yes | All-in-one debloat, tweaks, software GUI |
| 10 | MAS (Activation) | Yes | Windows/Office open-source activator (HWID, KMS) |
| 11 | PowerShell 7 | Yes | Official cross-platform PowerShell installer |
| 17 | InstallOffice | Yes | Microsoft Office CLI installation tool |
| 18 | Win11Debloat (Raphire) | Yes | Remove bloatware, telemetry, declutter Windows |
| 19 | WinGet-CLI (LTSC) | Yes | Install WinGet on LTSC/LTSB/Server |

### Shell / UX

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 12 | Oh My Posh | No | Custom prompt engine, 200+ themes, Nerd Font |
| 13 | Terminal-Icons | No | File/folder icons for PowerShell |

### Media

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 14 | Spicetify CLI | No | Customize Spotify desktop client |
| 15 | Spicetify Marketplace | No | In-app theme and extension marketplace |

### Dev Tools

| ID | Tool | Admin | Description |
|:---|:-----|:-----:|:------------|
| 16 | Datatools (Caltech) | No | CLI tools for JSON, CSV, XLSX, DSV processing |

---

## Requirements

| Requirement | Minimum | Recommended |
|:------------|:--------|:------------|
| OS | Windows 10 / 11 | Windows 11 |
| PowerShell | 5.1 | 7.x |
| Network | Internet | Broadband |
| Linux/macOS | pwsh 7.x | pwsh 7.4+ |

> PowerShell 7 (кроссплатформенний) є в каталозі IRMHUB — можна встановити через нього ж.

---

## Adding Custom Tools

Редагуйте `$script:CATALOG` у `irmhub.ps1`:

```powershell
[PSCustomObject]@{
    Id     = 20           # Унікальний послідовний ID
    Name   = 'MyTool'
    Cat    = 'Dev Tools'  # Має точно співпадати з існуючою категорією (case-sensitive!)
    Icon   = '[DEV]'      # [PKG] [JS] [PY] [RS] [SYS] [UX] [MED] [DEV]
    Admin  = $false       # $true якщо потрібні права адміністратора
    Cmd    = 'irm https://example.com/install.ps1 | iex'  # 'Cmd', не 'Command'
    GitHub = 'https://github.com/org/repo'
    Desc   = 'Опис інструменту.'
}
```

### Вимоги до додавання

1. Публічний репозиторій з активною розробкою
2. HTTPS-only URL для встановлення
3. Відсутність обфускації коду
4. Призначення: для розробників, сисадмінів, досвідчених користувачів

---

## Architecture

```
irmhub/
├── irmhub.ps1     # Головний застосунок (651 рядок)
├── index.html     # GitHub Pages лендінг
├── README.md      # Цей файл
├── AGENTS.md      # Інструкції для AI-агентів
├── CONTRIBUTING.md# Гайд з контрибуції
├── CHANGELOG.md   # Історія версій
├── SECURITY.md    # Політика безпеки
├── LICENSE        # MIT License
├── .editorconfig  # Конфігурація редактора
├── .gitignore     # Правила ігнорування Git
├── .github/
│   ├── workflows/
│   │   └── lint.yml          # PSScriptAnalyzer CI
│   └── ISSUE_TEMPLATE/
│       └── new-tool.yml      # Шаблон для додавання інструментів
└── tests/
    └── irmhub.Tests.ps1      # Pester unit-тести
```

### Script Structure (`irmhub.ps1`)

| # | Section | Lines | Purpose |
|:--|:--------|------:|:--------|
| 1 | Constants | 70–87 | Версія, URL, коди виходу |
| 2 | Helper Functions | 89–197 | Безпека, консоль, форматування, пошук |
| 3 | Bootstrap & Security | 199–202 | TLS, ініціалізація консолі |
| 4 | State & UI Config | 204–225 | ANSI-кольори, визначення ширини терміналу |
| 5 | Tool Catalog | 227–249 | Реєстр інструментів (19 шт.) |
| 6 | UI Components | 251–390 | Банер, список категорій, відображення |
| 7 | Execution Logic | 392–473 | Ізольоване виконання команд |
| 8 | Interactive Mode | 475–548 | Головний цикл TUI |
| 9 | Non-Interactive Mode | 550–623 | Обробка CLI-флагів |
| 10 | Main Entry Point | 625–644 | Маршрутизація режимів |

> [!NOTE]
> Функції оголошуються **до** виклику — це вимога `Invoke-Expression` у PS 5.1.
> На відміну від звичайних `.ps1`-файлів, forward references не працюють.

---

## Security Model

| Guarantee | Implementation |
|:----------|:---------------|
| **TLS 1.2+** | `[Net.ServicePointManager]::SecurityProtocol` оновлюється при старті |
| **Command Preview** | Повна команда показується перед виконанням |
| **Explicit Consent** | Потрібно ввести `YES` точно (case-sensitive) |
| **Elevation Check** | Попередження, якщо потрібні права адміністратора |
| **Isolated Execution** | `[scriptblock]::Create()` у розслабленому scope |
| **HTTPS Only** | Каталог вимагає `https://` для всіх URL |
| **Zero Telemetry** | Жодних вихідних дзвінків, крім інсталятора обраного інструменту |
| **Cross-Platform Safe** | OS-залежні API обгорнуті в `try/catch` (Linux/macOS сумісність) |

---

## Troubleshooting

### PowerShell 5.1 + `irm | iex`

При виконанні через `irm ... | iex` у PS 5.1:
- **Немає forward references** — функції мають бути оголошені до виклику (вже вирішено в коді)
- ** `[CmdletBinding()]` на рівні скрипта заборонено** — параметри парсяться вручну з `$args`
- ** `[char] * [int]` викликає помилку** — використовується `[string]` для повторення символів
- ** `exit` в інтерактивному режимі вбиває батьківське вікно** — використовується `return`

### ANSI Colors Not Working

Запустіть у Windows Terminal, VS Code terminal, або:
```powershell
irmhub.ps1 -NoColor
```

Для legacy conhost IRMHUB автоматично вмикає `VirtualTerminalProcessing`.

### Admin Tools Failing

Перезапустіть PowerShell від імені Адміністратора:
```powershell
Start-Process powershell -Verb RunAs
```

### Network Errors

```powershell
Test-NetConnection github.com
```

### Cross-Platform (Linux/macOS)

Деякі інструменти в каталозі призначені тільки для Windows.
IRMHUB безпечно працює на Linux/macOS — OS-залежні функції повертають `$false` замість помилки.

---

## License

MIT License. Див. [LICENSE](LICENSE).

**Відмова від відповідальності:** IRMHUB — агрегатор. Він не афілійований і не схвалює сторонні інструменти. *Завжди перевіряйте вихідний код перед виконанням.*
