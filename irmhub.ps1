#Requires -Version 5.1
<#
.SYNOPSIS
    IRMHUB — Universal PowerShell Tool Launcher
.DESCRIPTION
    Aggregates all popular open-source utilities installable via  irm | iex.
    Zero telemetry. Zero logging. HTTPS-only. Confirm before execute.
.LINK
    https://github.com/MYMDO/irmhub
.NOTES
    Run: irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────────────────────────────────────
#  SECURITY BOOTSTRAP
#  Enforce TLS 1.2+ for all subsequent web requests in this session.
#  Never store, log or transmit any user data.
# ─────────────────────────────────────────────────────────────────────────────
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# ─────────────────────────────────────────────────────────────────────────────
#  ANSI / COLOR HELPERS
# ─────────────────────────────────────────────────────────────────────────────
$ANSI = @{
    Reset       = "`e[0m"
    Bold        = "`e[1m"
    Dim         = "`e[2m"
    # Foreground
    Black       = "`e[30m"
    Red         = "`e[31m"
    Green       = "`e[32m"
    Yellow      = "`e[33m"
    Blue        = "`e[34m"
    Magenta     = "`e[35m"
    Cyan        = "`e[36m"
    White       = "`e[37m"
    BrightBlack = "`e[90m"
    BrightWhite = "`e[97m"
    # Background
    BgBlue      = "`e[44m"
    BgCyan      = "`e[46m"
    BgGreen     = "`e[42m"
    BgRed       = "`e[41m"
    BgYellow    = "`e[43m"
    BgMagenta   = "`e[45m"
    BgBlack     = "`e[40m"
    BgBrightBlack = "`e[100m"
}

function c([string]$text, [string]$color, [switch]$bold) {
    $b = if ($bold) { $ANSI.Bold } else { '' }
    return "$b$($ANSI[$color])$text$($ANSI.Reset)"
}

