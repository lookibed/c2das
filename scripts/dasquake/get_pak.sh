#!/usr/bin/env bash
# Download the Quake 1.06 shareware release and extract its id1/pak0.pak.
#
# usage: tools/get_pak.sh [base-dir]     (default: the repository root;
#                                         writes <base-dir>/id1/pak0.pak)
#
# The pak is id Software's shareware game data, distributable only as part of
# the whole release (see NOTICE), so it is not part of this repository.  The
# release archive and the extracted pak are both pinned by SHA-1.
#
# Needs curl, python3 (to open the zip) and the LHA extractor lhasa, which
# unpacks resource.1, the release's LHA archive.  Override with:
#   QUAKE106_URL  the quake106.zip to download
#   LHASA         the lhasa executable (default: lhasa from PATH)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="${QUAKE106_URL:-https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake/quake106.zip}"
LHASA="${LHASA:-lhasa}"
out="${1:-$here/..}"

ZIP_SHA1=f8a1a509b094ccdbed3c54b96f7d9b351c0898f5
PAK_SHA1=36b42dc7b6313fd9cabc0be8b9e9864840929735

sha1_of() {
    if command -v sha1sum >/dev/null 2>&1; then sha1sum "$1" | cut -d' ' -f1
    else shasum -a 1 "$1" | cut -d' ' -f1; fi
}

if [[ -f "$out/id1/pak0.pak" && "$(sha1_of "$out/id1/pak0.pak")" == "$PAK_SHA1" ]]; then
    echo "$out/id1/pak0.pak: present, SHA-1 $PAK_SHA1"
    exit 0
fi
command -v "$LHASA" >/dev/null || { echo "get_pak.sh: '$LHASA' not found; install lhasa or set LHASA" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/dl" "$work/x"

curl -fsSL -o "$work/dl/quake106.zip" "$URL"
got="$(sha1_of "$work/dl/quake106.zip")"
[[ "$got" == "$ZIP_SHA1" ]] || { echo "archive SHA-1 $got, expected $ZIP_SHA1" >&2; exit 1; }
python3 -I -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extract("resource.1", sys.argv[2])' \
    "$work/dl/quake106.zip" "$work/x"
(cd "$work/x" && "$LHASA" xq resource.1 id1/pak0.pak)
got="$(sha1_of "$work/x/id1/pak0.pak")"
[[ "$got" == "$PAK_SHA1" ]] || { echo "pak0.pak SHA-1 $got, expected $PAK_SHA1" >&2; exit 1; }

mkdir -p "$out/id1"
mv "$work/x/id1/pak0.pak" "$out/id1/pak0.pak"
chmod 644 "$out/id1/pak0.pak"
echo "id1/pak0.pak (Quake 1.06 shareware, SHA-1 $PAK_SHA1) -> $out/id1/pak0.pak"
