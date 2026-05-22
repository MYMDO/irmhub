# Security Policy

## Supported Versions

| Version | Supported |
|:--------|:----------|
| 1.0.x | :white_check_mark: |
| < 1.0 | :x: |

## Reporting a Vulnerability

1. **Не відкривайте** публічний GitHub issue
2. Напишіть мейнтейнерам або використайте GitHub private vulnerability reporting
3. Додайте детальний опис вразливості
4. Дайте час на оцінку та виправлення (48–72 год)

---

## Security Model

### Transport Layer Security

```powershell
# TLS 1.2+ примусово при старті
[Net.ServicePointManager]::SecurityProtocol =
    [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
```

### HTTPS Enforcement

- Усі URL в каталозі — тільки `https://`
- HTTP URL заборонені
- Валідація сертифікатів увімкнена за замовчуванням

### Command Transparency

Перед виконанням IRMHUB показує:
1. Назву та опис інструменту
2. Повний GitHub URL
3. Точну команду для виконання
4. Чи потрібні права адміністратора
5. Чеклист безпеки

### User Consent

- Потрібно ввести `YES` (case-sensitive, точно)
- Скорочення або синоніми не приймаються
- Enter або будь-що інше — скасування

### Scope Isolation

Інструменти виконуються в ізольованому scriptblock:

```powershell
$sb = [scriptblock]::Create($relaxedCmd)
& $sb
```

Це запобігає:
- Забрудненню глобального scope
- Витоку змінних
- Перевизначенню функцій

### Privilege Awareness

Інструменти, що потребують адмін-прав, позначені `Admin = $true` в каталозі.
IRMHUB попереджає перед запуском, якщо:
- Інструмент вимагає адмін-прав
- Поточна сесія не підвищена

### Cross-Platform Safety

На Linux/macOS OS-залежні API (наприклад, `[Security.Principal.WindowsIdentity]::GetCurrent()`) обгорнуті в `try/catch` і безпечно повертають `$false`.

---

## Known Limitations

### User Responsibility

IRMHUB — **запускач**, який агрегує інструменти. Безпека залежить від:
1. Мейнтейнерів кожного інструменту
2. Вашої пильності — перевіряйте команди перед виконанням
3. Мережевої безпеки — ваш TLS/HTTPS

### What IRMHUB Does NOT Do

- Верифікує цілісність інструментів після встановлення
- Сканує сторонні скрипти на malware
- Надає пісочницю для виконання
- Моніторить встановлене ПЗ
- Сповіщає про оновлення встановлених інструментів

---

## Best Practices

### For Users

1. Завжди перевіряйте URL перед `irm | iex`
2. Оглядайте код перед першим запуском
3. Використовуйте `-List` для попереднього перегляду
4. Повідомляйте про підозрілі інструменти в issues
5. Оновлюйте PowerShell до останньої версії

### For Tool Maintainers

1. Використовуйте HTTPS для всіх URL
2. Підписуйте релізи
3. Надавайте контрольні суми (checksums)
4. Додавайте `security.txt` в корінь репозиторію

---

## Security Checklist (додавання інструменту)

- [ ] Публічний репозиторій
- [ ] HTTPS URL для встановлення
- [ ] Без обфускації
- [ ] Без телеметрії
- [ ] Чиста історія безпеки

---

*Безпека — спільна відповідальність. Будьте пильні!*