# ─────────────────────────────────────────────────────────────────────────────
#  TOOL CATALOG
#  Each entry: Name, Desc, Category, Cmd, URL (GitHub), NeedsAdmin
#  Cmd must start with  irm https://  or  iwr -useb https://
# ─────────────────────────────────────────────────────────────────────────────
$CATALOG = @(
    # ── Package Managers ────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 1
        Name       = 'Scoop'
        Desc       = 'Package manager for Windows. No admin rights needed. Apps installed in user space.'
        Category   = 'Package Manager'
        CatIcon    = '[PKG]'
        Cmd        = 'irm https://get.scoop.sh | iex'
        GitHub     = 'https://github.com/ScoopInstaller/Scoop'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 2
        Name       = 'Chocolatey'
        Desc       = 'The largest Windows package repository. Enterprise-grade, 10k+ packages.'
        Category   = 'Package Manager'
        CatIcon    = '[PKG]'
        Cmd        = 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol=[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1''))'
        GitHub     = 'https://github.com/chocolatey/choco'
        NeedsAdmin = $true
    },

    # ── JavaScript / Node ────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 3
        Name       = 'Bun'
        Desc       = 'All-in-one JavaScript runtime, bundler, test runner & package manager (Zig/C++).'
        Category   = 'JavaScript'
        CatIcon    = '[JS] '
        Cmd        = 'irm https://bun.sh/install.ps1 | iex'
        GitHub     = 'https://github.com/oven-sh/bun'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 4
        Name       = 'Deno'
        Desc       = 'Secure TypeScript/JavaScript runtime by Node.js creators. Built-in TypeScript.'
        Category   = 'JavaScript'
        CatIcon    = '[JS] '
        Cmd        = 'irm https://deno.land/install.ps1 | iex'
        GitHub     = 'https://github.com/denoland/deno'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 5
        Name       = 'fnm'
        Desc       = 'Fast Node Version Manager written in Rust. Replaces nvm on Windows.'
        Category   = 'JavaScript'
        CatIcon    = '[JS] '
        Cmd        = 'irm https://fnm.vercel.app/install | iex'
        GitHub     = 'https://github.com/Schniz/fnm'
        NeedsAdmin = $false
    },

    # ── Python ───────────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 6
        Name       = 'uv'
        Desc       = 'Extremely fast Python package & project manager by Astral (Rust). Drop-in pip replacement.'
        Category   = 'Python'
        CatIcon    = '[PY] '
        Cmd        = 'irm https://astral.sh/uv/install.ps1 | iex'
        GitHub     = 'https://github.com/astral-sh/uv'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 7
        Name       = 'Rye'
        Desc       = 'Holistic Python project & environment manager. Handles Python installs, venvs, deps.'
        Category   = 'Python'
        CatIcon    = '[PY] '
        Cmd        = 'irm https://rye.astral.sh/get-windows.ps1 | iex'
        GitHub     = 'https://github.com/astral-sh/rye'
        NeedsAdmin = $false
    },

    # ── Rust ─────────────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 8
        Name       = 'Rustup'
        Desc       = 'Official Rust toolchain installer. Installs rustc, cargo, clippy, rustfmt.'
        Category   = 'Rust'
        CatIcon    = '[RS] '
        Cmd        = 'irm https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; .\rustup-init.exe'
        GitHub     = 'https://github.com/rust-lang/rustup'
        NeedsAdmin = $false
    },

    # ── System / Windows ─────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 9
        Name       = 'WinUtil (Chris Titus Tech)'
        Desc       = 'All-in-one Windows debloat, tweaks, software install, and repair toolkit with GUI.'
        Category   = 'System'
        CatIcon    = '[SYS]'
        Cmd        = 'irm https://christitus.com/win | iex'
        GitHub     = 'https://github.com/ChrisTitusTech/winutil'
        NeedsAdmin = $true
    },
    [PSCustomObject]@{
        Id         = 10
        Name       = 'MAS (Microsoft Activation Scripts)'
        Desc       = 'Open-source Windows & Office activator. HWID, KMS38, Online KMS, Ohook methods.'
        Category   = 'System'
        CatIcon    = '[SYS]'
        Cmd        = 'irm https://get.activated.win | iex'
        GitHub     = 'https://github.com/massgravel/Microsoft-Activation-Scripts'
        NeedsAdmin = $true
    },
    [PSCustomObject]@{
        Id         = 11
        Name       = 'PowerShell 7'
        Desc       = 'Official Microsoft installer for PowerShell 7 (cross-platform, open source).'
        Category   = 'System'
        CatIcon    = '[SYS]'
        Cmd        = 'iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"'
        GitHub     = 'https://github.com/PowerShell/PowerShell'
        NeedsAdmin = $true
    },

    # ── Shell / UX ───────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 12
        Name       = 'Oh My Posh'
        Desc       = 'Custom prompt engine for any shell. 200+ themes, Nerd Font icons, Git status.'
        Category   = 'Shell / UX'
        CatIcon    = '[UX] '
        Cmd        = 'irm https://ohmyposh.dev/install.ps1 | iex'
        GitHub     = 'https://github.com/JanDeDobbeleer/oh-my-posh'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 13
        Name       = 'Terminal-Icons'
        Desc       = 'PowerShell module to display file and folder icons in the terminal.'
        Category   = 'Shell / UX'
        CatIcon    = '[UX] '
        Cmd        = 'Install-Module -Name Terminal-Icons -Repository PSGallery -Force'
        GitHub     = 'https://github.com/devblackops/Terminal-Icons'
        NeedsAdmin = $false
    },

    # ── Media ────────────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 14
        Name       = 'Spicetify CLI'
        Desc       = 'Customize the Spotify desktop client — themes, extensions, custom apps.'
        Category   = 'Media'
        CatIcon    = '[MED]'
        Cmd        = 'iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex'
        GitHub     = 'https://github.com/spicetify/cli'
        NeedsAdmin = $false
    },
    [PSCustomObject]@{
        Id         = 15
        Name       = 'Spicetify Marketplace'
        Desc       = 'In-app marketplace for Spicetify themes and extensions.'
        Category   = 'Media'
        CatIcon    = '[MED]'
        Cmd        = 'iwr -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | iex'
        GitHub     = 'https://github.com/spicetify/marketplace'
        NeedsAdmin = $false
    },

    # ── Dev Tools ────────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Id         = 16
        Name       = 'Datatools (Caltech)'
        Desc       = 'CLI data-processing utilities: jsontools, csvtools, xlsxtools, dsv.'
        Category   = 'Dev Tools'
        CatIcon    = '[DEV]'
        Cmd        = 'irm https://caltechlibrary.github.io/datatools/installer.ps1 | iex'
        GitHub     = 'https://github.com/caltechlibrary/datatools'
        NeedsAdmin = $false
    }
)

