#!/usr/bin/env bash
set -euo pipefail

# install-buildx.sh
# Download and install docker buildx plugin from GitHub releases
# Installs to ~/.docker/cli-plugins/docker-buildx if not running as root,
# otherwise to /usr/local/lib/docker/cli-plugins/docker-buildx

ARCH_MAP() {
  case "$(uname -m)" in
    x86_64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    armv7l) echo arm-v7 ;;
    i386|i686) echo 386 ;;
    *) echo "$(uname -m)" ;;
  esac
}

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Required command '$1' not found" >&2; exit 2; }
}

ensure_cmd curl
ensure_cmd uname
ensure_cmd mktemp

ARCH=$(ARCH_MAP)
OS=linux

echo "Detected arch: $ARCH"

# determine latest tag
echo "Resolving latest buildx release..."
TAG=$(curl -sI https://github.com/docker/buildx/releases/latest | awk -F"/" '/location/ {print $NF}' | tr -d '\r')
if [ -z "$TAG" ]; then
  echo "Failed to resolve latest release tag, aborting" >&2
  exit 3
fi
echo "Latest buildx tag: $TAG"

ASSET_NAME="buildx-${TAG}.${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/docker/buildx/releases/download/${TAG}/${ASSET_NAME}"

TMPDIR=$(mktemp -d)
TMPFILE="$TMPDIR/buildx"
echo "Downloading $DOWNLOAD_URL ..."
if ! curl -fsSL -o "$TMPFILE" "$DOWNLOAD_URL"; then
  echo "Download failed for $DOWNLOAD_URL" >&2
  rm -rf "$TMPDIR"
  exit 4
fi
chmod +x "$TMPFILE"

# choose install location
if [ "$EUID" -ne 0 ]; then
  PLUGIN_DIR="$HOME/.docker/cli-plugins"
else
  PLUGIN_DIR="/usr/local/lib/docker/cli-plugins"
fi
mkdir -p "$PLUGIN_DIR"
DEST="$PLUGIN_DIR/docker-buildx"

echo "Installing buildx to $DEST"
mv "$TMPFILE" "$DEST"
chmod 0755 "$DEST"
rm -rf "$TMPDIR"

echo "docker buildx installed to $DEST"
echo "You can verify with: docker buildx version"

exit 0
