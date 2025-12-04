#!/bin/bash
# install.sh - One-liner installer for TermHop Client (th) and Server (TermHop)

set -e

# --- Configuration ---
REPO="termhop/termhop-releases"
INSTALL_DIR="$HOME/.local/bin"
VERSION="latest"

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}TermHop Installer${NC}"
echo "=================="

# 1. Detect OS and Arch
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
fi

echo -e "Detected: ${GREEN}${OS}/${ARCH}${NC}"

# 2. Determine Download URLs
# We use the 'latest' release endpoint to get the tag, then construct the download URL
# Or we can use the 'releases/latest/download' shortcut if we know the filenames.

# Filename patterns from build-and-publish.yml:
# Linux: th-linux, TermHop-linux
# macOS: th-macos-amd64, TermHop-macos-amd64 (or arm64)

DH_BINARY="th-${OS}"
TermHop_BINARY="termhop-${OS}"

if [ "$OS" == "darwin" ]; then
    DH_BINARY="${DH_BINARY}-${ARCH}"
    TermHop_BINARY="${TermHop_BINARY}-${ARCH}"
fi

BASE_URL="https://github.com/${REPO}/releases/latest/download"
DH_URL="${BASE_URL}/${DH_BINARY}"
TermHop_URL="${BASE_URL}/${TermHop_BINARY}"

# 3. Prepare Install Directory
mkdir -p "$INSTALL_DIR"
echo -e "Installing to: ${BLUE}${INSTALL_DIR}${NC}"

# 4. Download and Install
echo -n "Downloading th client... "
curl -L -s -o "${INSTALL_DIR}/th" "$DH_URL"
chmod +x "${INSTALL_DIR}/th"
echo -e "${GREEN}OK${NC}"

echo -n "Downloading TermHop server... "
curl -L -s -o "${INSTALL_DIR}/TermHop" "$TermHop_URL"
chmod +x "${INSTALL_DIR}/TermHop"
echo -e "${GREEN}OK${NC}"

# 5. Path Check
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${RED}Warning: ${INSTALL_DIR} is not in your PATH.${NC}"
    echo "Add the following to your ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 6. Generate/Get Key
echo -n "Generating/Retrieving Auth Key... "
KEY=$("${INSTALL_DIR}/th" -get-key)
echo -e "${GREEN}OK${NC}"

echo
echo -e "${GREEN}Installation Complete!${NC}"
echo "--------------------------------------------------"
echo "Next Steps:"
echo "1. Add the following key to your server's TermHop.yaml:"
echo -e "${BLUE}${KEY}${NC}"
echo
echo "2. **RESTART** the TermHop server (Right-click Tray -> Restart)."
echo "3. Run 'th -init' to connect and configure your client."
echo "--------------------------------------------------"