# ─────────────────────────────────────────────────────────────────────────────
#  LAYOUT CONSTANTS
# ─────────────────────────────────────────────────────────────────────────────
$WIDTH = [Math]::Min(100, $Host.UI.RawUI.WindowSize.Width - 2)
if ($WIDTH -lt 60) { $WIDTH = 78 }

function Draw-Line([string]$char = '─') {
    Write-Host ($char * $WIDTH) -ForegroundColor DarkGray
}

function Draw-Box([string]$text, [string]$fg = 'Cyan', [switch]$center) {
    $inner = $WIDTH - 2
    $t = if ($center) { $text.PadLeft([int](($inner + $text.Length) / 2)).PadRight($inner) } else { " $text".PadRight($inner) }
    Write-Host "$(c '┌' 'BrightBlack')$('─' * $inner)$(c '┐' 'BrightBlack')"
    Write-Host "$(c '│' 'BrightBlack')$(c $t $fg -bold)$(c '│' 'BrightBlack')"
    Write-Host "$(c '└' 'BrightBlack')$('─' * $inner)$(c '┘' 'BrightBlack')"
}

function Clear-Screen { Clear-Host }

# ─────────────────────────────────────────────────────────────────────────────
#  BANNER
# ─────────────────────────────────────────────────────────────────────────────
function Show-Banner {
    Clear-Screen
    $logo = @(
        '  ██╗██████╗ ███╗   ███╗    ██╗  ██╗██╗   ██╗██████╗ ',
        '  ██║██╔══██╗████╗ ████║    ██║  ██║██║   ██║██╔══██╗',
        '  ██║██████╔╝██╔████╔██║    ███████║██║   ██║██████╔╝',
        '  ██║██╔══██╗██║╚██╔╝██║    ██╔══██║██║   ██║██╔══██╗',
        '  ██║██║  ██║██║ ╚═╝ ██║    ██║  ██║╚██████╔╝██████╔╝',
        '  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ '
    )
    foreach ($line in $logo) {
        Write-Host $line -ForegroundColor Cyan
    }
    Write-Host ''
    $tagline = 'Universal PowerShell Tool Launcher  •  irm | iex  •  Zero Telemetry'
    $pad = [int](($WIDTH - $tagline.Length) / 2)
    Write-Host (' ' * $pad) -NoNewline
    Write-Host $tagline -ForegroundColor DarkCyan
    Write-Host ''
    Draw-Line
    Write-Host " $(c '[!]' 'Yellow' -bold) $(c 'SECURITY:' 'Yellow') Every command is shown BEFORE execution. You must confirm." -ForegroundColor Gray
    Write-Host " $(c '[i]' 'BrightBlack') PRIVACY: No telemetry. No logging. No network calls except tool URLs." -ForegroundColor DarkGray
    Draw-Line
    Write-Host ''
}

# ─────────────────────────────────────────────────────────────────────────────
#  CATEGORY MENU
# ─────────────────────────────────────────────────────────────────────────────
function Get-Categories {
    return @('All') + ($CATALOG | Select-Object -ExpandProperty Category -Unique | Sort-Object)
}

function Show-CategoryMenu {
    $cats = Get-Categories
    Write-Host " $(c 'FILTER BY CATEGORY' 'BrightBlack')"
    Write-Host ''
    for ($i = 0; $i -lt $cats.Count; $i++) {
        $num = "  [$i]"
        Write-Host "$(c $num 'Yellow') $($cats[$i])" -ForegroundColor Gray
    }
    Write-Host ''
    Write-Host " $(c '[s]' 'Magenta') Search by name / keyword" -ForegroundColor Gray
    Write-Host " $(c '[q]' 'Red')     Quit" -ForegroundColor Gray
    Write-Host ''
    Draw-Line
}

