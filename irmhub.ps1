#Requires -Version 5.1
<#
.SYNOPSIS
    IRMHUB - Universal PowerShell Tool Launcher
.DESCRIPTION
    Aggregates all popular open-source utilities installable via irm | iex.
    Zero telemetry. Zero logging. HTTPS-only. Confirm before execute.
.LINK
    https://github.com/MYMDO/irmhub
.NOTES
    Run: irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# TLS BOOTSTRAP
$_tls = [Net.SecurityProtocolType]::Tls12
try { $_tls = $_tls -bor [Net.SecurityProtocolType]::Tls13 } catch {}
[Net.ServicePointManager]::SecurityProtocol = $_tls
Remove-Variable _tls

# ENABLE VirtualTerminalProcessing for ANSI on PS5.1
$ESC = [char]27
try {
    $sig = '[DllImport("kernel32.dll")]public static extern bool SetConsoleMode(IntPtr h,int m);[DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int n);[DllImport("kernel32.dll")]public static extern bool GetConsoleMode(IntPtr h,out int m);'
    $k32 = Add-Type -MemberDefinition $sig -Name K32 -Namespace VT -PassThru -ErrorAction Stop
    $hOut = $k32::GetStdHandle(-11)
    $mode = 0
    $null = $k32::GetConsoleMode($hOut, [ref]$mode)
    $null = $k32::SetConsoleMode($hOut, ($mode -bor 4))
} catch {}

# ANSI COLORS — [char]27 works on PS 5.1, 7.x, Windows Terminal
$ANSI = @{
    Reset        = "$ESC[0m"
    Bold         = "$ESC[1m"
    Dim          = "$ESC[2m"
    Black        = "$ESC[30m"
    Red          = "$ESC[31m"
    Green        = "$ESC[32m"
    Yellow       = "$ESC[33m"
    Blue         = "$ESC[34m"
    Magenta      = "$ESC[35m"
    Cyan         = "$ESC[36m"
    White        = "$ESC[37m"
    BrightBlack  = "$ESC[90m"
    BrightWhite  = "$ESC[97m"
    BgBlue       = "$ESC[44m"
    BgCyan       = "$ESC[46m"
    BgGreen      = "$ESC[42m"
    BgRed        = "$ESC[41m"
    BgYellow     = "$ESC[43m"
    BgMagenta    = "$ESC[45m"
    BgBlack      = "$ESC[40m"
    BgBrightBlack= "$ESC[100m"
}

function c([string]$text, [string]$color, [switch]$bold) {
    $b = if ($bold) { $ANSI.Bold } else { '' }
    return "$b$($ANSI[$color])$text$($ANSI.Reset)"
}

