#!/bin/sh
# basic install script

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run as root (use sudo)." >&2
  exit 1
fi

PREFIX="${PREFIX:-/usr}"

BINDIR="${PREFIX}/bin"
SHAREDIR="${PREFIX}/share/prboom-rt"
APPLICATIONSDIR="${PREFIX}/share/applications"
ICONDIR="${PREFIX}/share/icons/hicolor/scalable/apps"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing prboom-plus-rt to ${PREFIX}..."

if [ -f "${SCRIPT_DIR}/prboom-plus-rt" ]; then
  install -m 755 "${SCRIPT_DIR}/prboom-plus-rt" "${BINDIR}/prboom-plus-rt"
  echo "  Installed binary: ${BINDIR}/prboom-plus-rt"
else
  echo "  WARNING: prboom-plus-rt binary not found, skipping."
fi

if [ -f "${SCRIPT_DIR}/libRayTracedGL1.so" ]; then
  install -m 644 "${SCRIPT_DIR}/libRayTracedGL1.so" "${BINDIR}/libRayTracedGL1.so"
  echo "  Installed library: ${BINDIR}/libRayTracedGL1.so"
else
  echo "  WARNING: libRayTracedGL1.so not found, skipping."
fi

if [ -f "${SCRIPT_DIR}/dist/prboom-rt-launcher" ]; then
  install -m 755 "${SCRIPT_DIR}/dist/prboom-rt-launcher" "${BINDIR}/prboom-rt-launcher"
  echo "  Installed launcher: ${BINDIR}/prboom-rt-launcher"
else
  echo "  WARNING: dist/prboom-rt-launcher not found, skipping."
fi

if [ -d "${SCRIPT_DIR}/ovrd" ]; then
  mkdir -p "${SHAREDIR}"
  cp -r "${SCRIPT_DIR}/ovrd" "${SHAREDIR}/"
  echo "  Installed ovrd data: ${SHAREDIR}/ovrd/"
else
  echo "  WARNING: ovrd/ directory not found, skipping."
fi

HAVE_DOOM_OVRD=false
HAVE_DOOM2_OVRD=false
[ -d "${SCRIPT_DIR}/doom/ovrd" ] && HAVE_DOOM_OVRD=true
[ -d "${SCRIPT_DIR}/doom2/ovrd" ] && HAVE_DOOM2_OVRD=true

if [ "$HAVE_DOOM_OVRD" = true ] || [ "$HAVE_DOOM2_OVRD" = true ]; then
  printf "Install per-game ovrd folders for Doom and Doom II? [y/N] "
  read -r REPLY
  case "$REPLY" in
    [yY]|[yY][eE][sS])
      if [ "$HAVE_DOOM_OVRD" = false ] || [ "$HAVE_DOOM2_OVRD" = false ]; then
        echo "  ERROR: Both doom/ovrd and doom2/ovrd must be present."
        echo "  Set them up first (see the Doom II section in README.md), then re-run."
        exit 1
      fi
      mkdir -p "${SHAREDIR}"
      cp -r "${SCRIPT_DIR}/doom" "${SHAREDIR}/doom"
      cp -r "${SCRIPT_DIR}/doom2" "${SHAREDIR}/doom2"
      echo "  Installed: ${SHAREDIR}/doom/ovrd/"
      echo "  Installed: ${SHAREDIR}/doom2/ovrd/"

      # prompt to copy IWADs if present
      HAVE_DOOM_WAD=false
      HAVE_DOOM2_WAD=false
      [ -f "${SCRIPT_DIR}/DOOM.WAD" ] && HAVE_DOOM_WAD=true
      [ -f "${SCRIPT_DIR}/DOOM2.WAD" ] && HAVE_DOOM2_WAD=true
      [ -f "${SCRIPT_DIR}/doom.wad" ] && HAVE_DOOM_WAD=true
      [ -f "${SCRIPT_DIR}/doom2.wad" ] && HAVE_DOOM2_WAD=true

      if [ "$HAVE_DOOM_WAD" = true ] || [ "$HAVE_DOOM2_WAD" = true ]; then
        printf "  Also copy your IWAD files to ${SHAREDIR}? [y/N] "
        read -r REPLY
        case "$REPLY" in
          [yY]|[yY][eE][sS])
            if [ "$HAVE_DOOM_WAD" = true ]; then
              WAD_SRC="${SCRIPT_DIR}/DOOM.WAD"
              [ -f "$WAD_SRC" ] || WAD_SRC="${SCRIPT_DIR}/doom.wad"
              install -m 644 "$WAD_SRC" "${SHAREDIR}/"
              echo "  Copied $(basename "$WAD_SRC")"
            fi
            if [ "$HAVE_DOOM2_WAD" = true ]; then
              WAD_SRC="${SCRIPT_DIR}/DOOM2.WAD"
              [ -f "$WAD_SRC" ] || WAD_SRC="${SCRIPT_DIR}/doom2.wad"
              install -m 644 "$WAD_SRC" "${SHAREDIR}/"
              echo "  Copied $(basename "$WAD_SRC")"
            fi
            ;;
          *)
            echo "  Skipping IWAD copy."
            ;;
        esac
      fi
      ;;
    *)
      echo "  Skipping per-game ovrd install."
      ;;
  esac
fi

if [ -f "${SCRIPT_DIR}/prboom-plus.wad" ]; then
  mkdir -p "${SHAREDIR}"
  install -m 644 "${SCRIPT_DIR}/prboom-plus.wad" "${SHAREDIR}/prboom-plus.wad"
  echo "  Installed WAD: ${SHAREDIR}/prboom-plus.wad"
else
  echo "  WARNING: prboom-plus.wad not found, skipping."
fi

if [ -f "${SCRIPT_DIR}/dist/detect-rt.sh" ]; then
  mkdir -p "${SHAREDIR}"
  install -m 755 "${SCRIPT_DIR}/dist/detect-rt.sh" "${SHAREDIR}/detect-rt.sh"
  echo "  Installed detect script: ${SHAREDIR}/detect-rt.sh"
else
  echo "  WARNING: dist/detect-rt.sh not found, skipping."
fi

if [ -f "${SCRIPT_DIR}/dist/prboom-plus-rt.desktop" ]; then
  mkdir -p "${APPLICATIONSDIR}"
  install -m 644 "${SCRIPT_DIR}/dist/prboom-plus-rt.desktop" "${APPLICATIONSDIR}/prboom-plus-rt.desktop"
  echo "  Installed desktop file: ${APPLICATIONSDIR}/prboom-plus-rt.desktop"
else
  echo "  WARNING: dist/prboom-plus-rt.desktop not found, skipping."
fi

if [ -f "${SCRIPT_DIR}/dist/icons/prboom-plus.svg" ]; then
  mkdir -p "${ICONDIR}"
  install -m 644 "${SCRIPT_DIR}/dist/icons/prboom-plus.svg" "${ICONDIR}/prboom-plus-rt.svg"
  echo "  Installed icon: ${ICONDIR}/prboom-plus-rt.svg"
else
  echo "  WARNING: dist/icons/prboom-plus.svg not found, skipping."
fi

echo ""
echo "Installation complete!"
echo ""
echo "Run 'prboom-plus-rt' to launch, or use 'prboom-rt-launcher' for IWAD selection."
echo "Put your IWAD files (DOOM.WAD, DOOM2.WAD, etc.) in ${SHAREDIR}"
echo "or in the same directory as the executable."