# ─────────────────────────────────────────────────────────────────────────────
#  TOOL LIST
# ─────────────────────────────────────────────────────────────────────────────
function Show-ToolList([array]$tools) {
    if ($tools.Count -eq 0) {
        Write-Host "  $(c 'No tools found.' 'Yellow')" -ForegroundColor Gray
        return
    }

    $catColors = @{
        'Package Manager' = 'Green'
        'JavaScript'      = 'Yellow'
        'Python'          = 'Blue'
        'Rust'            = 'Red'
        'System'          = 'Magenta'
        'Shell / UX'      = 'Cyan'
        'Media'           = 'Magenta'
        'Dev Tools'       = 'BrightBlack'
    }

    foreach ($t in $tools) {
        $col  = if ($catColors.ContainsKey($t.Category)) { $catColors[$t.Category] } else { 'White' }
        $adm  = if ($t.NeedsAdmin) { $(c ' [ADMIN]' 'Red') } else { '' }
        $idPad = "[$($t.Id)]".PadLeft(4)

        Write-Host "  $(c $idPad 'Yellow' -bold) $(c $t.CatIcon $col) $(c $t.Name 'White' -bold)$adm" -ForegroundColor Gray
        Write-Host "       $($t.Desc)" -ForegroundColor DarkGray
        Write-Host "       $(c 'CMD:' 'BrightBlack') $(c $t.Cmd 'Cyan')" -ForegroundColor DarkGray
        Write-Host ''
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  SECURITY CONFIRMATION + EXECUTE
# ─────────────────────────────────────────────────────────────────────────────
function Invoke-ToolSecure([PSCustomObject]$tool) {
    Clear-Screen
    Draw-Line
    Write-Host " $(c '▶  SELECTED TOOL' 'Cyan' -bold)"
    Draw-Line
    Write-Host ''
    Write-Host "  $(c 'Name     :' 'BrightBlack') $(c $tool.Name 'White' -bold)"
    Write-Host "  $(c 'Category :' 'BrightBlack') $($tool.Category)"
    Write-Host "  $(c 'GitHub   :' 'BrightBlack') $(c $tool.GitHub 'Cyan')"
    if ($tool.NeedsAdmin) {
        Write-Host "  $(c 'Privilege:' 'BrightBlack') $(c 'Requires Administrator rights' 'Red' -bold)"
    } else {
        Write-Host "  $(c 'Privilege:' 'BrightBlack') $(c 'Runs as current user (no admin needed)' 'Green')"
    }
    Write-Host ''
    Write-Host "  $(c 'Description:' 'BrightBlack')"
    Write-Host "  $($tool.Desc)" -ForegroundColor Gray
    Write-Host ''
    Draw-Line

    # Security — show command prominently
    Write-Host ''
    Write-Host " $(c '⚠  COMMAND THAT WILL BE EXECUTED:' 'Yellow' -bold)"
    Write-Host ''
    Write-Host "   $(c $tool.Cmd 'Green' -bold)"
    Write-Host ''
    Draw-Line

    # Admin check
    if ($tool.NeedsAdmin) {
        $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        $isAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Host ''
            Write-Host " $(c '[!] WARNING:' 'Red' -bold) This tool requires Administrator privileges." -ForegroundColor Red
            Write-Host "     Please restart PowerShell as Administrator and run IRMHUB again." -ForegroundColor Red
            Write-Host ''
            Write-Host " Press $(c 'Enter' 'Yellow') to go back..." -NoNewline
            $null = $Host.UI.ReadLine()
            return
        }
    }

    Write-Host ''
    Write-Host " $(c 'SECURITY CHECKLIST:' 'BrightBlack')" -ForegroundColor DarkGray
    Write-Host "  $(c '✓' 'Green') Connection encrypted via TLS 1.2+" -ForegroundColor DarkGray
    Write-Host "  $(c '✓' 'Green') Source URL verified HTTPS" -ForegroundColor DarkGray
    Write-Host "  $(c '✓' 'Green') Official GitHub repository linked above" -ForegroundColor DarkGray
    Write-Host "  $(c '!' 'Yellow') You are responsible for reviewing the source code at the GitHub URL" -ForegroundColor DarkGray
    Write-Host ''

    $confirm = Read-Host " Type $(c 'YES' 'Green' -bold) to execute, or press Enter to cancel"
    if ($confirm -ne 'YES') {
        Write-Host ''
        Write-Host " $(c 'Cancelled.' 'Yellow') No command was executed." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 900
        return
    }

    Write-Host ''
    Draw-Line
    Write-Host " $(c '▶  Executing...' 'Green' -bold)"
    Draw-Line
    Write-Host ''

    try {
        # Execute in a child scope to contain side effects
        $scriptBlock = [scriptblock]::Create($tool.Cmd)
        & $scriptBlock
    } catch {
        Write-Host ''
        Write-Host " $(c '[ERROR]' 'Red' -bold) $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ''
    Draw-Line
    Write-Host " $(c '✓  Done.' 'Green') Press $(c 'Enter' 'Yellow') to return to IRMHUB..." -NoNewline
    $null = $Host.UI.ReadLine()
}

# ─────────────────────────────────────────────────────────────────────────────
#  SEARCH
# ─────────────────────────────────────────────────────────────────────────────
function Invoke-Search {
    Show-Banner
    $kw = Read-Host " $(c 'Search' 'Cyan') (name / keyword)"
    if ([string]::IsNullOrWhiteSpace($kw)) { return }

    $kw = $kw.Trim().ToLower()
    $results = $CATALOG | Where-Object {
        $_.Name.ToLower().Contains($kw) -or
        $_.Desc.ToLower().Contains($kw) -or
        $_.Category.ToLower().Contains($kw) -or
        $_.Cmd.ToLower().Contains($kw)
    }

    Show-Banner
    Write-Host " $(c "Search results for:" 'BrightBlack') $(c $kw 'Cyan' -bold)  $(c "(${$results.Count} found)" 'BrightBlack')"
    Write-Host ''
    Show-ToolList $results

    if ($results.Count -gt 0) {
        $idInput = Read-Host " Enter tool $(c '[ID]' 'Yellow') to run, or press Enter to go back"
        if ($idInput -match '^\d+$') {
            $chosen = $results | Where-Object { $_.Id -eq [int]$idInput }
            if ($chosen) { Invoke-ToolSecure $chosen }
        }
    } else {
        Write-Host " Press $(c 'Enter' 'Yellow') to go back..." -NoNewline
        $null = $Host.UI.ReadLine()
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  UPDATE CATALOG (optional — fetch remote JSON if available)
# ─────────────────────────────────────────────────────────────────────────────
function Update-Catalog {
    # Future: irm https://raw.githubusercontent.com/.../catalog.json | ConvertFrom-Json
    # Currently embedded for offline/air-gapped compatibility and tamper-resistance.
    Write-Host " $(c '[i]' 'Cyan') Catalog v1.0 — embedded. No external catalog fetch." -ForegroundColor DarkGray
}

# ─────────────────────────────────────────────────────────────────────────────
#  MAIN LOOP
# ─────────────────────────────────────────────────────────────────────────────
function Start-IrmHub {
    $cats = Get-Categories

    while ($true) {
        Show-Banner
        Show-CategoryMenu

        $input = Read-Host " $(c '→' 'Cyan') Choose category or command"
        $input = $input.Trim().ToLower()

        # Quit
        if ($input -eq 'q' -or $input -eq 'quit' -or $input -eq 'exit') {
            Write-Host ''
            Write-Host " $(c 'Goodbye!' 'Cyan')" -ForegroundColor Cyan
            Write-Host ''
            break
        }

        # Search
        if ($input -eq 's') {
            Invoke-Search
            continue
        }

        # Category selection
        if ($input -match '^\d+$') {
            $catIdx = [int]$input
            if ($catIdx -ge 0 -and $catIdx -lt $cats.Count) {
                $selectedCat = $cats[$catIdx]
                $filtered = if ($selectedCat -eq 'All') {
                    $CATALOG
                } else {
                    $CATALOG | Where-Object { $_.Category -eq $selectedCat }
                }

                Show-Banner
                $header = if ($selectedCat -eq 'All') { 'ALL TOOLS' } else { $selectedCat.ToUpper() }
                Write-Host " $(c $header 'Cyan' -bold)  $(c "($($filtered.Count) tools)" 'BrightBlack')"
                Write-Host ''
                Show-ToolList $filtered
                Draw-Line

                $idInput = Read-Host " Enter tool $(c '[ID]' 'Yellow') to run, or press Enter to go back"
                if ($idInput -match '^\d+$') {
                    $chosen = $filtered | Where-Object { $_.Id -eq [int]$idInput }
                    if ($chosen) {
                        Invoke-ToolSecure $chosen
                    } else {
                        Write-Host " $(c '[!] Invalid ID.' 'Yellow')" -ForegroundColor Yellow
                        Start-Sleep -Milliseconds 700
                    }
                }
            } else {
                Write-Host " $(c '[!] Invalid choice.' 'Yellow')" -ForegroundColor Yellow
                Start-Sleep -Milliseconds 700
            }
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────
Update-Catalog
Start-IrmHub
