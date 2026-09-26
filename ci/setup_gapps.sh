#!/usr/bin/env bash
# GApps. device/phh/treble/gapps.mk solo activa Google si existe uno de estos:
#   vendor/opengapps  <- openGApps (el que usamos)
#   vendor/google      <- Google Mobile Services oficiales
#   vendor/gapps       <- Pixel Experience gapps
# Ninguno viene en el manifiesto, hay que aportarlos.
set -euo pipefail

AOSP_DIR="${AOSP_DIR:-$HOME/aosp}"
GAPPS_VARIANT="${GAPPS_VARIANT:-pico}"

cd "$AOSP_DIR"

if [ -d vendor/opengapps/.git ]; then
  echo "==> vendor/opengapps ya existe, actualizando"
  git -C vendor/opengapps pull --ff-only || true
else
  echo "==> clonando openGApps -> vendor/opengapps"
  git clone --depth=1 https://github.com/opengapps/open_gapps vendor/opengapps
fi

# Elige la variante en el mk del arbol de dispositivos
MK="device/phh/treble/gapps.mk"
if grep -q 'GAPPS_VARIANT' "$MK"; then
  sed -i "s/^GAPPS_VARIANT :=.*/GAPPS_VARIANT := $GAPPS_VARIANT/" "$MK"
  echo "==> GAPPS_VARIANT := $GAPPS_VARIANT  (en $MK)"
else
  echo "AVISO: no encuentro GAPPS_VARIANT en $MK"
fi

echo "    Las APKs de Play Store las metes luego con la app Treble o MindTheGappsp"
