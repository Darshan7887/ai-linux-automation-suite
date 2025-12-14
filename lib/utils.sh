#!/bin/bash

# ============================================
# utils.sh
# Common helper functions
# ============================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_command() {
    if ! command_exists "$1"; then
        echo "Required command not found: $1"
        exit 1
    fi
}

ensure_directory() {
    [ -d "$1" ] || mkdir -p "$1"
}
