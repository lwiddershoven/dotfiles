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


# ── Checks ────────────────────────────────────────────────────────────────────

divider
info "Checking Claude Code installed..."

if command -v claude &>/dev/null; then
    info "Found claude command..."
else
    error "Claude Code not installed - exiting."
fi

# ── Install plugins ───────────────────────────────────────────────────────────

divider
info "Installing plugins..."

add_claude_marketplace() {
  local repo="$1"
  local installed
  installed=$(claude plugin marketplace list --json | jq -r --arg repo "$repo" \
    '.[] | select(.repo == $repo) | .repo')

  if [[ -n "$installed" ]]; then
    info "Claude marketplace already added: ${repo}"
  else
    info "adding Claude marketplace: ${repo}..."
    claude plugin marketplace add "${repo}"
  fi
}

install_claude_plugin() {
  local plugin="$1"
  local installed
  installed=$(claude plugin list --json | jq -r --arg name "$plugin" \
    '.[] | select(.id | startswith($name + "@")) | .id')

  if [[ -n "$installed" ]]; then
    info "Claude plugin already installed: ${plugin}"
  else
    info "Installing Claude plugin: ${plugin}..."
    claude plugin install "${plugin}"
  fi
}

add_claude_marketplace anthropics/skills
add_claude_marketplace JuliusBrussee/caveman

install_claude_plugin claude-md-management
install_claude_plugin context7
install_claude_plugin frontend-design
install_claude_plugin skill-creator
install_claude_plugin superpowers
install_claude_plugin caveman

# ── Disable infrequently used plugins ─────────────────────────────────────────

divider
info "Disabling infrequently used plugins..."

disable_claude_plugin() {
  local plugin="$1"
  local enabled
  enabled=$(claude plugin list --json | jq -r --arg name "$plugin" \
    '.[] | select(.id | startswith($name + "@")) | .enabled')

  if [[ "$enabled" == "true" ]]; then
    info "Disabling Claude plugin: ${plugin}..."
    claude plugin disable "${plugin}"
  elif [[ "$enabled" == "false" ]]; then
    info "Claude plugin already disabled: ${plugin}"
  else
    warn "Claude plugin not found: ${plugin}"
  fi
}

disable_claude_plugin frontend-design

# ── List installed plugins ────────────────────────────────────────────────────

divider
info "Installed plugins:"

claude plugin list | tail +2

# ── Done ──────────────────────────────────────────────────────────────────────

divider
echo ""
echo -e "${BOLD}${GREEN}✔ Claude Code setup complete!${RESET}"
echo ""
