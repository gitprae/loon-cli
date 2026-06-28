#!/bin/sh
set -e

# Loon CLI Installation Script
# This script detects the OS and Architecture, downloads the appropriate standalone
# binary and the required tree-sitter.wasm from the latest GitHub release of gitprae/loon-cli.

# Ensure we're running with root privileges for /usr/local/bin
if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root privileges to install the CLI to /usr/local/bin."
  echo "Please run this script using sudo: sudo sh install.sh"
  exit 1
fi

echo "Detecting operating system..."
OS="$(uname -s)"
case "${OS}" in
  Linux*)     OS="linux" ;;
  Darwin*)    OS="darwin" ;;
  *)          echo "Error: Unsupported operating system: ${OS}"; exit 1 ;;
esac

echo "Detecting system architecture..."
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)     ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)          echo "Error: Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

TARGET="${OS}-${ARCH}"
echo "Detected target: ${TARGET}"

# Construct download URLs
REPO="gitprae/loon-cli"
BASE_URL="https://github.com/${REPO}/releases/latest/download"
BINARY_URL="${BASE_URL}/loon-${TARGET}"
WASM_URL="${BASE_URL}/tree-sitter.wasm"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading Loon CLI (${TARGET})..."
curl -sL --fail "${BINARY_URL}" -o "${TMP_DIR}/loon" || {
  echo "Error: Failed to download the Loon binary."
  exit 1
}

echo "Downloading tree-sitter.wasm..."
curl -sL --fail "${WASM_URL}" -o "${TMP_DIR}/tree-sitter.wasm" || {
  echo "Error: Failed to download tree-sitter.wasm."
  exit 1
}

echo "Installing to /usr/local/bin..."
chmod +x "${TMP_DIR}/loon"
mv "${TMP_DIR}/loon" /usr/local/bin/loon
mv "${TMP_DIR}/tree-sitter.wasm" /usr/local/bin/tree-sitter.wasm

echo "✅ Loon CLI successfully installed!"
echo "Run 'loon --help' to get started."
