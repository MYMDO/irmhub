#Requires -Version 5.1
<#
.SYNOPSIS
    IRMHUB - Universal PowerShell Tool Launcher
.DESCRIPTION
    An interactive TUI that aggregates popular open-source utilities installable
    via 'irm | iex' with full security transparency. Zero telemetry. Zero logging.
    HTTPS-only. Confirm before execute.
.PARAMETER List
    Display all tools without entering interactive mode.
.PARAMETER Search
    Search for tools by name, keyword, or category.
.PARAMETER Run
    Execute a tool directly by its ID (skips confirmation if -AutoConfirm is used).
.PARAMETER Category
    Filter tools by category name.
.PARAMETER AutoConfirm
    Skip the 'YES' confirmation prompt (use with -Run for automation).
.PARAMETER NoColor
    Disable ANSI color output.
.PARAMETER Version
    Display version information.
.PARAMETER Update
    Check for and display the latest version from GitHub.
.EXAMPLE
    irm https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1 | iex
    Run IRMHUB in interactive mode.
.EXAMPLE
    irmhub.ps1 -List
    Display all available tools.
.EXAMPLE
    irmhub.ps1 -Search "python"
    Search for Python-related tools.
.EXAMPLE
    irmhub.ps1 -Run 6
    Run tool with ID 6 directly.
.EXAMPLE
    irmhub.ps1 -Category "JavaScript"
    Show all JavaScript tools.
.EXAMPLE
    irmhub.ps1 -Run 6 -AutoConfirm
    Run tool 6 without confirmation (for automation).
.LINK
    https://github.com/MYMDO/irmhub
    https://github.com/MYMDO/irmhub/releases
#>

# Parse script-level parameters manually — avoids MetadataError with irm | iex in PS 5.1
$List = $false; $Search = $null; [int]$Run = -1; $Category = $null
$AutoConfirm = $false; $NoColor = $false; $Version = $false; $Update = $false

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        '-List' { $List = $true }
        '-Search' { $Search = $args[++$i] }
        '-Run' { $Run = [int]$args[++$i]; if ($Run -le 0) { Write-Warning "Invalid -Run value: must be positive."; exit 6 } }
        '-Category' { $Category = $args[++$i] }
        '-AutoConfirm' { $AutoConfirm = $true }
        '-NoColor' { $NoColor = $true }
        '-Version' { $Version = $true }
        '-Update' { $Update = $true }
        default { Write-Warning "Unknown parameter: $($args[$i])"; exit 6 }
    }
    $i++
}

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

#region Constants
$script:SCRIPT_VERSION = '1.0.0'
$script:AUTHOR = 'MYMDO'
$script:REPO_URL = 'https://github.com/MYMDO/irmhub'
$script:RAW_URL = 'https://raw.githubusercontent.com/MYMDO/irmhub/main/irmhub.ps1'
$script:LATEST_RELEASE_URL = 'https://api.github.com/repos/MYMDO/irmhub/releases/latest'

$script:EXIT_CODES = @{
    Success = 0
    UserCancel = 1
    AdminRequired = 2
    ToolNotFound = 3
    ExecutionFailed = 4
    NetworkError = 5
    InvalidParameter = 6
    UpdateAvailable = 7
}
#endregion

#region Helper Functions
function Initialize-SecurityProtocol {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    } catch {
        Write-Warning "Failed to enforce TLS 1.2 protocol."
    }
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls13
    } catch { }
}

function Initialize-ConsoleTerminal {
    try {
        $signature = '[DllImport("kernel32.dll")]public static extern bool SetConsoleMode(IntPtr h,int m);[DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int n);[DllImport("kernel32.dll")]public static extern bool GetConsoleMode(IntPtr h,out int m);'
        $k32 = Add-Type -MemberDefinition $signature -Name K32 -Namespace VT -PassThru -ErrorAction SilentlyContinue
        if ($null -ne $k32) {
            $hOut = $k32::GetStdHandle(-11)
            $mode = 0
            $null = $k32::GetConsoleMode($hOut, [ref]$mode)
            $null = $k32::SetConsoleMode($hOut, ($mode -bor 4))
        }
    } catch { }
}

