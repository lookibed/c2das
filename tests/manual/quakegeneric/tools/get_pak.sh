#!/usr/bin/env bash
# Fetch the Quake 1.06 shareware release and extract its id1/pak0.pak into
# fixtures/id1/pak0.pak of this corpus.  The pak is not committed: see
# ../UPSTREAM.md for its licence terms.
#
# Needs curl, python3 (to open the zip) and the LHA extractor lhasa, which
# unpacks resource.1, the release's LHA archive.  Override with:
#   QUAKE106_URL  the quake106.zip to download
#   LHASA         the lhasa executable (default: lhasa from PATH)
#   QUAKE_PAK_DIR the directory that receives id1/pak0.pak
#                 (default: the corpus's fixtures/)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="${QUAKE106_URL:-https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake/quake106.zip}"
LHASA="${LHASA:-lhasa}"
OUT="${QUAKE_PAK_DIR:-$HERE/../fixtures}"

ZIP_SHA1=f8a1a509b094ccdbed3c54b96f7d9b351c0898f5
PAK_SHA1=36b42dc7b6313fd9cabc0be8b9e9864840929735

if [ -f "$OUT/id1/pak0.pak" ] && echo "$PAK_SHA1  $OUT/id1/pak0.pak" | sha1sum -c --status; then
    echo "$OUT/id1/pak0.pak: present, sha1 $PAK_SHA1"
    exit 0
fi
command -v "$LHASA" >/dev/null || {
    echo "get_pak.sh: '$LHASA' not found; install lhasa or set LHASA" >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir "$WORK/dl" "$WORK/x"

curl -fsSL -o "$WORK/dl/quake106.zip" "$URL"
echo "$ZIP_SHA1  $WORK/dl/quake106.zip" | sha1sum -c --status || {
    echo "get_pak.sh: quake106.zip sha1 mismatch (want $ZIP_SHA1)" >&2
    exit 1
}
python3 -I -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extract("resource.1", sys.argv[2])' \
    "$WORK/dl/quake106.zip" "$WORK/x"
(cd "$WORK/x" && "$LHASA" xq resource.1 id1/pak0.pak)
echo "$PAK_SHA1  $WORK/x/id1/pak0.pak" | sha1sum -c --status || {
    echo "get_pak.sh: pak0.pak sha1 mismatch (want $PAK_SHA1)" >&2
    exit 1
}
mkdir -p "$OUT/id1"
mv "$WORK/x/id1/pak0.pak" "$OUT/id1/pak0.pak"
chmod 644 "$OUT/id1/pak0.pak"
echo "$OUT/id1/pak0.pak: fetched, sha1 $PAK_SHA1"
