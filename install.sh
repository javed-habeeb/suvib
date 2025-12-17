#!/usr/bin/env bash
set -e

sudo install -m 755 stream.sh /usr/local/bin/suvib

echo "Installed suvib to /usr/local/bin"
echo "User data will be stored in ~/.local/share/suvib"
