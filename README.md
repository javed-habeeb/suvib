# suvib

A lightweight Bash script to stream videos directly in VLC using [yt-dlp](https://github.com/yt-dlp/yt-dlp).
It fetches titles,caches them for faster replays, and gives you a simple numbered menu to pick from.
Actually an alias that points to the stream.sh and the file links.txt 

---

## Installation

Clone the repo and run:

```bash
./install.sh
```

---

## Usage
- Edit the links file
```
suvib --edit
```

- Add new url to links file
```
suvib --add [url1] [url2] ..
```
---

## Configuration
you should manually add the path to your vlc into stream.sh
- Linux/macOS: usually just `vlc`.
- Windows/WSL: something like `/mnt/c/Program Files/VideoLAN/VLC/vlc.exe`.

---

## Dependencies

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [dos2unix](https://waterlan.home.xs4all.nl/dos2unix.html) (optional)
- [VLC media player](https://www.videolan.org/vlc/)

---

## Notes

- `links.txt` is your personal playlist.
- `link_titles.txt` is auto-generated cache (don’t edit manually).
- This script does **not** bypass DRM or geo-blocking.
- No example URLs are included.
- Make sure to uncomment the package manager in the install.sh file for your distribution.eg:apt,pacman,brew
