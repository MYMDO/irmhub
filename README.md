# IRMHUB — Universal PowerShell Tool Launcher

> **One command to rule them all.**  
> An interactive TUI that aggregates all popular open-source utilities  
> installable via `irm ... | iex` — with full security transparency.

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

---

## What it does

IRMHUB is a PowerShell TUI (Text User Interface) that:

- **Lists** all popular open-source tools installable via `irm | iex`  
- **Categorizes** them (Package Managers, JS, Python, Rust, System, Shell/UX, Media, Dev Tools)  
- **Searches** by name, keyword, or category  
- **Shows the exact command** before any execution  
- **Requires manual confirmation** (`YES`) before running anything  
- **Checks admin rights** and warns if elevation is needed  
- **Runs zero telemetry** — no HTTP calls except to the tool URL you choose  

---

## Security Model

| Guarantee | How |
|-----------|-----|
| TLS 1.2+ enforced | `[Net.ServicePointManager]::SecurityProtocol` set at startup |
| Command preview | Shown in green before any execution |
| Explicit confirmation | User must type `YES` (not Enter) |
| Admin check | Checks `WindowsPrincipal.IsInRole(Administrator)` before admin tools |
| No telemetry | Only outbound request is to the tool you pick |
| Child scope execution | `[scriptblock]::Create()` — no global scope pollution |
| HTTPS only | All catalog URLs start with `https://` |

---

## Included Tools (v1.0)

| # | Tool | Category | Admin? |
|---|------|----------|--------|
| 1 | Scoop | Package Manager | No |
| 2 | Chocolatey | Package Manager | Yes |
| 3 | Bun | JavaScript | No |
| 4 | Deno | JavaScript | No |
| 5 | fnm | JavaScript | No |
| 6 | uv (Astral) | Python | No |
| 7 | Rye | Python | No |
| 8 | Rustup | Rust | No |
| 9 | WinUtil (Chris Titus Tech) | System | Yes |
| 10 | MAS (Microsoft Activation Scripts) | System | Yes |
| 11 | PowerShell 7 | System | Yes |
| 12 | Oh My Posh | Shell / UX | No |
| 13 | Terminal-Icons | Shell / UX | No |
| 14 | Spicetify CLI | Media | No |
| 15 | Spicetify Marketplace | Media | No |
| 16 | Datatools (Caltech) | Dev Tools | No |

---

## How to Deploy (GitHub + GitHub Pages)

### Step 1 — Create the repository

```
gh repo create irmhub --public --description "Universal PowerShell Tool Launcher"
cd irmhub
```

### Step 2 — Add files

```
irmhub.ps1     ← main PowerShell script (the launcher)
index.html     ← landing page (optional, for GitHub Pages)
README.md      ← this file
```

### Step 3 — Enable GitHub Pages

Go to **Settings → Pages → Source → Deploy from branch → main → / (root)**

Your landing page will be live at:  
`https://MYMDO.github.io/irmhub/`

### Step 4 — Run command

```powershell
irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
```

---

## Adding a New Tool

Edit `irmhub.ps1` — add a new `[PSCustomObject]` to the `$CATALOG` array:

```powershell
[PSCustomObject]@{
    Id         = 17                          # next available number
    Name       = 'MyTool'
    Desc       = 'Short description'
    Category   = 'Dev Tools'                 # must match existing or new category
    CatIcon    = '[DEV]'
    Cmd        = 'irm https://example.com/install.ps1 | iex'
    GitHub     = 'https://github.com/org/repo'
    NeedsAdmin = $false
}
```

Then submit a PR — tools will be reviewed for:
- Active GitHub repository with ≥100 stars (or special exception)
- HTTPS-only install URL
- No malware / obfuscation in the install script
- Clearly documented purpose

---

## Requirements

- Windows 10 / 11
- PowerShell 5.1+ (built into Windows) or PowerShell 7+
- Internet connection

---

## Privacy

IRMHUB collects **nothing**. It does not:
- Send analytics, crash reports, or usage stats
- Read or transmit your filesystem, credentials, or environment variables
- Persist any data between sessions
- Phone home

The only network request made is the one to install the tool *you explicitly chose and confirmed*.

---

## License

MIT — see [LICENSE](LICENSE)

---

## Disclaimer

IRMHUB is not affiliated with or endorsed by any of the listed tools.  
Each tool is the property of its respective authors.  
Always review the source code of any script before running it.
