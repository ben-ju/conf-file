# =========================================================================== #
#  PowerShell Profile — mirrors bash/.bashrc for Windows
# =========================================================================== #

# =========================================================================== #
#  ENVIRONMENT
# =========================================================================== #
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

$env:GOPATH = "$HOME\go"

# FZF catppuccin macchiato colors (matches .bashrc)
$env:FZF_DEFAULT_OPTS = @"
  --height 40% --layout=reverse --border rounded
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb
  --color=info:#cba6f7,prompt:#89b4fa,pointer:#f38ba8
  --color=marker:#a6e3a1,spinner:#f5c2e7,header:#6c7086
  --prompt='> ' --pointer='>' --marker='v'
"@
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git --exclude node_modules --exclude target'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND

$env:CLAUDE_CODE_MAX_OUTPUT_TOKENS = 64000

# =========================================================================== #
#  PROMPT — user@host path (git-branch)
# =========================================================================== #
function _GitBranch {
    $branch = git symbolic-ref --short HEAD 2>$null
    if (-not $branch) { $branch = git rev-parse --short HEAD 2>$null }
    if ($branch) { return " ($branch)" }
    return ""
}

function prompt {
    $lastOk  = $?
    $user    = $env:USERNAME
    $host_   = $env:COMPUTERNAME
    $path    = (Get-Location).Path.Replace($HOME, "~")
    $gitInfo = _GitBranch

    $arrow = if ($lastOk) { "`e[92m>`e[0m" } else { "`e[91m>`e[0m" }

    "`e[1m`e[96m${user}`e[0m@`e[1m`e[94m${host_}`e[0m `e[33m${path}`e[0m`e[35m${gitInfo}`e[0m`n${arrow} "
}

# =========================================================================== #
#  ALIASES
# =========================================================================== #
Set-Alias -Name v -Value nvim
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name lg -Value lazygit
Set-Alias -Name g -Value git

function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Name @args }
function mkcd($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }

# Safer file operations (prompt before overwrite)
function cpi { Copy-Item -Confirm @args }
function mvi { Move-Item -Confirm @args }
function rmi { Remove-Item -Confirm @args }

# Markdown reader (glow)
function mdread { glow -p @args }

# =========================================================================== #
#  FZF KEYBINDINGS (PSFzf module — optional)
# =========================================================================== #
# If PSFzf is installed, wire up Ctrl+T (file) and Ctrl+R (history)
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# =========================================================================== #
#  PSReadLine (better editing in the terminal)
# =========================================================================== #
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
}
