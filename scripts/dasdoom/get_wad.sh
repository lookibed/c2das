#!/usr/bin/env bash
# Download the shareware Doom IWAD (doom1.wad, Doom 1.9 shareware) and check it.
#
# usage: tools/get_wad.sh [destination]     (default: ./doom1.wad)
#
# The WAD is id Software's freely redistributable shareware episode; it is not
# part of this repository.  The archive and the extracted WAD are both pinned
# by SHA-1, so a changed mirror fails instead of handing over another file.
set -euo pipefail

URL="${DOOM_WAD_URL:-https://www.jbserver.com/downloads/games/doom/misc/shareware/doom1.wad.zip}"
ZIP_SHA1="4c5d94be6b6371736831e215912ea8094068d629"
WAD_SHA1="5b2e249b9c5133ec987b3ea77596381dc0d6bc1d"   # doom1.wad, shareware 1.9 (4 196 020 bytes)
dest="${1:-doom1.wad}"

sha1_of() {
    if command -v sha1sum >/dev/null 2>&1; then sha1sum "$1" | cut -d' ' -f1
    else shasum -a 1 "$1" | cut -d' ' -f1; fi
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsSL -o "$work/doom1.wad.zip" "$URL"
got="$(sha1_of "$work/doom1.wad.zip")"
[[ "$got" == "$ZIP_SHA1" ]] || { echo "archive SHA-1 $got, expected $ZIP_SHA1" >&2; exit 1; }

if command -v unzip >/dev/null 2>&1; then
    unzip -q -o "$work/doom1.wad.zip" DOOM1.WAD -d "$work"
else
    python3 -I -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extract("DOOM1.WAD", sys.argv[2])' \
        "$work/doom1.wad.zip" "$work"
fi
got="$(sha1_of "$work/DOOM1.WAD")"
[[ "$got" == "$WAD_SHA1" ]] || { echo "WAD SHA-1 $got, expected $WAD_SHA1" >&2; exit 1; }

mv "$work/DOOM1.WAD" "$dest"
echo "doom1.wad (shareware 1.9, SHA-1 $WAD_SHA1) -> $dest"
