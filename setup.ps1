# ============================================================================
#  setup.ps1 -- Bootstrap a fresh Windows dev environment for Neovim
#
#  Usage:
#    1. Open PowerShell as Administrator
#    2. git clone <this-repo> ~\conf-file
#    3. cd ~\conf-file; .\setup.ps1
#
#  What it does:
#    1. Installs Scoop (package manager for dev CLI tools)
#    2. Installs Git, curl, and core CLI tools via winget/scoop
#    3. Installs Neovim v0.12 from GitHub releases
#    4. Installs fzf, ripgrep, bat, fd (needed by nvim plugins)
#    5. Installs Node.js LTS, Go, Rust, Python
#    6. Installs lazygit, glow
#    7. Installs a C compiler (zig) for Treesitter parser compilation
#    8. Symlinks Neovim config
#    9. Bootstraps Neovim plugins
# ============================================================================

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Constants ───────────────────────────────────────────────────────────────
$CONF_DIR     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$NVIM_VERSION = "v0.12.0"
$GO_VERSION   = "1.23.6"
$NODE_LTS     = "22"

# ── Colors / Logging ───────────────────────────────────────────────────────
function Log($msg)  { Write-Host "[+] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Err($msg)  { Write-Host "[x] $msg" -ForegroundColor Red }
function Step($msg) { Write-Host "`n-- $msg --" -ForegroundColor Cyan }

# ── Helpers ─────────────────────────────────────────────────────────────────
function CommandExists($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function EnsureDir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function MakeSymlink($src, $dst) {
    if ((Test-Path $dst) -and ((Get-Item $dst).Target -eq $src)) {
        Log "Already linked: $dst -> $src"
        return
    }
    if (Test-Path $dst) {
        $backup = "$dst.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Warn "Backing up existing $dst -> $backup"
        Move-Item $dst $backup
    }
    EnsureDir (Split-Path -Parent $dst)
    New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
    Log "Linked: $dst -> $src"
}

function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ── Check for Admin (needed for symlinks on older Windows) ──────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Warn "Not running as Administrator. Symlinks may fail on Windows 10."
    Warn "If you get errors, re-run this script as Administrator."
    Warn "On Windows 11+ with Developer Mode enabled, symlinks work without admin.`n"
}

# ── 1. Scoop ────────────────────────────────────────────────────────────────
Step "Scoop (package manager)"

if (-not (CommandExists scoop)) {
    Log "Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    RefreshPath
} else {
    Log "Scoop already installed"
}

# Add extras bucket (needed for some packages)
scoop bucket add extras 2>$null
scoop bucket add versions 2>$null

# ── 2. Git ──────────────────────────────────────────────────────────────────
Step "Git"

if (-not (CommandExists git)) {
    Log "Installing Git via Scoop..."
    scoop install git
    RefreshPath
} else {
    Log "Git already installed: $(git --version)"
}

# ── 3. Neovim ───────────────────────────────────────────────────────────────
Step "Neovim"

if (CommandExists nvim) {
    Log "Neovim already installed: $(nvim --version | Select-Object -First 1)"
} else {
    Log "Installing Neovim ${NVIM_VERSION}..."
    $nvimUrl  = "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-win64.zip"
    $nvimZip  = "$env:TEMP\nvim-win64.zip"
    $nvimDest = "$env:LOCALAPPDATA\nvim-win64"

    Invoke-WebRequest -Uri $nvimUrl -OutFile $nvimZip -UseBasicParsing
    if (Test-Path $nvimDest) { Remove-Item -Recurse -Force $nvimDest }
    Expand-Archive -Path $nvimZip -DestinationPath $env:LOCALAPPDATA -Force
    Remove-Item $nvimZip -Force

    # Add to user PATH permanently
    $nvimBin = "$nvimDest\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$nvimBin*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$nvimBin", "User")
        $env:Path += ";$nvimBin"
    }
    Log "Neovim installed to $nvimDest"
}

# ── 4. CLI tools (fzf, ripgrep, bat, fd) ───────────────────────────────────
Step "CLI tools"

$scoopPackages = @(
    @{ Name = "fzf";     Cmd = "fzf"  },
    @{ Name = "ripgrep"; Cmd = "rg"   },
    @{ Name = "bat";     Cmd = "bat"  },
    @{ Name = "fd";      Cmd = "fd"   },
    @{ Name = "curl";    Cmd = "curl" },
    @{ Name = "unzip";   Cmd = "unzip" }
)