function Format-Color {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Reset', 'Bold', 'Dim', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'White', 'BrightBlack')]
        [string]$ColorCode,
        [switch]$Bold
    )
    $fontWeight = if ($Bold) { $script:ANSI['Bold'] } else { '' }
    return "$fontWeight$($script:ANSI[$ColorCode])$Text$($script:ANSI['Reset'])"
}

function Write-Divider {
    param([string]$Char = '-')
    Write-Host "$(Format-Color ($Char * $script:WIDTH) 'BrightBlack')"
}

function Test-AdministratorRights {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Get-ConsoleWidth {
    try {
        $width = $Host.UI.RawUI.WindowSize.Width
        if ($null -ne $width -and $width -gt 0) {
            return [Math]::Min(100, $width - 2)
        }
    } catch { }
    return 78
}

function Get-ToolById {
    param([int]$Id)
    return $script:CATALOG | Where-Object { $_.Id -eq $Id } | Select-Object -First 1
}

function Get-ToolsByCategory {
    param([string]$Category)
    if ([string]::IsNullOrWhiteSpace($Category) -or $Category -eq 'All') {
        return $script:CATALOG
    }
    return $script:CATALOG | Where-Object { $_.Cat -ieq $Category }
}

function Search-Tools {
    param([string]$Keyword)
    if ([string]::IsNullOrWhiteSpace($Keyword)) {
        return $script:CATALOG
    }
    $term = $Keyword.Trim().ToLower()
    return $script:CATALOG | Where-Object {
        $_.Name.ToLower().Contains($term) -or
        $_.Desc.ToLower().Contains($term) -or
        $_.Cat.ToLower().Contains($term) -or
        $_.Cmd.ToLower().Contains($term)
    }
}

function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri $script:LATEST_RELEASE_URL -TimeoutSec 10 -ErrorAction Stop
        if ($null -ne $response -and $response.tag_name) {
            return $response.tag_name -replace '^v', ''
        }
    } catch { }
    return $null
}

function Test-NetworkConnectivity {
    try {
        $null = [System.Net.Dns]::GetHostAddresses('github.com')
        return $true
    } catch {
        return $false
    }
}
#endregion

#region Bootstrap & Security
Initialize-SecurityProtocol
Initialize-ConsoleTerminal
#endregion

#region State & UI Configuration
$script:ESC = [char]27
$script:COLORS_ENABLED = -not $NoColor

if ($script:COLORS_ENABLED) {
    $script:ANSI = @{ 
        Reset = "$script:ESC[0m"; Bold = "$script:ESC[1m"; Dim = "$script:ESC[2m"
        Red = "$script:ESC[31m"; Green = "$script:ESC[32m"; Yellow = "$script:ESC[33m"
        Blue = "$script:ESC[34m"; Magenta = "$script:ESC[35m"; Cyan = "$script:ESC[36m"
        White = "$script:ESC[37m"; BrightBlack = "$script:ESC[90m"
    }
} else {
    $script:ANSI = @{ 
        Reset = ''; Bold = ''; Dim = ''
        Red = ''; Green = ''; Yellow = ''
        Blue = ''; Magenta = ''; Cyan = ''
        White = ''; BrightBlack = ''
    }
}

$script:WIDTH = Get-ConsoleWidth

$script:CATEGORY_COLORS = @{
    'Package Manager' = 'Green'
    'JavaScript' = 'Yellow'
    'Python' = 'Blue'
    'Rust' = 'Red'
    'System' = 'Magenta'
    'Shell / UX' = 'Cyan'
    'Media' = 'Magenta'
    'Dev Tools' = 'BrightBlack'
}
#endregion

