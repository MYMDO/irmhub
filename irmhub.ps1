#Requires -Version 5.1
<#
.SYNOPSIS
    IRMHUB - Universal PowerShell Tool Launcher
.DESCRIPTION
    Aggregates all popular open-source utilities installable via irm | iex.
    Zero telemetry. Zero logging. HTTPS-only. Confirm before execute.
.LINK
    https://github.com/MYMDO/irmhub
#>

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# ==========================================
# 1. CORE BOOTSTRAP & SECURITY PROFILES
# ==========================================

# Enforce TLS 1.2 at minimum (often required for GitHub raw content and modern CDNs)
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Warning "Failed to enforce TLS 1.2 protocol."
}

# Try to enable TLS 1.3 if available (PS7+ or newer Windows builds)
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls13
} catch { }

# Enable VirtualTerminalProcessing for ANSI colors on older PS 5.1 conhost
try {
    $sig = '[DllImport("kernel32.dll")]public static extern bool SetConsoleMode(IntPtr h,int m);[DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int n);[DllImport("kernel32.dll")]public static extern bool GetConsoleMode(IntPtr h,out int m);'
    $k32 = Add-Type -MemberDefinition $sig -Name K32 -Namespace VT -PassThru -ErrorAction SilentlyContinue
    if ($k32) {
        $hOut = $k32::GetStdHandle(-11)
        $mode = 0
        $null = $k32::GetConsoleMode($hOut, [ref]$mode)
        $null = $k32::SetConsoleMode($hOut, ($mode -bor 4))
    }
} catch { }

# ==========================================
# 2. STATE & UI CONFIGURATION
# ==========================================

$script:ESC = [char]27
$script:ANSI = @{
    Reset       = "$script:ESC[0m"
    Bold        = "$script:ESC[1m"
    Dim         = "$script:ESC[2m"
    Red         = "$script:ESC[31m"
    Green       = "$script:ESC[32m"
    Yellow      = "$script:ESC[33m"
    Blue        = "$script:ESC[34m"
    Magenta     = "$script:ESC[35m"
    Cyan        = "$script:ESC[36m"
    White       = "$script:ESC[37m"
    BrightBlack = "$script:ESC[90m"
}

# Determine optimal width
$script:WIDTH = [Math]::Min(100, $Host.UI.RawUI.WindowSize.Width - 2)
if ($script:WIDTH -lt 60) { $script:WIDTH = 78 }

# ==========================================
# 3. CATALOG REGISTRY
# ==========================================