foreach ($pkg in $scoopPackages) {
    if (CommandExists $pkg.Cmd) {
        Log "$($pkg.Name) already installed"
    } else {
        Log "Installing $($pkg.Name)..."
        scoop install $pkg.Name
    }
}

# ── 5. C Compiler (zig — needed for Treesitter parser compilation) ─────────
Step "C Compiler (zig)"

if (CommandExists zig) {
    Log "zig already installed"
} else {
    Log "Installing zig (needed by Treesitter to compile parsers)..."
    scoop install zig
}

# ── 6. Node.js ──────────────────────────────────────────────────────────────
Step "Node.js"

if (CommandExists node) {
    Log "Node.js already installed: $(node --version)"
} else {
    Log "Installing Node.js LTS via Scoop..."
    scoop install nodejs-lts
    RefreshPath
    Log "Node.js installed: $(node --version)"
}

# ── 7. Go ───────────────────────────────────────────────────────────────────
Step "Go"

if (CommandExists go) {
    Log "Go already installed: $(go version)"
} else {
    Log "Installing Go..."
    scoop install go
    RefreshPath
    Log "Go installed"
}

# ── 8. Rust ─────────────────────────────────────────────────────────────────
Step "Rust"

if (CommandExists rustc) {
    Log "Rust already installed: $(rustc --version)"
} else {
    Log "Installing Rust via rustup..."
    scoop install rustup
    rustup-init -y --default-toolchain stable 2>$null
    RefreshPath
    Log "Rust installed"
}

# ── 9. Python ───────────────────────────────────────────────────────────────
Step "Python"

if (CommandExists python) {
    Log "Python already installed: $(python --version)"
} else {
    Log "Installing Python..."
    scoop install python
    RefreshPath
}

# ── 10. lazygit ─────────────────────────────────────────────────────────────
Step "lazygit"

if (CommandExists lazygit) {
    Log "lazygit already installed"
} else {
    Log "Installing lazygit..."
    scoop install lazygit
}

# ── 11. glow (markdown reader) ──────────────────────────────────────────────
Step "glow"

if (CommandExists glow) {
    Log "glow already installed"
} else {
    Log "Installing glow..."
    scoop install glow
}

# ── 12. PSFzf module (fzf keybindings for PowerShell) ──────────────────────
Step "PSFzf module"

if (Get-Module -ListAvailable -Name PSFzf) {
    Log "PSFzf already installed"
} else {
    Log "Installing PSFzf module..."
    Install-Module -Name PSFzf -Scope CurrentUser -Force -SkipPublisherCheck
}

# ── 13. Symlinks ────────────────────────────────────────────────────────────
Step "Symlinks"

$nvimConfigDir = "$env:LOCALAPPDATA\nvim"
MakeSymlink "$CONF_DIR\nvim\init.lua" "$nvimConfigDir\init.lua"

# PowerShell profile
$psProfileDir = Split-Path -Parent $PROFILE
MakeSymlink "$CONF_DIR\powershell\Microsoft.PowerShell_profile.ps1" $PROFILE

# ── 14. Neovim plugin bootstrap ────────────────────────────────────────────
Step "Neovim plugins"

RefreshPath

if (CommandExists nvim) {
    Log "Launching Neovim to download plugins and Treesitter parsers..."

    # First pass: sync plugins via vim.pack
    nvim --headless "+Lazy! sync" "+qa" 2>$null
    # Second pass: let vim.pack finish downloading
    nvim --headless "+sleep 5" "+qa" 2>$null

    Log "Plugins bootstrapped (Mason LSP servers install on first file open)"
} else {
    Err "nvim not found on PATH. Restart your terminal and run: nvim --headless '+Lazy! sync' +qa"
}

# ── Done ────────────────────────────────────────────────────────────────────
Step "Setup complete"

Write-Host ""
Log "Config repo:  $CONF_DIR"
Log "Symlinks:"
Log "  $nvimConfigDir\init.lua -> $CONF_DIR\nvim\init.lua"
Log "  $PROFILE -> $CONF_DIR\powershell\Microsoft.PowerShell_profile.ps1"
Write-Host ""
Warn "Restart your terminal to pick up PATH changes."
Warn "First nvim launch will install Mason LSP servers -- run :Mason to check progress."
Warn "Treesitter uses zig as the C compiler. If parsers fail, ensure 'zig' is on PATH."
Write-Host ""
