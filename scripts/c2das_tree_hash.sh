#!/usr/bin/env bash
set -euo pipefail

root="${C2DAS_TREE_ROOT:?C2DAS_TREE_ROOT is required}"
case "$root" in
    /mnt/*|/root/c2das-preflight-*) ;;
    *) echo "refusing to hash an unapproved tree: $root" >&2; exit 64 ;;
esac
cd "$root"
find . -type f ! -path './.git/*' ! -path './target/*' ! -path './.c2das-target/*' ! -name '.c2das-sync-manifest' -print0 \
  | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
