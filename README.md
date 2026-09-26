# dew-gsi

Construye una GSI de **Android 16 (QPR)** para el **POCO C75 / `dew`** (MT6769, Helio G99)
a partir del árbol de dispositivos Treble, en un runner self-hosted.

## Por qué self-hosted

Un build de GSI de Android 16 necesita **~32 GB de RAM**. El runner hosted más grande de
GitHub (`ubuntu-latest-4-cores`) tiene **16 GB**, y se queda sin memoria a mitad de
compilación. Por eso este workflow **no** corre en `ubuntu-latest`.

El kernel sí cabía en 16 GB (ver `sergiofalconp24-hub/dew-kernel`), el árbol completo de
AOSP no.

**Maquina mínima del runner:** 16 núcleos, 32 GB RAM, 250 GB SSD/NVMe, Ubuntu 22.04 o 24.04.
Hetzner AX41 (~15 €/mes) cumple de sobra.

## Puesta en marcha

### 1. En el VPS

```bash
git clone https://github.com/sergiofalconp24-hub/dew-gsi.git
cd dew-gsi
chmod +x ci/*.sh
bash ci/register-runner.sh sergiofalconp24-hub dew-gsi
```

Eso descarga el runner, genera el token de registro y lo deja listo. Si no tienes `gh`
instalado en el VPS, pídeselo tú en
<https://github.com/sergiofalconp24-hub/dew-gsi/settings/actions/runners/new>
y exporta `RUNNER_TOKEN=<token>`.

Para que arranque solo tras un reinicio:

```bash
sudo ~/actions-runner/svc.sh install
sudo ~/actions-runner/svc.sh start
```

### 2. Disparar un build

```bash
gh workflow run build-gsi.yml --repo sergiofalconp24-hub/dew-gsi
gh run watch --repo sergiofalconp24-hub/dew-gsi
```

O desde la web: pestaña **Actions** → **build-gsi-dew** → *Run workflow*.

La primera vez marca **"Solo repo sync"** para descargar el árbol (~120 GB, varias horas)
sin compilar. Luego el build real.

### Entradas del workflow

| Input | Por defecto | Para qué |
|---|---|---|
| `target` | `treble_arm64_abgN-userdebug` | arm64 + A/B + GApps + sin root embebido |
| `jobs` | `12` | Threads de compilación (usa la mitad de los núcleos) |
| `gapps` | `pico` | Variante de openGApps (la más ligera) |
| `sync_only` | `no` | `si` = solo descarga el árbol |

## Repos

| | |
|---|---|
| Manifiesto | [`sergiofalconp24-hub/EvoX_treble`](https://github.com/sergiofalconp24-hub/EvoX_treble) @ `16.2` (fork de Doze-off) |
| Árbol de dispositivos | [`sergiofalconp24-hub/device_phh_treble-doze`](https://github.com/sergiofalconp24-hub/device_phh_treble-doze) @ `android-16.0` (fork de Doze-off) |
| GApps | [`opengapps/open_gapps`](https://github.com/opengapps/open_gapps) → `vendor/opengapps` |

Los forks son tuyos: para cambiar algo del sistema, edita `device/phh_treble-doze` y
despacha a la rama `build-*`, que dispara el workflow.

## Scripts

| Script | Qué hace |
|---|---|
| `ci/repo_init.sh` | `repo init` + instala `local_manifest.xml` |
| `ci/repo_sync.sh` | `repo sync -c -j8` |
| `ci/setup_gapps.sh` | Clona openGApps y fija `GAPPS_VARIANT` |
| `ci/build_system.sh` | `lunch` + `make` con ccache |
| `ci/register-runner.sh` | Registra el VPS como runner |

## Flash en el móvil

```bash
xz -d imagen.img.xz                      # si viene comprimido
adb reboot bootloader
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img
fastboot flash system imagen.img
fastboot reboot
```

Y en el móvil: **Ajustes → Sistema → Borrar datos** (format data, obligatorio tras cambiar
de partición).