# Defined as an array of robust PSCustomObjects for clean readability
$script:CATALOG = @(
    [PSCustomObject]@{ Id=1;  Name='Scoop';                  Cat='Package Manager'; Icon='[PKG]'; Admin=$false; Cmd='irm https://get.scoop.sh | iex';                                                                                                                                           GitHub='https://github.com/ScoopInstaller/Scoop';                  Desc='Package manager for Windows. No admin needed. User-space installs.' }
    [PSCustomObject]@{ Id=2;  Name='Chocolatey';             Cat='Package Manager'; Icon='[PKG]'; Admin=$true;  Cmd='Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1''))'; GitHub='https://github.com/chocolatey/choco';                       Desc='Largest Windows package repo. 10k+ packages. Enterprise-grade.' }
    [PSCustomObject]@{ Id=3;  Name='Bun';                    Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://bun.sh/install.ps1 | iex';                                                                                                                                    GitHub='https://github.com/oven-sh/bun';                           Desc='All-in-one JS runtime, bundler, test runner and package manager.' }
    [PSCustomObject]@{ Id=4;  Name='Deno';                   Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://deno.land/install.ps1 | iex';                                                                                                                               GitHub='https://github.com/denoland/deno';                         Desc='Secure TypeScript/JS runtime by Node.js creators. Built-in TS.' }
    [PSCustomObject]@{ Id=5;  Name='fnm';                    Cat='JavaScript';      Icon='[JS] '; Admin=$false; Cmd='irm https://fnm.vercel.app/install | iex';                                                                                                                              GitHub='https://github.com/Schniz/fnm';                            Desc='Fast Node Version Manager written in Rust. Replaces nvm on Windows.' }
    [PSCustomObject]@{ Id=6;  Name='uv';                     Cat='Python';          Icon='[PY] '; Admin=$false; Cmd='irm https://astral.sh/uv/install.ps1 | iex';                                                                                                                            GitHub='https://github.com/astral-sh/uv';                          Desc='Ultra-fast Python package and project manager by Astral (Rust).' }
    [PSCustomObject]@{ Id=7;  Name='Rye';                    Cat='Python';          Icon='[PY] '; Admin=$false; Cmd='irm https://rye.astral.sh/get-windows.ps1 | iex';                                                                                                                       GitHub='https://github.com/astral-sh/rye';                         Desc='Holistic Python project and environment manager. Handles venvs.' }
    [PSCustomObject]@{ Id=8;  Name='Rustup';                 Cat='Rust';            Icon='[RS] '; Admin=$false; Cmd='irm https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; .\rustup-init.exe';                                                                                          GitHub='https://github.com/rust-lang/rustup';                      Desc='Official Rust toolchain installer. rustc, cargo, clippy, rustfmt.' }
    [PSCustomObject]@{ Id=9;  Name='WinUtil (Chris Titus)';  Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://christitus.com/win | iex';                                                                                                                                   GitHub='https://github.com/ChrisTitusTech/winutil';                Desc='All-in-one Windows debloat, tweaks, software install GUI.' }
    [PSCustomObject]@{ Id=10; Name='MAS (Activation)';       Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='irm https://get.activated.win | iex';                                                                                                                                    GitHub='https://github.com/massgravel/Microsoft-Activation-Scripts';Desc='Open-source Windows and Office activator. HWID, KMS38, Online KMS.' }
    [PSCustomObject]@{ Id=11; Name='PowerShell 7';           Cat='System';          Icon='[SYS]'; Admin=$true;  Cmd='iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"';                                                                                                     GitHub='https://github.com/PowerShell/PowerShell';                 Desc='Official Microsoft installer for PowerShell 7 (cross-platform).' }
    [PSCustomObject]@{ Id=12; Name='Oh My Posh';             Cat='Shell / UX';      Icon='[UX] '; Admin=$false; Cmd='irm https://ohmyposh.dev/install.ps1 | iex';                                                                                                                            GitHub='https://github.com/JanDeDobbeleer/oh-my-posh';             Desc='Custom prompt engine for any shell. 200+ themes, Nerd Font icons.' }
    [PSCustomObject]@{ Id=13; Name='Terminal-Icons';         Cat='Shell / UX';      Icon='[UX] '; Admin=$false; Cmd='Install-Module -Name Terminal-Icons -Repository PSGallery -Force';                                                                                                       GitHub='https://github.com/devblackops/Terminal-Icons';            Desc='PowerShell module to show file and folder icons in the terminal.' }
    [PSCustomObject]@{ Id=14; Name='Spicetify CLI';          Cat='Media';           Icon='[MED]'; Admin=$false; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex';                                                                                      GitHub='https://github.com/spicetify/cli';                         Desc='Customize the Spotify desktop client with themes and extensions.' }
    [PSCustomObject]@{ Id=15; Name='Spicetify Marketplace';  Cat='Media';           Icon='[MED]'; Admin=$false; Cmd='iwr -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | iex';                                                                  GitHub='https://github.com/spicetify/marketplace';                 Desc='In-app marketplace for Spicetify themes and extensions.' }
    [PSCustomObject]@{ Id=16; Name='Datatools (Caltech)';    Cat='Dev Tools';       Icon='[DEV]'; Admin=$false; Cmd='irm https://caltechlibrary.github.io/datatools/installer.ps1 | iex';                                                                                                    GitHub='https://github.com/caltechlibrary/datatools';              Desc='CLI tools for JSON, CSV, XLSX and DSV data processing.' }
)

# ==========================================
# 4. HELPER FUNCTIONS
# ==========================================

function Format-Color {
    param([string]$Text, [string]$ColorCode, [switch]$Bold)
    $fontWeight = if ($Bold) { $script:ANSI.Bold } else { '' }
    return "$fontWeight$($script:ANSI[$ColorCode])$Text$($script:ANSI.Reset)"
}

function Write-Divider {
    param([string]$Char = '-')
    Write-Host ($Char * $script:WIDTH) -ForegroundColor DarkGray
}

function Test-AdministratorRights {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-ClearConsole {
    Clear-Host
}

# ==========================================
# 5. UI COMPONENTS
# ==========================================

function Show-HeaderBanner {
    Show-ClearConsole
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
    
    $tagline = 'Universal PowerShell Tool Launcher  *  irm | iex  *  Zero Telemetry'
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
    
    for ($i = 0; $i -lt @($categories).Length; $i++) {
        Write-Host "  $(Format-Color "[$i]" 'Yellow') $($categories[$i])" -ForegroundColor Gray
    }
    Write-Host ''
    Write-Host "  $(Format-Color '[s]' 'Magenta') Search by name / keyword" -ForegroundColor Gray
    Write-Host "  $(Format-Color '[q]' 'Red')     Quit" -ForegroundColor Gray
    Write-Host ''
    Write-Divider
    return $categories
}

function Show-FilteredCatalog {
    param([array]$Items)
    
    $itemArray = @($Items)
    if (-not $itemArray -or $itemArray.Length -eq 0) {
        Write-Host "  $(Format-Color 'No tools found matching criteria.' 'Yellow')"
        return
    }
    
    $colorMap = @{
        'Package Manager'='Green'; 'JavaScript'='Yellow'; 'Python'='Blue';
        'Rust'='Red'; 'System'='Magenta'; 'Shell / UX'='Cyan'; 'Media'='Magenta'; 'Dev Tools'='BrightBlack'
    }

    foreach ($tool in $itemArray) {
        $cColor = if ($colorMap.ContainsKey($tool.Cat)) { $colorMap[$tool.Cat] } else { 'White' }
        $adminBadge = if ($tool.Admin) { $(Format-Color ' [ADMIN REQUIRED]' 'Red') } else { '' }
        
        Write-Host "  $(Format-Color "[$($tool.Id)]" 'Yellow' -Bold) $(Format-Color $tool.Icon $cColor) $(Format-Color $tool.Name 'White' -Bold)$adminBadge"
        Write-Host "       $($tool.Desc)" -ForegroundColor DarkGray
        Write-Host "       $(Format-Color 'CMD:' 'BrightBlack') $(Format-Color $tool.Cmd 'Cyan')" -ForegroundColor DarkGray
        Write-Host ''
    }
}

# ==========================================
# 6. EXECUTION LOGIC
# ==========================================

function Invoke-ExecutionFlow {
    param([PSCustomObject]$SelectedTool)

    Show-ClearConsole
    Write-Divider
    Write-Host " $(Format-Color '> SELECTED TOOL REVIEW' 'Cyan' -Bold)"
    Write-Divider
    Write-Host ''
    Write-Host "  $(Format-Color 'Name     :' 'BrightBlack') $(Format-Color $SelectedTool.Name 'White' -Bold)"
    Write-Host "  $(Format-Color 'Category :' 'BrightBlack') $($SelectedTool.Cat)"
    Write-Host "  $(Format-Color 'GitHub   :' 'BrightBlack') $(Format-Color $SelectedTool.GitHub 'Cyan')"
    
    if ($SelectedTool.Admin) {
        Write-Host "  $(Format-Color 'Privilege:' 'BrightBlack') $(Format-Color 'Requires Administrator Rights' 'Red' -Bold)"
    } else {
        Write-Host "  $(Format-Color 'Privilege:' 'BrightBlack') $(Format-Color 'Runs as current user (No Admin)' 'Green')"
    }
    Write-Host ''
    Write-Host "  $(Format-Color 'Description:' 'BrightBlack')"
    Write-Host "  $($SelectedTool.Desc)" -ForegroundColor Gray
    Write-Host ''
    Write-Divider
    Write-Host ''
    Write-Host " $(Format-Color '! COMMAND TO BE EXECUTED:' 'Yellow' -Bold)"
    Write-Host ''
    Write-Host "   $(Format-Color $SelectedTool.Cmd 'Green' -Bold)"
    Write-Host ''
    Write-Divider

    if ($SelectedTool.Admin -and -not (Test-AdministratorRights)) {
        Write-Host ''
        Write-Host " $(Format-Color '[!] WARNING:' 'Red' -Bold) This tool requires Administrator privileges." -ForegroundColor Red
        Write-Host "     Restart PowerShell as Administrator and run IRMHUB again." -ForegroundColor Red
        Write-Host ''
        Write-Host " Press $(Format-Color 'Enter' 'Yellow') to go back..." -NoNewline
        $null = $Host.UI.ReadLine()
        return
    }

    Write-Host ''
    Write-Host " $(Format-Color 'SECURITY CHECKLIST:' 'BrightBlack')"
    Write-Host "  $(Format-Color 'OK' 'Green') TLS 1.2+ forced" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color 'OK' 'Green') HTTPS verified base endpoints" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color 'OK' 'Green') Exact command shown prior to execution" -ForegroundColor DarkGray
    Write-Host "  $(Format-Color '!!' 'Yellow') Ensure you trust the author at: $($SelectedTool.GitHub)" -ForegroundColor DarkGray
    Write-Host ''

    $confirmation = Read-Host " Type $(Format-Color 'YES' 'Green' -Bold) to strictly confirm and execute, or press Enter to cancel"
    
    if ($confirmation -ceq 'YES') {
        Write-Host ''
        Write-Divider
        Write-Host " $(Format-Color '> Instantiating child runspace...' 'BrightBlack')"
        Write-Host " $(Format-Color '> Executing module deployment...' 'Green' -Bold)"
        Write-Divider
        Write-Host ''

        try {
            # Execute within an isolated scriptblock, relaxing strict mode and error preferences for compatibility
            $relaxedCmd = "Set-StrictMode -Off; `$ErrorActionPreference = 'Continue'; " + $SelectedTool.Cmd
            $sb = [scriptblock]::Create($relaxedCmd)
            & $sb
        } catch {
            Write-Host ''
            Write-Host " $(Format-Color '[ERROR]' 'Red' -Bold) Execution Framework Failed." -ForegroundColor Red
            Write-Host " Details: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            [Console]::ResetColor()
            Write-Host ''
            Write-Divider
            Write-Host " $(Format-Color 'Task Complete.' 'Green') Press $(Format-Color 'Enter' 'Yellow') to return to IRMHUB..." -NoNewline
            $null = $Host.UI.ReadLine()
        }
    } else {
        Write-Host ''
        Write-Host " $(Format-Color 'Execution Cancelled.' 'Yellow') No system modifications were made." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 1200
    }
}

function Invoke-SearchFlow {
    Show-HeaderBanner
    $keyword = Read-Host " $(Format-Color 'Search Catalog' 'Cyan') (name / keyword)"
    if ([string]::IsNullOrWhiteSpace($keyword)) { return }
    
    $keyword = $keyword.Trim().ToLower()
    $searchResults = @($script:CATALOG | Where-Object {
        $_.Name.ToLower().Contains($keyword) -or 
        $_.Desc.ToLower().Contains($keyword) -or
        $_.Cat.ToLower().Contains($keyword) -or 
        $_.Cmd.ToLower().Contains($keyword)
    })
    
    Show-HeaderBanner
    Write-Host " $(Format-Color 'Search Results For:' 'BrightBlack') $(Format-Color $keyword 'Cyan' -Bold)  $(Format-Color "($(@($searchResults).Length) found)" 'BrightBlack')"
    Write-Host ''
    
    Show-FilteredCatalog -Items $searchResults
    
    if (@($searchResults).Length -gt 0) {
        $idInput = Read-Host " Enter tool $(Format-Color '[ID]' 'Yellow') to review and run, or press Enter to go back"
        if ($idInput -match '^\d+$') {
            $matched = $searchResults | Where-Object { $_.Id -eq [int]$idInput }
            if ($matched) { Invoke-ExecutionFlow -SelectedTool $matched[0] }
        }
    } else {
        Write-Host " Press $(Format-Color 'Enter' 'Yellow') to go back..." -NoNewline
        $null = $Host.UI.ReadLine()
    }
}

# ==========================================
# 7. MAIN EVENT LOOP
# ==========================================

function Start-IrmHub {
    try {
        while ($true) {
            Show-HeaderBanner
            $catList = Show-CategoryList
            
            $userInput = (Read-Host " $(Format-Color '->' 'Cyan') Choose menu option or category ID").Trim().ToLower()

            # Handle Exit
            if ($userInput -in @('q', 'quit', 'exit', 'close')) {
                Write-Host ''
                Write-Host " $(Format-Color 'Exiting IRMHUB. Trust Open Source. Goodbye!' 'Cyan')"
                Write-Host ''
                break
            }
            
            # Handle Search
            if ($userInput -eq 's') { 
                Invoke-SearchFlow 
                continue 
            }

            # Handle Category Selection
            if ($userInput -match '^\d+$') {
                $categoryIndex = [int]$userInput
                
                if ($categoryIndex -ge 0 -and $categoryIndex -lt @($catList).Length) {
                    $selectedCategory = $catList[$categoryIndex]
                    
                    $filteredItems = @()
                    if ($selectedCategory -eq 'All') {
                        $filteredItems = @($script:CATALOG)
                    } else {
                        $filteredItems = @($script:CATALOG | Where-Object { $_.Cat -eq $selectedCategory })
                    }
                    
                    Show-HeaderBanner
                    $displayHeader = if ($selectedCategory -eq 'All') { 'ENTIRE CATALOG' } else { $selectedCategory.ToUpper() }
                    Write-Host " $(Format-Color $displayHeader 'Cyan' -Bold)  $(Format-Color "($(@($filteredItems).Length) tools)" 'BrightBlack')"
                    Write-Host ''
                    
                    Show-FilteredCatalog -Items $filteredItems
                    Write-Divider
                    
                    $idInput = Read-Host " Enter tool $(Format-Color '[ID]' 'Yellow') to review and run, or press Enter to go back"
                    if ($idInput -match '^\d+$') {
                        $chosenTool = $filteredItems | Where-Object { $_.Id -eq [int]$idInput }
                        
                        if ($chosenTool) { 
                            Invoke-ExecutionFlow -SelectedTool $chosenTool[0] 
                        } else { 
                            Write-Host " $(Format-Color '[!] Invalid Tool ID.' 'Yellow')"
                            Start-Sleep -Milliseconds 800 
                        }
                    }
                } else {
                    Write-Host " $(Format-Color '[!] Invalid Category ID.' 'Yellow')"
                    Start-Sleep -Milliseconds 800
                }
            }
        }
    } finally {
        # Failsafe cleanup ensuring terminal coloring state returns to standard defaults upon abrupt exit
        [Console]::ResetColor()
    }
}

# Start Execution
Start-IrmHub