# TOOL CATALOG
$CATALOG = @(
    [PSCustomObject]@{ Id=1;  Name='Scoop';                  Desc='Package manager for Windows. No admin needed. User-space installs.';                  Category='Package Manager'; CatIcon='[PKG]'; Cmd='irm https://get.scoop.sh | iex';                                                                                                                                           GitHub='https://github.com/ScoopInstaller/Scoop';                  NeedsAdmin=$false },
    [PSCustomObject]@{ Id=2;  Name='Chocolatey';             Desc='Largest Windows package repo. 10k+ packages. Enterprise-grade.';                      Category='Package Manager'; CatIcon='[PKG]'; Cmd='Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1''))'; GitHub='https://github.com/chocolatey/choco';                       NeedsAdmin=$true  },
    [PSCustomObject]@{ Id=3;  Name='Bun';                    Desc='All-in-one JS runtime, bundler, test runner and package manager.';                    Category='JavaScript';      CatIcon='[JS] '; Cmd='irm https://bun.sh/install.ps1 | iex';                                                                                                                                    GitHub='https://github.com/oven-sh/bun';                           NeedsAdmin=$false },
    [PSCustomObject]@{ Id=4;  Name='Deno';                   Desc='Secure TypeScript/JS runtime by Node.js creators. Built-in TS.';                      Category='JavaScript';      CatIcon='[JS] '; Cmd='irm https://deno.land/install.ps1 | iex';                                                                                                                               GitHub='https://github.com/denoland/deno';                         NeedsAdmin=$false },
    [PSCustomObject]@{ Id=5;  Name='fnm';                    Desc='Fast Node Version Manager written in Rust. Replaces nvm on Windows.';                 Category='JavaScript';      CatIcon='[JS] '; Cmd='irm https://fnm.vercel.app/install | iex';                                                                                                                              GitHub='https://github.com/Schniz/fnm';                            NeedsAdmin=$false },
    [PSCustomObject]@{ Id=6;  Name='uv';                     Desc='Ultra-fast Python package and project manager by Astral (Rust).';                     Category='Python';          CatIcon='[PY] '; Cmd='irm https://astral.sh/uv/install.ps1 | iex';                                                                                                                            GitHub='https://github.com/astral-sh/uv';                          NeedsAdmin=$false },
    [PSCustomObject]@{ Id=7;  Name='Rye';                    Desc='Holistic Python project and environment manager. Handles venvs.';                     Category='Python';          CatIcon='[PY] '; Cmd='irm https://rye.astral.sh/get-windows.ps1 | iex';                                                                                                                       GitHub='https://github.com/astral-sh/rye';                         NeedsAdmin=$false },
    [PSCustomObject]@{ Id=8;  Name='Rustup';                 Desc='Official Rust toolchain installer. rustc, cargo, clippy, rustfmt.';                   Category='Rust';            CatIcon='[RS] '; Cmd='irm https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; .\rustup-init.exe';                                                                                          GitHub='https://github.com/rust-lang/rustup';                      NeedsAdmin=$false },
    [PSCustomObject]@{ Id=9;  Name='WinUtil (Chris Titus)';  Desc='All-in-one Windows debloat, tweaks, software install GUI.';                           Category='System';          CatIcon='[SYS]'; Cmd='irm https://christitus.com/win | iex';                                                                                                                                   GitHub='https://github.com/ChrisTitusTech/winutil';                NeedsAdmin=$true  },
    [PSCustomObject]@{ Id=10; Name='MAS (Activation Scripts)';Desc='Open-source Windows and Office activator. HWID, KMS38, Online KMS.';                Category='System';          CatIcon='[SYS]'; Cmd='irm https://get.activated.win | iex';                                                                                                                                    GitHub='https://github.com/massgravel/Microsoft-Activation-Scripts';NeedsAdmin=$true  },
    [PSCustomObject]@{ Id=11; Name='PowerShell 7';           Desc='Official Microsoft installer for PowerShell 7 (cross-platform).';                     Category='System';          CatIcon='[SYS]'; Cmd='iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"';                                                                                                     GitHub='https://github.com/PowerShell/PowerShell';                 NeedsAdmin=$true  },
    [PSCustomObject]@{ Id=12; Name='Oh My Posh';             Desc='Custom prompt engine for any shell. 200+ themes, Nerd Font icons.';                   Category='Shell / UX';      CatIcon='[UX] '; Cmd='irm https://ohmyposh.dev/install.ps1 | iex';                                                                                                                            GitHub='https://github.com/JanDeDobbeleer/oh-my-posh';             NeedsAdmin=$false },
    [PSCustomObject]@{ Id=13; Name='Terminal-Icons';         Desc='PowerShell module to show file and folder icons in the terminal.';                    Category='Shell / UX';      CatIcon='[UX] '; Cmd='Install-Module -Name Terminal-Icons -Repository PSGallery -Force';                                                                                                       GitHub='https://github.com/devblackops/Terminal-Icons';            NeedsAdmin=$false },
    [PSCustomObject]@{ Id=14; Name='Spicetify CLI';          Desc='Customize the Spotify desktop client with themes and extensions.';                    Category='Media';           CatIcon='[MED]'; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex';                                                                                      GitHub='https://github.com/spicetify/cli';                         NeedsAdmin=$false },
    [PSCustomObject]@{ Id=15; Name='Spicetify Marketplace';  Desc='In-app marketplace for Spicetify themes and extensions.';                             Category='Media';           CatIcon='[MED]'; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | iex';                                                                  GitHub='https://github.com/spicetify/marketplace';                 NeedsAdmin=$false },
    [PSCustomObject]@{ Id=16; Name='Datatools (Caltech)';    Desc='CLI tools for JSON, CSV, XLSX and DSV data processing.';                              Category='Dev Tools';       CatIcon='[DEV]'; Cmd='irm https://caltechlibrary.github.io/datatools/installer.ps1 | iex';                                                                                                    GitHub='https://github.com/caltechlibrary/datatools';              NeedsAdmin=$false }
)

# LAYOUT
$WIDTH = [Math]::Min(100, $Host.UI.RawUI.WindowSize.Width - 2)
if ($WIDTH -lt 60) { $WIDTH = 78 }

function Draw-Line([string]$char = '-') {
    Write-Host ($char * $WIDTH) -ForegroundColor DarkGray
}

function Clear-Screen { Clear-Host }

# BANNER
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
    foreach ($line in $logo) { Write-Host $line -ForegroundColor Cyan }
    Write-Host ''
    $tag = 'Universal PowerShell Tool Launcher  *  irm | iex  *  Zero Telemetry'
    $pad = [int](($WIDTH - $tag.Length) / 2)
    Write-Host (' ' * [Math]::Max(0,$pad)) -NoNewline
    Write-Host $tag -ForegroundColor DarkCyan
    Write-Host ''
    Draw-Line
    Write-Host " $(c '[!]' 'Yellow' -bold) $(c 'SECURITY:' 'Yellow') Every command is shown BEFORE execution. You must confirm." -ForegroundColor Gray
    Write-Host " $(c '[i]' 'BrightBlack') PRIVACY: No telemetry. No logging. No network calls except tool URLs." -ForegroundColor DarkGray
    Draw-Line
    Write-Host ''
}

# CATEGORIES
function Get-Categories { return @('All') + ($CATALOG | Select-Object -ExpandProperty Category -Unique | Sort-Object) }

function Show-CategoryMenu {
    $cats = Get-Categories
    Write-Host " $(c 'FILTER BY CATEGORY' 'BrightBlack')"
    Write-Host ''
    for ($i = 0; $i -lt $cats.Count; $i++) {
        Write-Host "  $(c "[$i]" 'Yellow') $($cats[$i])" -ForegroundColor Gray
    }
    Write-Host ''
    Write-Host "  $(c '[s]' 'Magenta') Search by name / keyword" -ForegroundColor Gray
    Write-Host "  $(c '[q]' 'Red')     Quit" -ForegroundColor Gray
    Write-Host ''
    Draw-Line
}

# TOOL LIST
function Show-ToolList([array]$tools) {
    if ($tools.Count -eq 0) { Write-Host "  $(c 'No tools found.' 'Yellow')"; return }
    $catColors = @{
        'Package Manager'='Green'; 'JavaScript'='Yellow'; 'Python'='Blue'
        'Rust'='Red'; 'System'='Magenta'; 'Shell / UX'='Cyan'; 'Media'='Magenta'; 'Dev Tools'='BrightBlack'
    }
    foreach ($t in $tools) {
        $col = if ($catColors.ContainsKey($t.Category)) { $catColors[$t.Category] } else { 'White' }
        $adm = if ($t.NeedsAdmin) { $(c ' [ADMIN]' 'Red') } else { '' }
        Write-Host "  $(c "[$($t.Id)]" 'Yellow' -bold) $(c $t.CatIcon $col) $(c $t.Name 'White' -bold)$adm"
        Write-Host "       $($t.Desc)" -ForegroundColor DarkGray
        Write-Host "       $(c 'CMD:' 'BrightBlack') $(c $t.Cmd 'Cyan')" -ForegroundColor DarkGray
        Write-Host ''
    }
}

# SECURITY CONFIRM + EXECUTE
function Invoke-ToolSecure([PSCustomObject]$tool) {
    Clear-Screen
    Draw-Line
    Write-Host " $(c '> SELECTED TOOL' 'Cyan' -bold)"
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
    Write-Host ''
    Write-Host " $(c '! COMMAND THAT WILL BE EXECUTED:' 'Yellow' -bold)"
    Write-Host ''
    Write-Host "   $(c $tool.Cmd 'Green' -bold)"
    Write-Host ''
    Draw-Line

    if ($tool.NeedsAdmin) {
        $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $pr  = [Security.Principal.WindowsPrincipal]$id
        $adm = $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $adm) {
            Write-Host ''
            Write-Host " $(c '[!] WARNING:' 'Red' -bold) This tool requires Administrator privileges." -ForegroundColor Red
            Write-Host "     Restart PowerShell as Administrator and run IRMHUB again." -ForegroundColor Red
            Write-Host ''
            Write-Host " Press $(c 'Enter' 'Yellow') to go back..." -NoNewline
            $null = $Host.UI.ReadLine()
            return
        }
    }

    Write-Host ''
    Write-Host " $(c 'SECURITY CHECKLIST:' 'BrightBlack')" -ForegroundColor DarkGray
    Write-Host "  $(c 'OK' 'Green') TLS 1.2+ enforced"              -ForegroundColor DarkGray
    Write-Host "  $(c 'OK' 'Green') HTTPS source URL"               -ForegroundColor DarkGray
    Write-Host "  $(c 'OK' 'Green') Official GitHub repo linked"    -ForegroundColor DarkGray
    Write-Host "  $(c '!!' 'Yellow') Review source code at GitHub before trusting" -ForegroundColor DarkGray
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
    Write-Host " $(c '> Executing...' 'Green' -bold)"
    Draw-Line
    Write-Host ''

    try {
        $sb = [scriptblock]::Create($tool.Cmd)
        & $sb
    } catch {
        Write-Host ''
        Write-Host " $(c '[ERROR]' 'Red' -bold) $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ''
    Draw-Line
    Write-Host " $(c 'Done.' 'Green') Press $(c 'Enter' 'Yellow') to return to IRMHUB..." -NoNewline
    $null = $Host.UI.ReadLine()
}

# SEARCH
function Invoke-Search {
    Show-Banner
    $kw = Read-Host " $(c 'Search' 'Cyan') (name / keyword)"
    if ([string]::IsNullOrWhiteSpace($kw)) { return }
    $kw = $kw.Trim().ToLower()
    $results = @($CATALOG | Where-Object {
        $_.Name.ToLower().Contains($kw) -or $_.Desc.ToLower().Contains($kw) -or
        $_.Category.ToLower().Contains($kw) -or $_.Cmd.ToLower().Contains($kw)
    })
    Show-Banner
    Write-Host " $(c 'Results for:' 'BrightBlack') $(c $kw 'Cyan' -bold)  $(c "($($results.Count) found)" 'BrightBlack')"
    Write-Host ''
    Show-ToolList $results
    if ($results.Count -gt 0) {
        $idInput = Read-Host " Enter tool $(c '[ID]' 'Yellow') to run, or Enter to go back"
        if ($idInput -match '^\d+$') {
            $chosen = $results | Where-Object { $_.Id -eq [int]$idInput }
            if ($chosen) { Invoke-ToolSecure $chosen }
        }
    } else {
        Write-Host " Press $(c 'Enter' 'Yellow') to go back..." -NoNewline
        $null = $Host.UI.ReadLine()
    }
}

# MAIN LOOP
function Start-IrmHub {
    $cats = Get-Categories
    while ($true) {
        Show-Banner
        Show-CategoryMenu
        $inp = (Read-Host " $(c '->' 'Cyan') Choose category or command").Trim().ToLower()

        if ($inp -eq 'q' -or $inp -eq 'quit' -or $inp -eq 'exit') {
            Write-Host ''; Write-Host " $(c 'Goodbye!' 'Cyan')"; Write-Host ''
            break
        }
        if ($inp -eq 's') { Invoke-Search; continue }

        if ($inp -match '^\d+$') {
            $catIdx = [int]$inp
            if ($catIdx -ge 0 -and $catIdx -lt $cats.Count) {
                $selectedCat = $cats[$catIdx]
                $filtered = @(if ($selectedCat -eq 'All') { $CATALOG } else { $CATALOG | Where-Object { $_.Category -eq $selectedCat } })
                Show-Banner
                $hdr = if ($selectedCat -eq 'All') { 'ALL TOOLS' } else { $selectedCat.ToUpper() }
                Write-Host " $(c $hdr 'Cyan' -bold)  $(c "($($filtered.Count) tools)" 'BrightBlack')"
                Write-Host ''
                Show-ToolList $filtered
                Draw-Line
                $idInput = Read-Host " Enter tool $(c '[ID]' 'Yellow') to run, or Enter to go back"
                if ($idInput -match '^\d+$') {
                    $chosen = $filtered | Where-Object { $_.Id -eq [int]$idInput }
                    if ($chosen) { Invoke-ToolSecure $chosen }
                    else { Write-Host " $(c '[!] Invalid ID.' 'Yellow')"; Start-Sleep -Milliseconds 700 }
                }
            } else {
                Write-Host " $(c '[!] Invalid choice.' 'Yellow')"; Start-Sleep -Milliseconds 700
            }
        }
    }
}

Start-IrmHub
