#!/usr/bin/env bash
set -euo pipefail

echo "[*] Setting up environment..."

# sudo detection
if [[ $EUID -ne 0 ]]; then
  SUDO=sudo
else
  SUDO=""
fi

# ensure suvib exists
if [[ ! -f suvib ]]; then
  echo "[!] Error: suvib not found in current directory"
  exit 1
fi

# user data directory
DATA_DIR="$HOME/.suvib"
mkdir -p "$DATA_DIR"
touch "$DATA_DIR/links.txt" "$DATA_DIR/link_titles.txt"
echo "[*] Created data files in $DATA_DIR"

# install yt-dlp if missing
if ! command -v yt-dlp >/dev/null; then
  echo "[*] Installing yt-dlp..."
  curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
  chmod +x yt-dlp
  $SUDO install -m 755 yt-dlp /usr/local/bin/yt-dlp
else
  echo "[*] yt-dlp already installed"
fi

# install suvib properly
echo "[*] Installing suvib..."
chmod +x suvib
$SUDO install -m 755 suvib /usr/local/bin/suvib

echo "[*] Installation complete"
