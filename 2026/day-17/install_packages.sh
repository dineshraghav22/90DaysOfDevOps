#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

PACKAGES=("nginx" "curl" "wget")

for pkg in "${PACKAGES[@]}"; do
    # Check if installed (works for both rpm and dpkg based systems)
    if rpm -q "$pkg" &>/dev/null || dpkg -s "$pkg" &>/dev/null 2>/dev/null; then
        echo "[SKIP] $pkg is already installed"
    else
        echo "[INSTALL] Installing $pkg..."
        if command -v yum &>/dev/null; then
            yum install -y "$pkg" &>/dev/null && echo "[OK] $pkg installed" || echo "[FAIL] Failed to install $pkg"
        elif command -v apt-get &>/dev/null; then
            apt-get install -y "$pkg" &>/dev/null && echo "[OK] $pkg installed" || echo "[FAIL] Failed to install $pkg"
        else
            echo "[FAIL] No package manager found"
        fi
    fi
done
