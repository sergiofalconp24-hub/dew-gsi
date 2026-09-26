#!/usr/bin/env bash
# Compila la imagen del sistema.
#
# OJO: el target 'bacon' que usan los builders de TrebleDroid NO existe en este
# arbol de dispositivos (vive en el repo de builders de phhusson, que no esta en
# el manifiesto). Asi que compilamos el product del sistema directamente, que es
# lo que produce el system.img que se flashea.
set -euo pipefail

AOSP_DIR="${AOSP_DIR:-$HOME/aosp}"
TARGET="${TARGET:-treble_arm64_abgN-userdebug}"
JOBS="${JOBS:-12}"
CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"

cd "$AOSP_DIR"

export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"
export CCACHE_DIR
export USE_CCACHE=1
export CCACHE_COMPRESS=1
mkdir -p "$CCACHE_DIR"

echo "==> lunch $TARGET"
source build/envsetup.sh
lunch "$TARGET"

echo "==> ccache"
ccache -s || true
ccache -M 50G || true

echo "==> make -j$JOBS  (esto son varias horas)"
time m -j"$JOBS" "$TARGET"

echo
echo "==> Resultado:"
find out/target/product -maxdepth 3 \
     \( -name '*.img.xz' -o -name 'system.img' \) -exec ls -lh {} \; 2>/dev/null || true

cat <<'EOF'

Para flashearlo en el POCO C75:

  # descomprime si es .img.xz
  xz -d <imagen>.img.xz

  adb reboot bootloader
  fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
  fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img
  fastboot flash system imagen.img
  fastboot reboot
  # y en el movil: Ajustes > Sistema > Borrar datos (format data)
EOF
