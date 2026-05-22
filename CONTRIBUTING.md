# Contributing to IRMHUB

Дякуємо за інтерес до контрибуції!

---

## Ways to Contribute

### 1. Report Issues

- Пошукайте серед існуючих issues перед створенням нового
- Додайте кроки відтворення, очікувану та фактичну поведінку
- Вкажіть версію PowerShell та ОС

### 2. Submit Tool Proposals

Відкрийте issue з шаблоном **Tool Request**:

```
Name: [Tool Name]
Category: [Package Manager / JS / Python / Rust / System / Shell/UX / Media / Dev Tools]
URL: [Install script — HTTPS only]
GitHub: [Repository URL]
Admin Required: [Yes / No]
Description: [Короткий опис]
```

### 3. Submit Pull Requests

#### PR Process

1. Форкніть репозиторій
2. Створіть гілку: `git checkout -b feature/tool-name`
3. Внесіть зміни
4. Протестуйте локально (див. [Testing](#testing))
5. Закомітьте зі зрозумілим повідомленням
6. Запуште та створіть PR

#### Code Style

- Дотримуйтесь PowerShell best practices
- **Не використовуйте** `[CmdletBinding()]` або `param()` на **рівні скрипта** — це ламає `irm | iex` у PS 5.1 (MetadataError). Параметри парсяться вручну з `$args`
- Всередині **функцій** можна використовувати `[CmdletBinding()]` та `[Parameter()]` без обмежень
- Імена функцій — Verb-Noun
- **Уникайте однакових імен** для змінних скрипта та параметрів: `$script:VERSION` перезапише `$Version` (PowerShell case-insensitive!)
- Коментуйте складну логіку, уникайте очевидних коментарів

#### Architecture Quirks

- **Немає forward references** — функції мають бути оголошені до виклику (Helpers → Bootstrap → UI → ...)
- `Set-StrictMode -Version 2.0` ламає `[char] * [int]` — використовуйте `[string]` для повторення
- `exit` в інтерактивному режимі вбиває батьківське вікно — тільки `return`
- Hashtable ANSI-кольорів: `$script:ANSI['Red']` (не `$script:ANSI.Red`)
- OS-залежні API ([WindowsIdentity]) обгортайте в `try/catch` для Linux/macOS

---

## Testing

### Verification Commands

```powershell
# Перевірка синтаксису та список усіх 19 інструментів
pwsh -File irmhub.ps1 -List -NoColor

# Тест пошуку (регістронезалежний)
pwsh -File irmhub.ps1 -Search "python" -NoColor

# Тест фільтрації категорій (регістронезалежний — -Category "javascript" працює)
pwsh -File irmhub.ps1 -Category "javascript" -NoColor

# Тест запуску без підтвердження
pwsh -File irmhub.ps1 -Run 6 -AutoConfirm -NoColor
```

### Testing Matrix

| PowerShell | OS | Status |
|:-----------|:---|:-------|
| 5.1 | Windows 10/11 | Required |
| 7.x | Windows 10/11 | Required |
| 7.x | Linux / macOS | Recommended |

### Manual Checklist

- [ ] `-List` показує всі 19 інструментів
- [ ] `-Search` повертає коректні результати (включно з частковим співпадінням)
- [ ] `-Category` фільтрує незалежно від регістру (`JavaScript` = `javascript`)
- [ ] `-Run` виконує інструмент
- [ ] `-AutoConfirm` пропускає підтвердження
- [ ] `-NoColor` вимикає кольори
- [ ] `-Version` показує версію
- [ ] `-Update` перевіряє оновлення
- [ ] ANSI-кольори працюють коректно
- [ ] Попередження про адмін-права для підвищених інструментів
- [ ] Коди виходу правильні (0–7)
- [ ] Пошук без результатів показує повідомлення та паузу 1.2с
- [ ] На Linux/macOS не падає з помилкою (WindowsIdentity тощо)

---

## Tool Addition Criteria

1. **Active Development** — регулярні коміти протягом останніх 6 місяців
2. **Community Trust** — встановлена база користувачів
3. **Open Source** — публічний репозиторій з OSI-ліцензією
4. **HTTPS Only** — URL встановлення тільки `https://`
5. **No Obfuscation** — код має бути читабельним
6. **Relevant Purpose** — CLI-інструменти для розробників, сисадмінів

### Categories

| Category | Description |
|:---------|:------------|
| Package Manager | Scoop, Chocolatey |
| JavaScript | JS-рантайми, менеджери пакетів |
| Python | Python-інструменти |
| Rust | Rust toolchain |
| System | Windows утиліти, оптимізація |
| Shell / UX | Промпти, термінал |
| Media | Spotify та аудіо/відео |
| Dev Tools | Розробницькі утиліти CLI |

---

## Development Setup

```powershell
git clone https://github.com/YOUR-USERNAME/irmhub.git
cd irmhub
git checkout -b feature/my-tool

# Тестування
pwsh -File irmhub.ps1 -List -NoColor

git add .
git commit -m "feat: Add MyTool to catalog"
git push origin feature/my-tool
```

---

## License

MIT — див. [LICENSE](LICENSE).
