#!/usr/bin/env bash
# Descarga/actualiza el arbol de AOSP
set -euo pipefail

AOSP_DIR="${AOSP_DIR:-$HOME/aosp}"
cd "$AOSP_DIR"

echo "==> repo sync -c -j8 --fail-fast"
echo "    (la primera vez descarga ~120 GB y tarda varias horas)"
repo sync -c -j8 --fail-fast

echo "==> arbol descargado:"
du -sh "$AOSP_DIR" .repo 2>/dev/null || true
df -h "$AOSP_DIR" | tail -1
