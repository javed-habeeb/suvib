#!/bin/bash


#stream using VLC
VLC_PATH="" #add the path to vlc
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EPISODE_FILE="$SCRIPT_DIR/links.txt"

logo=(
"  ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓███████▓▒░  "
" ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  "
" ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  "
"  ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░   "
"        ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  "
"        ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  "
" ░▒▓███████▓▒░ ░▒▓██████▓▒░   ░▒▓██▓▒░  ░▒▓█▓▒░▒▓███████▓▒░   "
"                                                             "
"~~~~~~~|      A STREAMER FROM PROVIDED LINKS     |~~~~~~~~~~"
)                                                            



if command -v dos2unix >/dev/null 2>&1; then
    dos2unix "$EPISODE_FILE" >/dev/null 2>&1
fi

TITLE_CACHE="$SCRIPT_DIR/link_titles.txt"
TMP_CACHE_UPDATE="$SCRIPT_DIR/._new_titles.tmp"


#checking if yt-dlp is available
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "yt-dlp is not installed"
    exit 1
fi

#check if vlc path is valid
if [[ ! -f "$VLC_PATH" ]]; then
    echo "vlc not found at $VLC_PATH"
    exit 1
fi

#if episodes list exists
if [[ ! -f "$EPISODE_FILE" ]]; then
    echo "episodes.txt not found. add url's to it"
    exit 1
fi

#load episodes list
mapfile -t EPISODES < <(grep -v '^\s*$' "$EPISODE_FILE")

#declare associative array for URL -> title
declare -A TITLE_MAP

#load if cache exists
if [[ -f "$TITLE_CACHE" ]]; then
    while IFS= read -r line; do
        CLEAN=$(echo "$line" | tr -d '\r' | xargs)
        URL="${CLEAN%%:::*}"
        TITLE="${CLEAN#*:::}"
        [[ -n "$URL" && -n "$TITLE" ]] && TITLE_MAP["$URL"]="$TITLE"
    done < "$TITLE_CACHE"
fi

#prepare new title file
> "$TMP_CACHE_UPDATE"

#display the numbered menu
printf "%s\n" "${logo[@]}"
for i in "${!EPISODES[@]}"; do
    URL="$(echo "${EPISODES[$i]}" | tr -d '\r' | xargs)"

    if [[ -z "${TITLE_MAP[$URL]+found}" ]]; then
        echo "[debug] title for $URL NOT in cache. fetching via yt-dlp"
        TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "[Unknown Title]")
        [[ -z "$TITLE" ]] && TITLE="[unsupported or offline]"
        TITLE_MAP["$URL"]="$TITLE"
        echo "$URL:::$TITLE" >> "$TMP_CACHE_UPDATE"
    else
        TITLE="${TITLE_MAP[$URL]}"
    fi

    printf "%2d) %s\n" $((i + 1)) "$TITLE"
done

#append only newer entries
if [[ -s "$TMP_CACHE_UPDATE" ]]; then
    awk '!seen[$0]++' "$TMP_CACHE_UPDATE" >> "$TITLE_CACHE"

fi

rm -f "$TMP_CACHE_UPDATE"


#selection prompt
read -p "choose episode number: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || (( CHOICE < 1 || CHOICE > ${#EPISODES[@]} )); then
    echo "invalid choice"
    exit 1
fi

URL="${EPISODES[$((CHOICE - 1))]}"

echo "extracting stream from: $URL"
STREAM_URL=$(yt-dlp -f "best[ext=mp4][protocol^=http]" -g "$URL" 2>/dev/null)

if [[ -z "$STREAM_URL" ]]; then
    echo "Stream extraction failed"
    exit 1
fi

echo "playing vlc..."
"$VLC_PATH" --fullscreen --no-video-title-show "$STREAM_URL"

