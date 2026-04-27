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
info "Checking Ollama installed..."

if command -v ollama &>/dev/null; then
    info "Found ollama command..."
else
    error "Ollama not installed - exiting."
fi

# ── Start Ollama ───────────────────────────────────────────────────────────────

divider

OLLAMA_HOST="http://127.0.0.1:11434"
OLLAMA_PID=""

cleanup() {
    if [[ -n "${OLLAMA_PID}" ]]; then
        divider
        info "Stopping ollama (PID ${OLLAMA_PID})..."
        kill "${OLLAMA_PID}" 2>/dev/null || true
        wait "${OLLAMA_PID}" 2>/dev/null || true
    fi
}

# Ensure cleanup runs on script exit
trap cleanup EXIT INT TERM

# Start Ollama serve
if ! curl -s "${OLLAMA_HOST}/api/tags" >/dev/null 2>&1; then
    info "Starting Ollama serve..."
    ollama serve > /dev/null 2>&1  &
    OLLAMA_PID=$!

    # Wait until Ollama ready
    until curl -s "${OLLAMA_HOST}/api/tags" >/dev/null 2>&1; do
        sleep 0.5
    done
else
    info "Ollama already running - skipping ollamas serve."
fi

# ── Configuring model parameters ──────────────────────────────────────────────

divider
info "Configure model parameters..."

MODEL=qwen2.5-coder:32b
CONFIG=$(cat <<EOF
{
  "model": "${MODEL}",
  "stream": true,
  "options": {
    "num_ctx": 65536,
    "temperature": 0.15,
    "num_predict": 4096,
    "repeat_penalty": 1.12
  }
}
EOF
)

RESPONSE=$(curl "${OLLAMA_HOST}/api/generate" -d "${CONFIG}" 2> /dev/null)
DONE=$(echo "${RESPONSE}" | jq -r '.done')

if [[ ! "${DONE}" = "true" ]]; then
    error "Could not set parameters - exiting.\nresponse: ${RESPONSE}\n"
fi

# ── Launch Claude ─────────────────────────────────────────────────────────────

divider
info "Running ollama launch claude ${MODEL}..."
ollama launch claude --model "${MODEL}"
