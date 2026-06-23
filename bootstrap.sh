#!/usr/bin/env bash

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

info()    { echo -e "${BOLD}${GREEN}▶ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $*${RESET}"; }
error()   { echo -e "${RED}✖ $*${RESET}" >&2; exit 1; }
divider() { echo -e "\n${BOLD}────────────────────────────────────────${RESET}"; }


# ── Xcode CLI Tools ───────────────────────────────────────────────────────────

divider
info "Checking Xcode Command Line Tools..."

if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode CLI tools (this may take a few minutes)..."
    xcode-select --install
    # Wait for the user to complete the GUI install prompt
    until xcode-select -p &>/dev/null; do sleep 5; done
    info "Xcode CLI tools installed."
else
    info "Xcode CLI tools already installed - skipping."
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────

divider
info "Checking Homebrew..."

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    info "Homebrew already installed - skipping."
fi

# Add Homebrew to PATH
if [ ! -f ~/.zprofile ] || ! grep -q "brew shellenv" ~/.zprofile; then
    BREW="$(brew --prefix)/bin/brew"
    echo "eval \"\$($BREW shellenv)\"" >> ~/.zprofile
fi

# ── Brewfile ──────────────────────────────────────────────────────────────────
#
# See ~/.dotfiles/Brewfile

DOTFILES_DIR="$HOME/.dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"

divider
info "Running Brewfile..."

if [[ -f "$BREWFILE" ]]; then
    brew bundle --file="$BREWFILE"
else
    warn "No Brewfile found at $BREWFILE - skipping."
fi

# ── Dotfiles ──────────────────────────────────────────────────────────────────

divider
info "Setting up dotfiles..."

if [[ -d "$DOTFILES_DIR" ]]; then
    if ! command -v stow &>/dev/null; then
        error "Cannot find stow - add it to your Brewfile."
    fi

    # Stow each package directory (skip non-directories and bootstrap.sh itself)
    for pkg in "$DOTFILES_DIR"/*/; do
        pkg_name="$(basename "$pkg")"
        info "Stowing $pkg_name..."
        stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg_name" 2>/dev/null \
            || warn "Could not stow $pkg_name - skipping (conflict?)"
    done
else
    warn "Dotfiles not found at $DOTFILES_DIR - skipping."
fi

# ── Runtimes ──────────────────────────────────────────────────────────────────
#
# See ~/.dotfiles/mise/.config/mise/config.toml  

divider
info "Installing mise tools..."

eval "$(mise activate bash)"
mise install

JVM_LINK=/Library/Java/JavaVirtualMachines/openjdk.jdk
if [[ ! -L "$JVM_LINK" ]]; then
    info "Creating symlink to JVM for macOS integration"
    sudo ln -sfn $JAVA_HOME $JVM_LINK
else
    info "Symlink to JVM already exists - skipping."
fi

# ── macOS Defaults ────────────────────────────────────────────────────────────
#
# See ~/.dotfiles/macos.sh

MACOS_SH="$DOTFILES_DIR/macos.sh"

divider
info "Applying macOS system defaults..."

if [[ -f "$MACOS_SH" ]]; then
    sh "$DOTFILES_DIR/macos.sh"
else
    warn "macOS settings script not found at $MACOS_SH - skipping."
fi

# ── Git ───────────────────────────────────────────────────────────────────────
#
# See also ~/.dotfiles/git/.config/git/config

divider
info "Checking Git user..."

# Create .gitconfig file for user settings outside version control
touch ~/.gitconfig

# Git user mail is also used for SSH key
if ! git config --get user.email &>/dev/null; then
    info "Configuring Git user..."
    read -rp "  Enter your full name: " USER_NAME
    read -rp "  Enter your email    : " USER_EMAIL
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"
else
    USER_EMAIL="$(git config --get user.email)"
    info "Git user already configured - skipping."
fi

# ── SSH Key ───────────────────────────────────────────────────────────────────
#
# See also ~/.dotfiles/ssh/.ssh/config

divider
info "Checking SSH key..."

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
    # Generate key pair
    info "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$SSH_KEY"

    # Start SSH agent and add key to keychain
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$SSH_KEY"

    # Copy public key to clipboard
    pbcopy <  "$SSH_KEY.pub"
    info "Copied SSH public key to clipboard (add this to GitHub)"
else
    info "SSH key already exists - skipping."
fi

info "Checking Git signing key..."
if ! git config --get user.signingkey &>/dev/null; then
    info "Configuring Git signing key..."
    git config --global user.signingkey "$SSH_KEY"
else
    info "Git signing key already configured - skipping."
fi

# ── Done ──────────────────────────────────────────────────────────────────────

divider
echo ""
echo -e "${BOLD}${GREEN}✔ Bootstrap complete!${RESET}"
echo ""
echo "  Next steps:"
echo "  1. Add your SSH key to GitHub: https://github.com/settings/keys (cmd+doubkle-click to open)"
echo "  2. Open a new terminal session to load your shell config"
echo -e "  3. Run ${BOLD}~/bin/install-eclipse.sh${RESET} to install Eclipse"
echo -e "  4. Run ${BOLD}~/bin/install-claude-plugins.sh${RESET} to install Claude plugins and skills"
echo ""
