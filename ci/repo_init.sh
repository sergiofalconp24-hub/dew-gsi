#!/usr/bin/env bash
# repo init + local_manifest
set -euo pipefail

AOSP_DIR="${AOSP_DIR:-$HOME/aosp}"
MANIFEST_URL="${MANIFEST_URL:-https://github.com/sergiofalconp24-hub/EvoX_treble}"
MANIFEST_REF="${MANIFEST_REF:-16.2}"

echo "==> repo init ($MANIFEST_URL @ $MANIFEST_REF)"
mkdir -p "$AOSP_DIR"
cd "$AOSP_DIR"

if [ ! -d .repo ]; then
  repo init \
    -u "$MANIFEST_URL" \
    -b "$MANIFEST_REF" \
    --depth=1 \
    -g "$(git config --global user.email)" \
    -g "$(git config --global user.name)"
else
  echo "    .repo ya existe, no se re-inicializa"
fi

echo "==> instalando local_manifest.xml"
mkdir -p .repo/local_manifests
if [ -f "$GITHUB_WORKSPACE/local_manifest.xml" ]; then
  cp "$GITHUB_WORKSPACE/local_manifest.xml" .repo/local_manifests/
elif [ -f "$HOME/gsi/local_manifest.xml" ]; then
  cp "$HOME/gsi/local_manifest.xml" .repo/local_manifests/
else
  echo "ERROR: no encuentro local_manifest.xml" >&2
  exit 1
fi
cat .repo/local_manifests/local_manifest.xml
