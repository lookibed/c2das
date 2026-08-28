#!/usr/bin/env bash
set -euo pipefail

source="${C2DAS_SYNC_SOURCE:?C2DAS_SYNC_SOURCE is required}"
mirror="${C2DAS_SYNC_MIRROR:?C2DAS_SYNC_MIRROR is required}"
case "$source" in /mnt/*) ;; *) echo "refusing source outside /mnt: $source" >&2; exit 64 ;; esac
case "$mirror" in /root/c2das-preflight-*) ;; *) echo "refusing unsafe mirror: $mirror" >&2; exit 64 ;; esac
mkdir -p "$mirror"
find "$mirror" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
(cd "$source" && tar --exclude=.git --exclude=target --exclude=.c2das-target -cf - .) | (cd "$mirror" && tar -xf -)
