#!/bin/bash

set -e

echo "[*] setting up the environment...."

touch links.txt link_titles.txt
echo "[*] created links.txt and link_titles.txt (if they didnt exist)"

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
chmod +x yt-dlp
sudo mv yt-dlp /usr/local/bin/
echo "[*]yt-dlp installed.."

#uncomment the line depending on your system
#sudo apt update && sudo apt install -y dos2unix
#sudo pacman -S --noconfirm dos2unix
#brew install dos2unix

echo "[*] remember to install dos2unix manually if you skip the lines above"

echo "[*] symlink suvib to /usr/local/bin/"
sudo ln -s "$(pwd)/suvib" /usr/local/bin/suvib 
echo "[*] done"

echo "[*] installation complete"
