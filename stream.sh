#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# paths
# ---------------------------
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/suvib"
EPISODE_FILE="$DATA_DIR/links.txt"
TITLE_CACHE="$DATA_DIR/link_titles.txt"
TMP_CACHE_UPDATE="$DATA_DIR/._new_titles.tmp"

mkdir -p "$DATA_DIR"
touch "$EPISODE_FILE" "$TITLE_CACHE"

# ---------------------------
# dependencies
# ---------------------------
if ! command -v yt-dlp >/dev/null; then
    echo "yt-dlp is not installed"
    exit 1
fi

VLC_PATH="$(command -v vlc || true)"
if [[ -z "$VLC_PATH" ]]; then
    echo "vlc not found in PATH"
    exit 1
fi

EDITOR="${EDITOR:-nano}"

# ---------------------------
# commands
# ---------------------------
case "${1:-}" in
    --edit)
        "$EDITOR" "$EPISODE_FILE"
        exit 0
        ;;

    --add)
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: suvib --add <URL> [URL...]"
            exit 1
        fi

        for url in "$@"; do
            if grep -Fxq "$url" "$EPISODE_FILE"; then
                echo "skipped (exists): $url"
                continue
            fi
            echo "$url" >> "$EPISODE_FILE"
            echo "added: $url"
        done
        exit 0
        ;;
esac

# ---------------------------
# streaming logic (your code)
# ---------------------------

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

mapfile -t EPISODES < <(grep -v '^\s*$' "$EPISODE_FILE")

if [[ ${#EPISODES[@]} -eq 0 ]]; then
    echo "No links found. Use: suvib --add <URL>"
    exit 1
fi

declare -A TITLE_MAP

if [[ -f "$TITLE_CACHE" ]]; then
    while IFS= read -r line; do
        URL="${line%%:::*}"
        TITLE="${line#*:::}"
        [[ -n "$URL" && -n "$TITLE" ]] && TITLE_MAP["$URL"]="$TITLE"
    done < "$TITLE_CACHE"
fi

> "$TMP_CACHE_UPDATE"

printf "%s\n" "${logo[@]}"
for i in "${!EPISODES[@]}"; do
    URL="${EPISODES[$i]}"

    if [[ -z "${TITLE_MAP[$URL]+x}" ]]; then
        TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "[Unknown]")
        TITLE_MAP["$URL"]="$TITLE"
        echo "$URL:::$TITLE" >> "$TMP_CACHE_UPDATE"
    else
        TITLE="${TITLE_MAP[$URL]}"
    fi

    printf "%2d) %s\n" $((i + 1)) "$TITLE"
done

[[ -s "$TMP_CACHE_UPDATE" ]] && awk '!seen[$0]++' "$TMP_CACHE_UPDATE" >> "$TITLE_CACHE"
rm -f "$TMP_CACHE_UPDATE"

read -rp "choose episode number: " CHOICE
(( CHOICE >= 1 && CHOICE <= ${#EPISODES[@]} )) || exit 1

URL="${EPISODES[$((CHOICE - 1))]}"

STREAM_URL=$(yt-dlp -f "best[ext=mp4][protocol^=http]" -g "$URL")
"$VLC_PATH" --fullscreen --no-video-title-show "$STREAM_URL"
