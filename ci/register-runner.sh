#!/usr/bin/env bash
# Registra esta maquina como self-hosted runner de GitHub Actions.
# Se ejecuta EN EL VPS (no en tu PC).
#
#   bash ci/register-runner.sh sergiofalconp24-hub dew-gsi
#
# Necesita el token de registro, que caduca a la hora. Si no se lo pasas,
# lo pide con gh y lo genera al momento.
set -euo pipefail

OWNER="${1:-sergiofalconp24-hub}"
REPO="${2:-dew-gsi}"
LABELS="${RUNNER_LABELS:-linux,x64,dew-gsi}"

echo "==> descargando el runner"
mkdir -p "$HOME/actions-runner" && cd "$HOME/actions-runner"

VER=2.321.0
URL="https://github.com/actions/runner/releases/download/v${VER}/actions-runner-linux-x64-${VER}.tar.gz"

if [ ! -x ./config.sh ]; then
  curl -fsSL -o runner.tar.gz "$URL"
  tar xzf runner.tar.gz
  rm runner.tar.gz
fi
chmod +x run.sh config.sh 2>/dev/null || true

echo "==> generando token de registro (caduca en 1 h)"
if [ -n "${RUNNER_TOKEN:-}" ]; then
  TOKEN="$RUNNER_TOKEN"
elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  TOKEN="$(gh api -X POST "repos/$OWNER/$REPO/actions/runners/registration-token" -q .token)"
else
  echo "No encuentro gh ni RUNNER_TOKEN."
  echo "Genera tu token aqui y exportalo:"
  echo "  https://github.com/$OWNER/$REPO/settings/actions/runners/new"
  echo "  export RUNNER_TOKEN=<pega el token>"
  exit 1
fi

echo "==> configurando el runner"
./config.sh \
  --url "https://github.com/$OWNER/$REPO" \
  --token "$TOKEN" \
  --name "dew-$(hostname)" \
  --labels "$LABELS" \
  --work "_work" \
  --replace

cat <<'EOF'

==> Listo. Para arrancarlo:

  cd ~/actions-runner
  ./run.sh

O como servicio (recomendado en un VPS, para que sobreviva a reinicios):

  sudo ./svc.sh install
  sudo ./svc.sh start
  sudo ./svc.sh status

Despues, en tu PC:  gh workflow run build-gsi.yml --repo OWNER/REPO
EOF