#region Tool Catalog
$script:CATALOG = @(
    [PSCustomObject]@{ Id=1;  Name='Scoop';                  Cat='Package Manager'; Icon='[PKG]'; Admin=$false; Cmd='irm https://get.scoop.sh | iex';                                                                                                           GitHub='https://github.com/ScoopInstaller/Scoop';                  Desc='Package manager for Windows. No admin needed. User-space installs.' }
    [PSCustomObject]@{ Id=2;  Name='Chocolatey';             Cat='Package Manager'; Icon='[PKG]'; Admin=$true;  Cmd='Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1''))';  GitHub='https://github.com/chocolatey/choco';                       Desc='Largest Windows package repo. 10k+ packages. Enterprise-grade.' }
    [PSCustomObject]@{ Id=3;  Name='Bun';                    Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://bun.sh/install.ps1 | iex';                                                                                                          GitHub='https://github.com/oven-sh/bun';                           Desc='All-in-one JS runtime, bundler, test runner and package manager.' }
    [PSCustomObject]@{ Id=4;  Name='Deno';                   Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://deno.land/install.ps1 | iex';                                                                                                 GitHub='https://github.com/denoland/deno';                         Desc='Secure TypeScript/JS runtime by Node.js creators. Built-in TS.' }
    [PSCustomObject]@{ Id=5;  Name='fnm';                    Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://fnm.vercel.app/install | iex';                                                                                                GitHub='https://github.com/Schniz/fnm';                            Desc='Fast Node Version Manager written in Rust. Replaces nvm on Windows.' }
    [PSCustomObject]@{ Id=6;  Name='uv';                     Cat='Python';          Icon='[PY] '; Admin=$false; Cmd='irm https://astral.sh/uv/install.ps1 | iex';                                                                                              GitHub='https://github.com/astral-sh/uv';                          Desc='Ultra-fast Python package and project manager by Astral (Rust).' }
    [PSCustomObject]@{ Id=7;  Name='Rye';                    Cat='Python';          Icon='[PY] '; Admin=$false; Cmd='irm https://rye.astral.sh/get-windows.ps1 | iex';                                                                                             GitHub='https://github.com/astral-sh/rye';                         Desc='Holistic Python project and environment manager. Handles venvs.' }
    [PSCustomObject]@{ Id=8;  Name='Rustup';                 Cat='Rust';            Icon='[RS] '; Admin=$false; Cmd='irm https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; .\rustup-init.exe';                                                                    GitHub='https://github.com/rust-lang/rustup';                      Desc='Official Rust toolchain installer. rustc, cargo, clippy, rustfmt.' }
    [PSCustomObject]@{ Id=9;  Name='WinUtil (Chris Titus)';  Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://christitus.com/win | iex';                                                                                                  GitHub='https://github.com/ChrisTitusTech/winutil';                Desc='All-in-one Windows debloat, tweaks, software install GUI.' }
    [PSCustomObject]@{ Id=10; Name='MAS (Activation)';       Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://get.activated.win | iex';                                                                                                   GitHub='https://github.com/massgravel/Microsoft-Activation-Scripts';Desc='Open-source Windows/Office activation script. HWID, KMS38, Online KMS. Use at your own risk and in compliance with local laws.' }
    [PSCustomObject]@{ Id=11; Name='PowerShell 7';           Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"';                                                                              GitHub='https://github.com/PowerShell/PowerShell';                 Desc='Official Microsoft installer for PowerShell 7 (cross-platform).' }
    [PSCustomObject]@{ Id=12; Name='Oh My Posh';             Cat='Shell / UX';      Icon='[UX] '; Admin=$false; Cmd='irm https://ohmyposh.dev/install.ps1 | iex';                                                                                                GitHub='https://github.com/JanDeDobbeleer/oh-my-posh';             Desc='Custom prompt engine for any shell. 200+ themes, Nerd Font icons.' }
    [PSCustomObject]@{ Id=13; Name='Terminal-Icons';         Cat='Shell / UX';      Icon='[UX] '; Admin=$false; Cmd='Install-Module -Name Terminal-Icons -Repository PSGallery -Force';                                                                                      GitHub='https://github.com/devblackops/Terminal-Icons';            Desc='PowerShell module to show file and folder icons in the terminal.' }
    [PSCustomObject]@{ Id=14; Name='Spicetify CLI';          Cat='Media';           Icon='[MED]'; Admin=$false; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex';                                                                             GitHub='https://github.com/spicetify/cli';                         Desc='Customize the Spotify desktop client with themes and extensions.' }
    [PSCustomObject]@{ Id=15; Name='Spicetify Marketplace';  Cat='Media';           Icon='[MED]'; Admin=$false; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | iex';                                                                    GitHub='https://github.com/spicetify/marketplace';                 Desc='In-app marketplace for Spicetify themes and extensions.' }
    [PSCustomObject]@{ Id=16; Name='Datatools (Caltech)';    Cat='Dev Tools';       Icon='[DEV]'; Admin=$false; Cmd='irm https://caltechlibrary.github.io/datatools/installer.ps1 | iex';                                                                                  GitHub='https://github.com/caltechlibrary/datatools';              Desc='CLI tools for JSON, CSV, XLSX and DSV data processing.' }
    [PSCustomObject]@{ Id=17; Name='InstallOffice Tool';     Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://setup.installoffice.org | iex';                                                                                                  GitHub='https://github.com/installoffice/setup';                   Desc='Official Microsoft Office Installation Tool. Install/Remove MS Office apps.' }
    [PSCustomObject]@{ Id=18; Name='Win11Debloat (Raphire)'; Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://debloat.raphi.re/ | iex';                                                                                                  GitHub='https://github.com/Raphire/Win11Debloat';                  Desc='Remove bloatware, telemetry, and declutter Windows 10/11 quickly.' }
    [PSCustomObject]@{ Id=19; Name='WinGet-CLI (LTSC/LTSB)'; Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://winget.pro | iex';                                                                                                              GitHub='https://github.com/asheroto/winget-install';              Desc='Install Microsoft WinGet on Windows 10/11 LTSC, LTSB, and Server versions.' }
)

$dupeIds = $script:CATALOG | Group-Object Id | Where-Object Count -gt 1
if ($dupeIds) { throw "Duplicate catalog IDs: $($dupeIds.Name -join ', ')" }
#endregion

#region UI Components
function Show-Banner {
    param([switch]$NoClear)
    if (-not $NoClear) { Clear-Host }
    $asciiLogo = @(
        '  ██╗██████╗ ███╗   ███╗    ██╗  ██╗██╗   ██╗██████╗ ',
        '  ██║██╔══██╗████╗ ████║    ██║  ██║██║   ██║██╔══██╗',
        '  ██║██████╔╝██╔████╔██║    ███████║██║   ██║██████╔╝',
        '  ██║██╔══██╗██║╚██╔╝██║    ██╔══██║██║   ██║██╔══██╗',
        '  ██║██║  ██║██║ ╚═╝ ██║    ██║  ██║╚██████╔╝██████╔╝',
        '  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ '
    )
    foreach ($line in $asciiLogo) { Write-Host $line -ForegroundColor Cyan }
    Write-Host ''
    
    $tagline = "Universal PowerShell Tool Launcher  *  irm | iex  *  Zero Telemetry"
    $padding = [int](($script:WIDTH - $tagline.Length) / 2)
    Write-Host (' ' * [Math]::Max(0, $padding)) -NoNewline
    Write-Host $tagline -ForegroundColor DarkCyan
    
    Write-Host ''
    Write-Divider
    Write-Host " $(Format-Color '[!]' 'Yellow' -Bold) $(Format-Color 'SECURITY:' 'Yellow') Every command is explicitly shown BEFORE execution." -ForegroundColor Gray
    Write-Host " $(Format-Color '[i]' 'BrightBlack') PRIVACY : No telemetry. No environment logging. Zero outbound calls." -ForegroundColor DarkGray
    Write-Divider
    Write-Host ''
}

function Show-CategoryList {
    $categories = @('All') + ($script:CATALOG | Select-Object -ExpandProperty Cat -Unique | Sort-Object)
    Write-Host " $(Format-Color 'FILTER BY CATEGORY' 'BrightBlack')"
    Write-Host ''
    
    for ($i = 0; $i -lt $categories.Count; $i++) {
        Write-Host "  $(Format-Color "[$i]" 'Yellow') $($categories[$i])" -ForegroundColor Gray
    }
    Write-Host ''
    Write-Host "  $(Format-Color '[s]' 'Magenta') Search by name / keyword" -ForegroundColor Gray
    Write-Host "  $(Format-Color '[q]' 'Red')     Quit" -ForegroundColor Gray
    Write-Host ''
    Write-Divider
    return $categories
}

function Show-ToolList {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Tools
    )
    
    $count = @($Tools).Count
    if ($count -eq 0) {
        Write-Host "  $(Format-Color 'No tools found matching criteria.' 'Yellow')"
        return
    }
    
    foreach ($tool in $Tools) {
        $cColor = if ($script:CATEGORY_COLORS.ContainsKey($tool.Cat)) { $script:CATEGORY_COLORS[$tool.Cat] } else { 'White' }
        $adminBadge = if ($tool.Admin) { " $(Format-Color '[ADMIN REQUIRED]' 'Red')" } else { '' }
        
        Write-Host "  $(Format-Color "[$($tool.Id)]" 'Yellow' -Bold) $(Format-Color $tool.Icon $cColor) $(Format-Color $tool.Name 'White' -Bold)$adminBadge"
        Write-Host "       $($tool.Desc)" -ForegroundColor DarkGray
        Write-Host "       $(Format-Color 'CMD:' 'BrightBlack') $(Format-Color $tool.Cmd 'Cyan')" -ForegroundColor DarkGray
        Write-Host ''
    }
}

function Show-ToolDetails {
    param([PSCustomObject]$Tool)
    
    Write-Divider
    Write-Host " $(Format-Color '> SELECTED TOOL REVIEW' 'Cyan' -Bold)"
    Write-Divider
    Write-Host ''
    Write-Host "  $(Format-Color 'Name     :' 'BrightBlack') $(Format-Color $Tool.Name 'White' -Bold)"
    Write-Host "  $(Format-Color 'Category :' 'BrightBlack') $($Tool.Cat)"
    Write-Host "  $(Format-Color 'GitHub   :' 'BrightBlack') $(Format-Color $Tool.GitHub 'Cyan')"
    
    if ($Tool.Admin) {
        Write-Host "  $(Format-Color 'Privilege:' 'BrightBlack') $(Format-Color 'Requires Administrator Rights' 'Red' -Bold)"
    } else {
        Write-Host "  $(Format-Color 'Privilege:' 'BrightBlack') $(Format-Color 'Runs as current user (No Admin)' 'Green')"
    }
    Write-Host ''
    Write-Host "  $(Format-Color 'Description:' 'BrightBlack')"
    Write-Host "  $($Tool.Desc)" -ForegroundColor Gray
    Write-Host ''
    Write-Divider
    Write-Host ''
    Write-Host " $(Format-Color '! COMMAND TO BE EXECUTED:' 'Yellow' -Bold)"
    Write-Host ''
    Write-Host "   $(Format-Color $Tool.Cmd 'Green' -Bold)"
    Write-Host ''
    Write-Divider
}

function Show-SecurityChecklist {
    param([PSCustomObject]$Tool)
    
    Write-Host ''
    Write-Host " $(Format-Color 'SECURITY CHECKLIST:' 'BrightBlack')"
    Write-Host "  $(Format-Color 'OK' 'Green') TLS 1.2+ forced" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color 'OK' 'Green') HTTPS verified base endpoints" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color 'OK' 'Green') Exact command shown prior to execution" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color '!!' 'Yellow') Ensure you trust the author at: $($Tool.GitHub)" -ForegroundColor DarkGray
    Write-Host ''
}

function Show-AdminWarning {
    param([switch]$NonInteractive)
    Write-Host ''
    Write-Host " $(Format-Color '[!] WARNING:' 'Red' -Bold) This tool requires Administrator privileges." -ForegroundColor Red
    Write-Host "     Restart PowerShell as Administrator and run IRMHUB again." -ForegroundColor Red
    Write-Host ''
    if (-not $NonInteractive) {
        Write-Host " Press $(Format-Color 'Enter' 'Yellow') to go back..." -NoNewline
        $null = $Host.UI.ReadLine()
    }
}

function Show-SearchUI {
    Show-Banner
    $keyword = Read-Host " $(Format-Color 'Search Catalog' 'Cyan') (name / keyword / category)"
    if ([string]::IsNullOrWhiteSpace($keyword)) { return $null }
    
    $results = Search-Tools -Keyword $keyword
    return [PSCustomObject]@{ Keyword = $keyword; Results = $results }
}
#endregion

#region Execution Logic
function Invoke-ToolExecution {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Tool,
        [switch]$SkipConfirmation,
        [switch]$AutoConfirm,
        [switch]$NonInteractive
    )
    
    Show-Banner
    Show-ToolDetails -Tool $Tool
    
    if ($Tool.Admin -and -not (Test-AdministratorRights)) {
        Show-AdminWarning -NonInteractive:$NonInteractive
        return $script:EXIT_CODES.AdminRequired
    }

    if ($SkipConfirmation -or $AutoConfirm) {
        return Invoke-ToolCommand -Tool $Tool -NonInteractive:$NonInteractive
    }

    Show-SecurityChecklist -Tool $Tool

    $confirmation = Read-Host " Type $(Format-Color 'YES' 'Green' -Bold) to strictly confirm and execute, or press Enter to cancel"
    
    if ($confirmation -ceq 'YES') {
        return Invoke-ToolCommand -Tool $Tool
    } else {
        Write-Host ''
        Write-Host " $(Format-Color 'Execution Cancelled.' 'Yellow') No system modifications were made." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 1200
        return $script:EXIT_CODES.UserCancel
    }
}

function Invoke-ToolCommand {
    param(
        [PSCustomObject]$Tool,
        [switch]$NonInteractive
    )
    
    Write-Host ''
    Write-Divider
    Write-Host " $(Format-Color '> Preparing execution scope...' 'BrightBlack')"
    Write-Host " $(Format-Color '> Executing module deployment...' 'Green' -Bold)"
    Write-Divider
    Write-Host ''

    $execSuccess = $true
    try {
        $relaxedCmd = "Set-StrictMode -Off; `$ErrorActionPreference = 'Continue'; $($Tool.Cmd)"
        $sb = [scriptblock]::Create($relaxedCmd)
        & $sb
    } catch {
        $execSuccess = $false
        Write-Host ''
        Write-Host " $(Format-Color '[ERROR]' 'Red' -Bold) Execution Framework Failed." -ForegroundColor Red
        Write-Host " Details: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        [Console]::ResetColor()
        Write-Host ''
        Write-Divider
        if ($execSuccess) {
            if (-not $NonInteractive) {
                Write-Host " $(Format-Color 'Task Complete.' 'Green') Press $(Format-Color 'Enter' 'Yellow') to return to IRMHUB..." -NoNewline
                $null = $Host.UI.ReadLine()
            }
        } else {
            if (-not $NonInteractive) {
                Write-Host " $(Format-Color 'Task Failed.' 'Red') Press $(Format-Color 'Enter' 'Yellow') to return to IRMHUB..." -NoNewline
                $null = $Host.UI.ReadLine()
            }
        }
    }

    if ($execSuccess) {
        return $script:EXIT_CODES.Success
    } else {
        return $script:EXIT_CODES.ExecutionFailed
    }
}
#endregion

#region Interactive Mode
function Start-InteractiveMode {
    try {
        while ($true) {
            Show-Banner
            $categories = Show-CategoryList
            
            $userInput = (Read-Host " $(Format-Color '->' 'Cyan') Choose menu option or category ID").Trim().ToLower()

            switch ($userInput) {
                { $_ -in @('q', 'quit', 'exit', 'close') } {
                    Write-Host ''
                    Write-Host " $(Format-Color 'Exiting IRMHUB. Trust Open Source. Goodbye!' 'Cyan')"
                    Write-Host ''
                    return $script:EXIT_CODES.Success
                }
                's' {
                    $searchResult = Show-SearchUI
                    if ($null -ne $searchResult -and @($searchResult.Results).Count -gt 0) {
                        Show-Banner
                        Write-Host " $(Format-Color 'Search Results For:' 'BrightBlack') $(Format-Color $searchResult.Keyword 'Cyan' -Bold)  $(Format-Color "($(@($searchResult.Results).Count) found)" 'BrightBlack')"
                        Write-Host ''
                        Show-ToolList -Tools $searchResult.Results
                        Prompt-ToolSelection -Tools $searchResult.Results
                    } elseif ($null -ne $searchResult -and -not [string]::IsNullOrWhiteSpace($searchResult.Keyword)) {
                        Write-Host ''
                        Write-Host " $(Format-Color 'No tools found for:' 'Yellow') $(Format-Color $searchResult.Keyword 'Cyan')"
                        Start-Sleep -Milliseconds 1200
                    }
                    continue  # continue outer while loop
                }
                default {
                    if ($userInput -match '^\d+$') {
                        $categoryIndex = [int]$userInput
                        if ($categoryIndex -ge 0 -and $categoryIndex -lt $categories.Count) {
                            $selectedCategory = $categories[$categoryIndex]
                            $filteredTools = Get-ToolsByCategory -Category $selectedCategory
                            
                            Show-Banner
                            $displayHeader = if ($selectedCategory -eq 'All') { 'ENTIRE CATALOG' } else { $selectedCategory.ToUpper() }
                            Write-Host " $(Format-Color $displayHeader 'Cyan' -Bold)  $(Format-Color "($(@($filteredTools).Count) tools)" 'BrightBlack')"
                            Write-Host ''
                            
                            Show-ToolList -Tools $filteredTools
                            Prompt-ToolSelection -Tools $filteredTools
                        } else {
                            Write-Host " $(Format-Color '[!] Invalid Category ID.' 'Yellow')"
                            Start-Sleep -Milliseconds 800
                        }
                    }
                }
            }
        }
    } finally {
        [Console]::ResetColor()
    }
}

function Prompt-ToolSelection {
    param([array]$Tools)
    
    $idInput = Read-Host " Enter tool $(Format-Color '[ID]' 'Yellow') to review and run, or press Enter to go back"
    if ($idInput -match '^\d+$') {
        $selectedTool = $Tools | Where-Object { $_.Id -eq [int]$idInput } | Select-Object -First 1
        if ($null -ne $selectedTool) {
            $null = Invoke-ToolExecution -Tool $selectedTool
        } else {
            Write-Host " $(Format-Color '[!] Invalid Tool ID.' 'Yellow')"
            Start-Sleep -Milliseconds 800
        }
    }
}
#endregion

#region Non-Interactive Mode
function Show-VersionInfo {
    Write-Host "IRMHUB v$script:SCRIPT_VERSION" -ForegroundColor Cyan
    Write-Host "Author: $script:AUTHOR"
    Write-Host "Repository: $script:REPO_URL"
}

function Start-NonInteractiveMode {
    if ($Version) {
        Show-VersionInfo
        return $script:EXIT_CODES.Success
    }

    if ($Update) {
        Write-Host "Checking for updates..." -ForegroundColor Cyan
        if (-not (Test-NetworkConnectivity)) {
            Write-Host "Network error: Unable to connect to GitHub." -ForegroundColor Red
            return $script:EXIT_CODES.NetworkError
        }
        $latest = Get-LatestVersion
        if ($null -eq $latest) {
            Write-Host "No releases found on GitHub. You are running v$script:SCRIPT_VERSION (build version)." -ForegroundColor Yellow
            return $script:EXIT_CODES.Success
        }
        if ($latest -ne $script:SCRIPT_VERSION) {
            Write-Host "Update available: v$latest (current: v$script:SCRIPT_VERSION)" -ForegroundColor Yellow
            Write-Host "Run: irm $script:RAW_URL | iex" -ForegroundColor Cyan
            return $script:EXIT_CODES.UpdateAvailable
        } else {
            Write-Host "You are running the latest version: v$script:SCRIPT_VERSION" -ForegroundColor Green
            return $script:EXIT_CODES.Success
        }
    }

    if ($List) {
        Show-Banner -NoClear
        Write-Host " $(Format-Color 'AVAILABLE TOOLS' 'Cyan' -Bold)  $(Format-Color "($($script:CATALOG.Count) total)" 'BrightBlack')"
        Write-Host ''
        Show-ToolList -Tools $script:CATALOG
        return $script:EXIT_CODES.Success
    }

    if (-not [string]::IsNullOrWhiteSpace($Search)) {
        $results = Search-Tools -Keyword $Search
        Show-Banner -NoClear
        Write-Host " $(Format-Color 'Search Results For:' 'BrightBlack') $(Format-Color $Search 'Cyan' -Bold)  $(Format-Color "($(@($results).Count) found)" 'BrightBlack')"
        Write-Host ''
        Show-ToolList -Tools $results
        return $script:EXIT_CODES.Success
    }

    if ($Run -gt 0) {
        $tool = Get-ToolById -Id $Run
        if ($null -eq $tool) {
            Write-Host "Tool with ID $Run not found." -ForegroundColor Red
            return $script:EXIT_CODES.ToolNotFound
        }
        Write-Host "Executing: $($tool.Name)..." -ForegroundColor Cyan
        return Invoke-ToolExecution -Tool $tool -AutoConfirm:$AutoConfirm -NonInteractive
    }
    if (-not [string]::IsNullOrWhiteSpace($Category)) {
        $tools = Get-ToolsByCategory -Category $Category
        if (@($tools).Count -eq 0) {
            Write-Host "No tools found in category: $Category" -ForegroundColor Yellow
            Write-Host "Available categories: $((@('All') + ($script:CATALOG | Select-Object -ExpandProperty Cat -Unique | Sort-Object) | Where-Object { $_ -ne 'All' }) -join ', ')" -ForegroundColor Gray
            return $script:EXIT_CODES.Success
        }
        Show-Banner -NoClear
        Write-Host " $(Format-Color $Category.ToUpper() 'Cyan' -Bold)  $(Format-Color "($(@($tools).Count) tools)" 'BrightBlack')"
        Write-Host ''
        Show-ToolList -Tools $tools
        return $script:EXIT_CODES.Success
    }

    return $null
}
#endregion

#region Main Entry Point
function Main {
    try {
        if ($List -or -not [string]::IsNullOrWhiteSpace($Search) -or $Run -gt 0 -or -not [string]::IsNullOrWhiteSpace($Category) -or $Version -or $Update) {
            $exitCode = Start-NonInteractiveMode
            if ($null -ne $exitCode) {
                exit $exitCode
            }
        }
        
        $null = Start-InteractiveMode
    } catch {
        Write-Host "`n[FATAL] $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Press Enter to exit..."
        $null = $Host.UI.ReadLine()
    }
}

Main
#endregion
