#!/usr/bin/env bash
set -e

sudo rm -f /usr/local/bin/suvib

read -rp "Remove user data (~/.local/share/suvib)? (y/N): " yn
[[ $yn =~ ^[Yy]$ ]] && rm -rf ~/.local/share/suvib

echo "Uninstalled suvib"
