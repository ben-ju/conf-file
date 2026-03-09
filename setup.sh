#!/usr/bin/env bash
# ============================================================================
#  setup.sh — Bootstrap a fresh Ubuntu / WSL-Ubuntu dev environment
#
#  Usage:
#    git clone <this-repo> ~/conf-file
#    cd ~/conf-file && bash setup.sh
#
#  What it does:
#    1. Symlinks bashrc and neovim config
#    2. Installs apt packages (git, curl, build-essential, fzf, ripgrep, bat…)
#    3. Installs Neovim (stable from GitHub releases)
#    4. Installs nvm + latest LTS Node.js
#    5. Installs Go
#    6. Installs Rust via rustup
#    7. Installs lazygit
#    8. Installs glow (markdown reader)
#    9. Opens Neovim once to bootstrap plugins + Mason LSP servers
# ============================================================================

set -euo pipefail

# ── Constants ───────────────────────────────────────────────────────────────
CONF_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_VERSION="v0.11.1"
GO_VERSION="1.23.6"
LAZYGIT_VERSION="0.44.1"
GLOW_VERSION="2.0.0"
NODE_LTS="22"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()  { printf "${GREEN}${BOLD}[✓]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}${BOLD}[!]${RESET} %s\n" "$*"; }
err()  { printf "${RED}${BOLD}[✗]${RESET} %s\n" "$*"; }
step() { printf "\n${CYAN}${BOLD}── %s ──${RESET}\n" "$*"; }

# ── Helpers ─────────────────────────────────────────────────────────────────
command_exists() { command -v "$1" &>/dev/null; }

symlink() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    log "Already linked: $dst -> $src"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.bak.$(date +%s)"
    warn "Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
}

# ── 1. Symlinks ────────────────────────────────────────────────────────────
step "Symlinks"

symlink "$CONF_DIR/bash/.bashrc"  "$HOME/.bashrc"
symlink "$CONF_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# ── 2. APT packages ───────────────────────────────────────────────────────
step "APT packages"

PACKAGES=(
  git curl wget unzip tar gzip
  build-essential cmake
  fzf ripgrep bat
  python3 python3-pip python3-venv
  bash-completion
  xclip                        # clipboard support for WSL/X11
)

sudo apt-get update -qq
sudo apt-get install -y -qq "${PACKAGES[@]}"
log "APT packages installed"

# bat is installed as 'batcat' on Ubuntu — create symlink if needed
if command_exists batcat && ! command_exists bat; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  log "Linked batcat -> bat"
fi

# ── 3. Neovim ─────────────────────────────────────────────────────────────
step "Neovim"

if command_exists nvim; then
  log "Neovim already installed: $(nvim --version | head -1)"
else
  log "Installing Neovim ${NVIM_VERSION}..."
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
    -o /tmp/nvim.tar.gz
  sudo rm -rf /opt/nvim-linux64
  sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
  # The tarball extracts as nvim-linux-x86_64; normalize to nvim-linux64
  if [ -d /opt/nvim-linux-x86_64 ] && [ ! -d /opt/nvim-linux64 ]; then
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim-linux64
  fi
  rm -f /tmp/nvim.tar.gz
  log "Neovim installed to /opt/nvim-linux64"
fi

# Ensure nvim is on PATH (bashrc already adds /opt/nvim-linux64/bin)
export PATH="/opt/nvim-linux64/bin:$PATH"

# ── 4. Node.js (via nvm) ─────────────────────────────────────────────────
step "Node.js (nvm)"

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  log "Installing nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Load nvm for this script
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if command_exists node; then
  log "Node.js already installed: $(node --version)"
else
  log "Installing Node.js LTS ${NODE_LTS}..."
  nvm install "$NODE_LTS"
  nvm alias default "$NODE_LTS"
fi
log "npm $(npm --version)"

# ── 5. Go ─────────────────────────────────────────────────────────────────
step "Go"

if command_exists go; then
  log "Go already installed: $(go version)"
else
  log "Installing Go ${GO_VERSION}..."
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
  mkdir -p "$HOME/.local/opt"
  rm -rf "$HOME/.local/opt/go"
  tar -xzf /tmp/go.tar.gz -C "$HOME/.local/opt/"
  rm -f /tmp/go.tar.gz
  log "Go installed to ~/.local/opt/go"
fi

export PATH="$PATH:$HOME/.local/opt/go/bin:$HOME/go/bin"

# ── 6. Rust ───────────────────────────────────────────────────────────────
step "Rust"

if command_exists rustc; then
  log "Rust already installed: $(rustc --version)"
else
  log "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  log "Rust installed: $(rustc --version)"
fi

# ── 7. lazygit ────────────────────────────────────────────────────────────
step "lazygit"

if command_exists lazygit; then
  log "lazygit already installed"
else
  log "Installing lazygit ${LAZYGIT_VERSION}..."
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    -o /tmp/lazygit.tar.gz
  mkdir -p "$HOME/.local/bin"
  tar -xzf /tmp/lazygit.tar.gz -C /tmp/ lazygit
  mv /tmp/lazygit "$HOME/.local/bin/lazygit"
  rm -f /tmp/lazygit.tar.gz
  log "lazygit installed to ~/.local/bin"
fi

# ── 8. glow (markdown reader) ────────────────────────────────────────────
step "glow"

if command_exists glow; then
  log "glow already installed"
else
  log "Installing glow ${GLOW_VERSION}..."
  curl -fsSL "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_x86_64.tar.gz" \
    -o /tmp/glow.tar.gz
  mkdir -p "$HOME/.local/bin"
  tar -xzf /tmp/glow.tar.gz -C /tmp/ glow
  mv /tmp/glow "$HOME/.local/bin/glow"
  rm -f /tmp/glow.tar.gz
  log "glow installed to ~/.local/bin"
fi

# ── 9. Neovim plugin bootstrap ───────────────────────────────────────────
step "Neovim plugins"

log "Launching Neovim to let vim.pack download plugins..."
# Pass 1: vim.pack clones plugin repos (they aren't on runtimepath yet)
nvim --headless "+sleep 15" +qa 2>/dev/null || true
# Pass 2: plugins are now on runtimepath — nvim-treesitter's
# ensure_installed kicks in and compiles parsers
log "Second launch: loading plugins and installing Treesitter parsers..."
nvim --headless "+sleep 20" +qa 2>/dev/null || true
log "Plugins bootstrapped (Mason LSP servers install on first file open)"

# ── Done ──────────────────────────────────────────────────────────────────
step "Setup complete"

echo ""
log "Config repo:  $CONF_DIR"
log "Symlinks:"
log "  ~/.bashrc           -> $CONF_DIR/bash/.bashrc"
log "  ~/.config/nvim/init.lua -> $CONF_DIR/nvim/init.lua"
echo ""
warn "Reload your shell:  source ~/.bashrc"
warn "First nvim launch will install Mason LSP servers — run :Mason to check progress"
echo ""
