#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.1.0}"
# Clean version string (remove leading 'v' if present, e.g. v0.1.0 -> 0.1.0)
VERSION="${VERSION#v}"
if [[ ! "$VERSION" =~ ^[0-9] ]]; then
    VERSION="0.0.0-${VERSION}"
fi

BINARY="${2:-mahsang}"
OUTPUT="${3:-mahsang-linux-amd64.deb}"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary '$BINARY' not found." >&2
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/DEBIAN"
mkdir -p "$TMP_DIR/usr/bin"

cp "$BINARY" "$TMP_DIR/usr/bin/mahsang"
chmod 755 "$TMP_DIR/usr/bin/mahsang"

cat <<EOF > "$TMP_DIR/DEBIAN/control"
Package: mahsang
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: MahsaNG Maintainers
Description: MahsaNG Desktop VPN client
 Cross-platform desktop VPN client in Go embedding xray-core.
EOF

chmod 755 "$TMP_DIR/DEBIAN"
chmod 644 "$TMP_DIR/DEBIAN/control"

dpkg-deb --build "$TMP_DIR" "$OUTPUT"
echo "Created Debian package at $OUTPUT"
